variable "name" {
  description = "Base name for the SQS queue, its DLQ, and the optional SNS topic"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "fifo" {
  description = "Create a FIFO queue/topic instead of standard; FIFO guarantees ordering and exactly-once delivery at lower throughput"
  type        = bool
  default     = false
}

variable "message_retention_seconds" {
  description = "Message retention in seconds (default 4 days); SQS allows 60 to 1209600 (14 days)"
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 and 1209600 (14 days)."
  }
}

variable "visibility_timeout_seconds" {
  description = "Seconds a received message is hidden from other consumers before becoming visible again; SQS allows 0 to 43200 (12 hours)"
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200 (12 hours)."
  }
}

variable "max_receive_count" {
  description = "DLQ -- messages that fail this many receive attempts are moved to the dead-letter queue"
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count > 0
    error_message = "max_receive_count must be greater than zero."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption; empty string uses SSE-SQS"
  type        = string
  default     = ""
}

variable "create_sns_topic" {
  description = "SNS topic alongside the queue -- set to false if you only need SQS"
  type        = bool
  default     = true
}

variable "subscribe_sqs_to_sns" {
  description = "Subscribe the SQS queue to the SNS topic automatically"
  type        = bool
  default     = true
}

variable "sns_subscriptions" {
  description = "Additional SNS subscriber endpoints (Lambda ARNs, HTTPS endpoints), keyed by subscription name"
  type        = map(object({ protocol = string, endpoint = string }))
  default     = {}
}

variable "allowed_aws_services" {
  description = "AWS service principals allowed to send to SNS/SQS (e.g., s3.amazonaws.com)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
