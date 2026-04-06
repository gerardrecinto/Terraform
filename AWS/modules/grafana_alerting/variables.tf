variable "grafana_url" {
  type = string
}

variable "grafana_auth" {
  description = "Service account token for Grafana API"
  type        = string
  sensitive   = true
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

# ALB ARN suffixes to monitor (up to 10 per resume)
variable "alb_arn_suffixes" {
  type = list(string)
}

variable "alb_names" {
  description = "Human-readable names for each ALB, same order as alb_arn_suffixes"
  type        = list(string)
}

# MSK cluster name
variable "msk_cluster_name" {
  type    = string
  default = ""
}

# SQS queue names to monitor
variable "sqs_queue_names" {
  type    = list(string)
  default = []
}

# SNS topic ARNs to monitor
variable "sns_topic_arns" {
  type    = list(string)
  default = []
}

# PrivateLink endpoint service IDs to monitor
variable "privatelink_endpoint_service_ids" {
  type    = list(string)
  default = []
}

# Slack webhook for alert notifications
variable "slack_webhook_url" {
  type      = string
  sensitive = true
  default   = ""
}

variable "alert_email" {
  type    = string
  default = ""
}

# Thresholds
variable "alb_5xx_threshold" {
  type    = number
  default = 10
}

variable "alb_latency_p99_ms" {
  type    = number
  default = 2000
}

variable "sqs_message_age_seconds" {
  type    = number
  default = 300
}

variable "tags" {
  type    = map(string)
  default = {}
}
