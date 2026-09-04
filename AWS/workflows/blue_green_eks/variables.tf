variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region the EKS cluster and its weighted ALB target groups are provisioned in"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "VPC the EKS cluster and ALB target groups are provisioned in"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "k8s_namespace" {
  description = "Kubernetes namespace the migrated workload runs in on EKS"
  type        = string
  default     = "default"
}

# Traffic weight to EKS (0-100). Beanstalk gets the remainder.
# Migration sequence: 0 -> 10 -> 50 -> 100
variable "eks_traffic_weight" {
  description = "Percentage of ALB traffic weighted to EKS (0-100); Beanstalk gets the remainder. Migration sequence: 0 -> 10 -> 50 -> 100"
  type        = number
  default     = 0

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
