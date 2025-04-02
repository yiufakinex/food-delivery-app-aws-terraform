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

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "create_sub_domain" {
  description = "Whether to create a subdomain record"
  type        = bool
  default     = false
}

variable "sub_domain" {
  description = "Subdomain to use (if create_sub_domain is true)"
  type        = string
  default     = "app"
}

variable "create_www_record" {
  description = "Whether to create a www record"
  type        = bool
  default     = true
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}

variable "create_health_check" {
  description = "Whether to create a Route53 health check"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "enable_failover" {
  description = "Whether to enable DNS failover to a secondary region"
  type        = bool
  default     = false
}

variable "failover_alb_dns_name" {
  description = "DNS name of the ALB in the failover region"
  type        = string
  default     = ""
}

variable "failover_alb_zone_id" {
  description = "Zone ID of the ALB in the failover region"
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
