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

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "enable_stickiness" {
  description = "Enable stickiness for the target group"
  type        = bool
  default     = false
}

variable "enable_access_logs" {
  description = "Enable access logs for the ALB"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

variable "path_based_routes" {
  description = "Path-based routing rules"
  type = list(object({
    path_pattern     = string
    target_group_arn = string
  }))
  default = []
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "FoodDeliveryApp"
    ManagedBy = "Terraform"
  }
}
