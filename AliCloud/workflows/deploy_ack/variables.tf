variable "region" {
  description = "AliCloud region for the ACK cluster, log bucket, and API gateway"
  type        = string
  default     = "cn-hangzhou"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); sizes node pools and drives resource naming"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "vpc_id" {
  description = "VPC the vswitches below belong to; not passed to the ACK module directly (it derives VPC from vswitch_ids), kept here so the caller's VPC context is explicit"
  type        = string
}

variable "vswitch_ids" {
  description = "VSwitch IDs the cluster's control plane and node pools attach to; must span at least one zone"
  type        = list(string)

  validation {
    condition     = length(var.vswitch_ids) > 0
    error_message = "vswitch_ids must contain at least one vswitch."
  }
}
