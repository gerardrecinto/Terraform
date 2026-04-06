variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_id" {
  type = string
}

variable "k8s_namespace" {
  type    = string
  default = "default"
}

# Traffic weight to EKS (0-100). Beanstalk gets the remainder.
# Migration sequence: 0 -> 10 -> 50 -> 100
variable "eks_traffic_weight" {
  type    = number
  default = 0

  validation {
    condition     = var.eks_traffic_weight >= 0 && var.eks_traffic_weight <= 100
    error_message = "eks_traffic_weight must be between 0 and 100."
  }
}

variable "sns_alert_arn" {
  description = "SNS topic ARN for 5XX alarm during migration"
  type        = string
  default     = ""
}
