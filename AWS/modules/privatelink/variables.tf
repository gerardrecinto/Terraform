variable "service_name" {
  description = "Name prefix for all PrivateLink resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC the endpoint service's NLB and consumer endpoint (when created) live in"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "subnet_ids" {
  description = "Subnets where the VPC endpoint will place ENIs"
  type        = list(string)
}

variable "consumer_vpc_id" {
  description = "VPC ID of the consumer account (cross-account)"
  type        = string
  default     = ""
}

variable "allowed_principals" {
  description = "AWS account ARNs allowed to connect to the endpoint service"
  type        = list(string)
  default     = []
}

variable "nlb_arn" {
  description = "ARN of the NLB backing the endpoint service"
  type        = string
}

variable "tcp_ports" {
  description = "SSH/WebSocket TCP passthrough ports the endpoint service forwards (e.g., 22, 443)"
  type        = list(number)
  default     = [22, 443]

  validation {
    condition     = length(var.tcp_ports) > 0
    error_message = "tcp_ports must contain at least one port."
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

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
