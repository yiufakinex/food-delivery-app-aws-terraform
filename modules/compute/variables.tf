variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "fodeliapp"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = ""
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
}

variable "web_security_group_id" {
  description = "ID of the security group for web servers"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for the ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for the ALB"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = 2
}

variable "db_endpoint" {
  description = "Endpoint of the database"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for ASG notifications"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "FoodDeliveryApp"
    ManagedBy = "Terraform"
  }
}
