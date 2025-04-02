# Create a random password for the database if not provided
resource "random_password" "db_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = false
}

# Create a DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.app_name}-${var.environment}-db-subnet-group"
  subnet_ids  = var.database_subnet_ids
  description = "Subnet group for ${var.app_name} ${var.environment} database"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-db-subnet-group"
    }
  )
}

# Create a DB parameter group
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.app_name}-${var.environment}-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for ${var.app_name} ${var.environment} database"

  # Example parameters 
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = var.environment == "prod" ? "150" : "50"
  }

  tags = var.common_tags
}

# Create a DB instance
resource "aws_db_instance" "db_instance" {
  identifier        = "${var.app_name}-${var.environment}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password == "" ? random_password.db_password[0].result : var.db_password

  vpc_security_group_ids = [var.database_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  # Backup and maintenance
  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # High availability
  multi_az = var.environment == "prod"

  # Performance Insights
  performance_insights_enabled = var.environment == "prod"

  # Storage autoscaling
  max_allocated_storage = var.environment == "prod" ? 100 : 50

  # Protection
  deletion_protection       = var.environment == "prod"
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.app_name}-${var.environment}-final-snapshot" : null

  # Monitoring
  monitoring_interval = var.environment == "prod" ? 60 : 0

  # Apply immediately in non-prod environments
  apply_immediately = var.environment != "prod"

  # DB Options
  auto_minor_version_upgrade = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-db"
    }
  )
}

# Create monitoring role if monitoring is enabled (for prod)
resource "aws_iam_role" "rds_monitoring_role" {
  count = var.environment == "prod" ? 1 : 0
  name  = "${var.app_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attachment" {
  count      = var.environment == "prod" ? 1 : 0
  role       = aws_iam_role.rds_monitoring_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Create an RDS event subscription to get notifications about RDS events
resource "aws_db_event_subscription" "default" {
  count     = var.sns_topic_arn != "" ? 1 : 0
  name      = "${var.app_name}-${var.environment}-db-event-subscription"
  sns_topic = var.sns_topic_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.db_instance.id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "recovery",
    "restoration",
  ]

  tags = var.common_tags
}
