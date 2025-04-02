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

variable "bucket_suffix" {
  description = "Suffix to make the S3 bucket name unique"
  type        = string
}

variable "cloudfront_price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "include_api_origin" {
  description = "Whether to include an API origin for backend requests"
  type        = bool
  default     = true
}

variable "api_domain_name" {
  description = "Domain name for the API (ALB DNS name)"
  type        = string
  default     = ""
}

variable "use_custom_domain" {
  description = "Whether to use a custom domain for the CloudFront distribution"
  type        = bool
  default     = false
}

variable "static_domain_name" {
  description = "Custom domain name for the static assets"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
  default     = ""
}

variable "geo_restriction_type" {
  description = "Type of geo restriction for the CloudFront distribution"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Whether to enable CloudFront access logs"
  type        = bool
  default     = false
}

variable "logging_bucket_domain_name" {
  description = "Domain name of the S3 bucket for CloudFront logs"
  type        = string
  default     = ""
}

variable "web_acl_id" {
  description = "ID of the AWS WAF web ACL"
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
