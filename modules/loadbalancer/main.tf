# Create Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod"
  drop_invalid_header_fields = true

  # Enable access logs if specified
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "${var.app_name}-${var.environment}-alb-logs"
      enabled = true
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-alb"
    }
  )
}

# Create Target Group for ALB
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.app_name}-${var.environment}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200,301,302"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  stickiness {
    enabled         = var.enable_stickiness
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (with redirect to HTTPS)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# Add optional path-based routing rules if enabled
resource "aws_lb_listener_rule" "path_based_routing" {
  count        = length(var.path_based_routes)
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100 + count.index

  action {
    type             = "forward"
    target_group_arn = var.path_based_routes[count.index].target_group_arn
  }

  condition {
    path_pattern {
      values = [var.path_based_routes[count.index].path_pattern]
    }
  }
}
