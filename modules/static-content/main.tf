# Create S3 bucket for static assets
resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.app_name}-${var.environment}-static-assets-${var.bucket_suffix}"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-static-assets"
    }
  )
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "static_assets_block" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure bucket ownership
resource "aws_s3_bucket_ownership_controls" "static_assets_ownership" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Create Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "static_assets_oac" {
  name                              = "${var.app_name}-${var.environment}-static-assets-oac"
  description                       = "Origin Access Control for ${var.app_name} static assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Bucket policy allowing CloudFront access
resource "aws_s3_bucket_policy" "static_assets_policy" {
  bucket = aws_s3_bucket.static_assets.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_assets_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.static_assets_distribution
  ]
}

# Create CloudFront distribution for static assets
resource "aws_cloudfront_distribution" "static_assets_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.app_name}-${var.environment} static assets distribution"
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  # Main S3 origin
  origin {
    domain_name              = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.static_assets.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.static_assets_oac.id
  }

  # Website ALB origin for API calls
  dynamic "origin" {
    for_each = var.include_api_origin ? [1] : []
    content {
      domain_name = var.api_domain_name
      origin_id   = "ALB-API"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # Default cache behavior for static assets
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${aws_s3_bucket.static_assets.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Cache behavior for API calls
  dynamic "ordered_cache_behavior" {
    for_each = var.include_api_origin ? [1] : []
    content {
      path_pattern     = "/api/*"
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "ALB-API"

      forwarded_values {
        query_string = true
        headers      = ["Authorization", "Origin", "Host"]
        cookies {
          forward = "all"
        }
      }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
    }
  }

  # Custom error response for SPA routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Domain settings
  aliases = var.use_custom_domain ? [var.static_domain_name] : []

  # SSL certificate
  dynamic "viewer_certificate" {
    for_each = var.use_custom_domain ? [1] : []
    content {
      acm_certificate_arn      = var.certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.use_custom_domain ? [] : [1]
    content {
      cloudfront_default_certificate = true
    }
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # Logging
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket_domain_name
      prefix          = "${var.app_name}-${var.environment}-cloudfront-logs/"
    }
  }

  # Web Application Firewall
  web_acl_id = var.web_acl_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-cloudfront-distribution"
    }
  )
}

# Create Route53 record for CloudFront (if custom domain is used)
resource "aws_route53_record" "static_assets_record" {
  count   = var.use_custom_domain ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.static_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_assets_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_assets_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
