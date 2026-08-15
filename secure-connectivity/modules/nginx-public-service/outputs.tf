output "alb_dns_name" {
  description = "Public DNS name of the ALB. Point a Route 53 record here, or use directly."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID for the ALB, for alias record creation."
  value       = aws_lb.this.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID attached to the NGINX instances."
  value       = aws_security_group.app.id
}

output "target_group_arn" {
  description = "ARN of the ALB target group, for wiring additional alarms/dashboards."
  value       = aws_lb_target_group.this.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling group."
  value       = aws_autoscaling_group.this.name
}

output "instance_iam_role_arn" {
  description = "ARN of the instance IAM role (SSM-managed, no SSH)."
  value       = aws_iam_role.instance.arn
}

output "https_enabled" {
  description = "Whether this deployment is running with a TLS listener (true) or HTTP-only demo mode (false)."
  value       = local.https_enabled
}
