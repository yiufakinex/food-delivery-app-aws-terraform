output "db_instance_endpoint" {
  description = "Connection endpoint for the database"
  value       = aws_db_instance.db_instance.endpoint
}

output "db_instance_address" {
  description = "Address of the database instance"
  value       = aws_db_instance.db_instance.address
}

output "db_instance_port" {
  description = "Port of the database instance"
  value       = aws_db_instance.db_instance.port
}

output "db_instance_name" {
  description = "Name of the database"
  value       = aws_db_instance.db_instance.db_name
}

output "db_instance_username" {
  description = "Username for the database"
  value       = aws_db_instance.db_instance.username
}

output "db_instance_password" {
  description = "Password for the database (only available if randomly generated)"
  value       = var.db_password == "" ? random_password.db_password[0].result : "Provided externally"
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
}

output "db_parameter_group_name" {
  description = "Name of the database parameter group"
  value       = aws_db_parameter_group.db_parameter_group.name
}
