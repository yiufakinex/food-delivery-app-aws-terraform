# Create IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.app_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Create EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.app_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create Launch Template
resource "aws_launch_template" "launch_template" {
  name          = "${var.app_name}-${var.environment}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_security_group_id]
    delete_on_termination       = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    app_name    = var.app_name
    environment = var.environment
    region      = var.region
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.app_name}-${var.environment}-instance"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                = "${var.app_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  # Enable instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
    }
  }

  dynamic "tag" {
    for_each = merge(
      var.common_tags,
      {
        Name = "${var.app_name}-${var.environment}-asg-instance"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# CPU Scaling Policy - Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.app_name}-${var.environment}-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# CPU Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-${var.environment}-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Scale out if CPU utilization is above 80% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]

  tags = var.common_tags
}

# CPU Scaling Policy - Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.app_name}-${var.environment}-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# CPU Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.app_name}-${var.environment}-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Scale in if CPU utilization is below 20% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]

  tags = var.common_tags
}

# ASG Notifications
resource "aws_autoscaling_notification" "asg_notifications" {
  count = var.sns_topic_arn != "" ? 1 : 0

  group_names = [aws_autoscaling_group.asg.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.sns_topic_arn
}
