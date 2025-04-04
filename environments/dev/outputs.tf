# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "website_url" {
  description = "URL of the website"
  value       = "https://${module.dns.website_domain}"
}

output "static_content_url" {
  description = "URL for accessing static content"
  value       = module.static_content.static_assets_url
}

output "db_endpoint" {
  description = "Endpoint of the database"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.static_content.cloudfront_distribution_id
}
