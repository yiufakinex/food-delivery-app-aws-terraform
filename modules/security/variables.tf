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

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "FoodDeliveryApp"
    ManagedBy = "Terraform"
  }
}
