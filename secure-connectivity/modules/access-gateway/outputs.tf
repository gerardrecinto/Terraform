output "gateway_security_group_id" {
  description = "Security group ID attached to the gateway."
  value       = aws_security_group.gateway.id
}

output "gateway_iam_role_arn" {
  description = "ARN of the gateway's IAM role (SSM-managed)."
  value       = aws_iam_role.gateway.arn
}

output "autoscaling_group_name" {
  description = "Name of the single-instance Auto Scaling group backing the gateway."
  value       = aws_autoscaling_group.gateway.name
}

output "log_group_name" {
  description = "CloudWatch Logs group for gateway system/auth logs."
  value       = aws_cloudwatch_log_group.gateway.name
}
