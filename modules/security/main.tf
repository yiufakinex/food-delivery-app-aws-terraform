# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = var.vpc_id

  # HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.app_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion host (SSH access)"
  vpc_id      = var.vpc_id

  # SSH from specified IPs
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-bastion-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Web Server Security Group
resource "aws_security_group" "webserver_sg" {
  name        = "${var.app_name}-${var.environment}-webserver-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # HTTPS from ALB only
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH from bastion only
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-webserver-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group
resource "aws_security_group" "database_sg" {
  name        = "${var.app_name}-${var.environment}-database-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # MySQL/Aurora from web servers only
  ingress {
    description     = "MySQL/Aurora access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_sg.id]
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-database-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
