output "s3_bucket_id" {
  description = "ID of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets_distribution.arn
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets_distribution.domain_name
}

output "cloudfront_distribution_zone_id" {
  description = "Zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_assets_distribution.hosted_zone_id
}

output "static_assets_url" {
  description = "URL for accessing the static assets"
  value       = var.use_custom_domain ? "https://${var.static_domain_name}" : "https://${aws_cloudfront_distribution.static_assets_distribution.domain_name}"
}
