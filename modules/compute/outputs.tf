output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.launch_template.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.launch_template.latest_version
}

output "asg_name" {
  description = "Name of the auto scaling group"
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "ARN of the auto scaling group"
  value       = aws_autoscaling_group.asg.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}

output "ec2_role_name" {
  description = "Name of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}

output "scale_out_policy_arn" {
  description = "ARN of the scale out policy"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale in policy"
  value       = aws_autoscaling_policy.scale_in.arn
}
