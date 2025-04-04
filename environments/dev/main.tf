provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local variables
locals {
  app_name    = "fodeliapp"
  environment = "dev"

  common_tags = {
    Project     = "FoodDeliveryApp"
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

# Random string for uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# SNS Topic for Notifications
resource "aws_sns_topic" "notifications" {
  name = "${local.app_name}-${local.environment}-notifications"

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.operator_email
}

# S3 Bucket for Access Logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${local.app_name}-${local.environment}-logs-${random_string.suffix.result}"

  tags = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_bucket_ownership]

  bucket = aws_s3_bucket.logs_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs_bucket.id

  rule {
    id     = "log-rotation"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  app_name    = local.app_name
  environment = local.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones

  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs

  single_nat_gateway = true
  enable_flow_logs   = false

  common_tags = local.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"

  app_name    = local.app_name
  environment = local.environment
  vpc_id      = module.networking.vpc_id

  ssh_allowed_cidrs = var.ssh_allowed_cidrs

  common_tags = local.common_tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  app_name                   = local.app_name
  environment                = local.environment
  database_subnet_ids        = module.networking.private_data_subnet_ids
  database_security_group_id = module.security.database_security_group_id

  db_instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password

  sns_topic_arn = aws_sns_topic.notifications.arn

  common_tags = local.common_tags
}

# Load Balancer Module
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  app_name    = local.app_name
  environment = local.environment
  vpc_id      = module.networking.vpc_id

  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id

  certificate_arn = var.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"

  health_check_path = "/"
  enable_stickiness = true

  enable_access_logs = true
  access_logs_bucket = aws_s3_bucket.logs_bucket.bucket_domain_name

  common_tags = local.common_tags
}

# Static Content Delivery
module "static_content" {
  source = "../../modules/static-content"

  app_name      = local.app_name
  environment   = local.environment
  bucket_suffix = random_string.suffix.result

  cloudfront_price_class = "PriceClass_100"

  include_api_origin = true
  api_domain_name    = module.loadbalancer.alb_dns_name

  use_custom_domain  = true
  static_domain_name = "static.${var.domain_name}"
  hosted_zone_id     = var.hosted_zone_id
  certificate_arn    = var.cloudfront_certificate_arn

  enable_logging             = true
  logging_bucket_domain_name = aws_s3_bucket.logs_bucket.bucket_domain_name

  common_tags = local.common_tags
}

# Compute (EC2, ASG) Module
module "compute" {
  source = "../../modules/compute"

  app_name    = local.app_name
  environment = local.environment
  region      = var.region

  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  ebs_volume_size       = 20
  web_security_group_id = module.security.webserver_security_group_id

  private_subnet_ids = module.networking.private_app_subnet_ids
  target_group_arn   = module.loadbalancer.target_group_arn

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  db_endpoint = module.database.db_instance_endpoint
  db_name     = module.database.db_instance_name
  db_username = module.database.db_instance_username
  db_password = var.db_password

  sns_topic_arn = aws_sns_topic.notifications.arn

  common_tags = local.common_tags
}

# DNS Module
module "dns" {
  source = "../../modules/dns"

  app_name    = local.app_name
  environment = local.environment

  domain_name       = var.domain_name
  create_sub_domain = true
  sub_domain        = local.environment
  create_www_record = true

  alb_dns_name = module.loadbalancer.alb_dns_name
  alb_zone_id  = module.loadbalancer.alb_zone_id

  create_health_check = true
  health_check_path   = "/health"

  enable_failover = false

  common_tags = local.common_tags
}

