output "website_domain" {
  description = "The full domain name of the website"
  value       = var.create_sub_domain ? "${var.sub_domain}.${var.domain_name}" : var.domain_name
}

output "hosted_zone_id" {
  description = "ID of the hosted zone"
  value       = data.aws_route53_zone.hosted_zone.zone_id
}

output "health_check_id" {
  description = "ID of the health check (if created)"
  value       = var.create_health_check ? aws_route53_health_check.health_check[0].id : null
}
