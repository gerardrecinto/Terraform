output "instance_ids" {
  description = "IDs of the private instances."
  value       = aws_instance.this[*].id
}

output "instance_private_ips" {
  description = "Private IPs of the instances (no public IPs exist)."
  value       = aws_instance.this[*].private_ip
}

output "instance_security_group_id" {
  description = "Security group ID attached to the instances."
  value       = aws_security_group.instance.id
}

output "instance_iam_role_arn" {
  description = "ARN of the instance IAM role (SSM-managed, no SSH)."
  value       = aws_iam_role.instance.arn
}

output "session_log_group_name" {
  description = "CloudWatch Logs group receiving Session Manager output, if enable_session_logging is true."
  value       = var.enable_session_logging ? aws_cloudwatch_log_group.sessions[0].name : null
}

output "vpc_endpoints_enabled" {
  description = "Whether SSM VPC interface endpoints were created by this module."
  value       = var.enable_vpc_endpoints
}
