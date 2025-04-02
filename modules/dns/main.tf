# Get the Route53 hosted zone
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  private_zone = false
}

# Create Route53 record for the main domain
resource "aws_route53_record" "main_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.create_sub_domain ? "${var.sub_domain}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Create Route53 record for www subdomain (if needed)
resource "aws_route53_record" "www_record" {
  count   = var.create_www_record ? 1 : 0
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www.${var.create_sub_domain ? "${var.sub_domain}." : ""}${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Optional: Create health check for the website
resource "aws_route53_health_check" "health_check" {
  count             = var.create_health_check ? 1 : 0
  fqdn              = var.create_sub_domain ? "${var.sub_domain}.${var.domain_name}" : var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-health-check"
    }
  )
}

# Optional: Set up DNS failover if multiple regions are used
resource "aws_route53_record" "failover_record" {
  count   = var.enable_failover && var.failover_alb_dns_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.create_sub_domain ? "${var.sub_domain}.${var.domain_name}" : var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "${var.app_name}-${var.environment}-secondary"

  alias {
    name                   = var.failover_alb_dns_name
    zone_id                = var.failover_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.health_check[0].id
}
