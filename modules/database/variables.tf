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

variable "database_subnet_ids" {
  description = "List of subnet IDs for the database subnet group"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "ID of the security group for the database"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
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
  description = "Password for the database (leave empty to generate a random one)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for database event notifications"
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
