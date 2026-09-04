variable "grafana_url" {
  description = "Base URL of the Grafana instance the alert rules and contact points are created in"
  type        = string

  validation {
    condition     = length(var.grafana_url) > 0
    error_message = "grafana_url must not be empty."
  }
}

variable "grafana_auth" {
  description = "Service account token for Grafana API"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags and alert naming"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region the monitored CloudWatch data source queries"
  type        = string
  default     = "us-west-2"
}

variable "alb_arn_suffixes" {
  description = "ALB ARN suffixes to monitor (up to 10 per resume)"
  type        = list(string)
}

variable "alb_names" {
  description = "Human-readable names for each ALB, same order as alb_arn_suffixes"
  type        = list(string)
}

variable "msk_cluster_name" {
  description = "MSK cluster name to monitor; empty string skips MSK alerting"
  type        = string
  default     = ""
}

variable "sqs_queue_names" {
  description = "SQS queue names to monitor for message age"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs to monitor"
  type        = list(string)
  default     = []
}

variable "privatelink_endpoint_service_ids" {
  description = "PrivateLink endpoint service IDs to monitor"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "Slack webhook for alert notifications; empty string skips the Slack contact point"
  type        = string
  sensitive   = true
  default     = ""
}

variable "alert_email" {
  description = "Email address alert notifications are sent to; empty string skips the email contact point"
  type        = string
  default     = ""
}

variable "alb_5xx_threshold" {
  description = "Number of 5XX responses per evaluation window that triggers the ALB error-rate alert"
  type        = number
  default     = 10

  validation {
    condition     = var.alb_5xx_threshold > 0
    error_message = "alb_5xx_threshold must be greater than zero."
  }
}

variable "alb_latency_p99_ms" {
  description = "P99 latency in milliseconds that triggers the ALB latency alert"
  type        = number
  default     = 2000

  validation {
    condition     = var.alb_latency_p99_ms > 0
    error_message = "alb_latency_p99_ms must be greater than zero."
  }
}

variable "sqs_message_age_seconds" {
  description = "Oldest message age in seconds that triggers the SQS backlog alert"
  type        = number
  default     = 300

  validation {
    condition     = var.sqs_message_age_seconds > 0
    error_message = "sqs_message_age_seconds must be greater than zero."
  }
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
