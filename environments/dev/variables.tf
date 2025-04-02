# Provider Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "profile" {
  description = "AWS profile to use"
  type        = string
  default     = "terraform-user"
}

# VPC and Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks for private data subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

# Security
variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the bastion host"
  type        = list(string)
  default     = ["198.xx.xx.xx/32"]
}

# Database
variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "fodeliapp"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

# Compute
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0a2e7efb4257c0907"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "fodeliapp-key"
}

# DNS and SSL
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "fooddeli.com"
}

variable "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  type        = string
  default     = "example.demo"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for ALB"
  type        = string
  default     = "demo"
}

variable "cloudfront_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront (must be in us-east-1)"
  type        = string
  default     = "example"
}

# Notifications
variable "operator_email" {
  description = "Email address for notifications"
  type        = string
  default     = "franklin@example.com"
}
