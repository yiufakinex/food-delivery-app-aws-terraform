output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.alb_target_group.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http_listener.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https_listener.arn
}
