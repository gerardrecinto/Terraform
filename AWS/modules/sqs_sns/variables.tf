variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "fifo" {
  type    = bool
  default = false
}

# Message retention in seconds (default 4 days)
variable "message_retention_seconds" {
  type    = number
  default = 345600
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

# DLQ -- messages that fail maxReceiveCount times go here
variable "max_receive_count" {
  type    = number
  default = 5
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

# SNS topic alongside the queue -- set to false if you only need SQS
variable "create_sns_topic" {
  type    = bool
  default = true
}

# Subscribe the SQS queue to the SNS topic automatically
variable "subscribe_sqs_to_sns" {
  type    = bool
  default = true
}

# Additional SNS subscriber endpoints (Lambda ARNs, HTTPS endpoints)
variable "sns_subscriptions" {
  type    = map(object({ protocol = string, endpoint = string }))
  default = {}
}

variable "allowed_aws_services" {
  description = "AWS service principals allowed to send to SNS/SQS (e.g., s3.amazonaws.com)"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
