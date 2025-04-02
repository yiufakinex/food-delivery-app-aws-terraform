output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

output "webserver_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.webserver_sg.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database_sg.id
}
