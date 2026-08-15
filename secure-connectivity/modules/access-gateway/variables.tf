variable "name" {
  description = "Name prefix applied to all resources created by this module."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the gateway instance."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 1
    error_message = "Provide at least 1 public subnet."
  }
}

variable "target_security_group_id" {
  description = "Security group ID of the private target(s) this gateway is allowed to reach (e.g. the private-compute-access module's instance_security_group_id output). The gateway's egress is restricted to this security group on port 22 -- it cannot reach anything else in the VPC."
  type        = string
}

variable "admin_cidr_allowlist" {
  description = "CIDR blocks allowed to SSH into the gateway. Required, non-empty, and may never include 0.0.0.0/0 or ::/0 -- this module refuses to create an internet-open SSH ingress rule under any configuration."
  type        = list(string)

  validation {
    condition     = length(var.admin_cidr_allowlist) > 0
    error_message = "admin_cidr_allowlist must not be empty -- this module has no default-open SSH mode."
  }

  validation {
    condition     = !contains(var.admin_cidr_allowlist, "0.0.0.0/0") && !contains(var.admin_cidr_allowlist, "::/0")
    error_message = "admin_cidr_allowlist must not include 0.0.0.0/0 or ::/0. This module intentionally has no supported way to open SSH to the whole internet."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the gateway."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access to the gateway. Optional -- this module does not create or store any key pair. Leave empty to administer the gateway itself via Session Manager only (recommended); the gateway still forwards SSH to the private target using whatever key the operator supplies out-of-band."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for gateway system/auth logs, in days."
  type        = number
  default     = 30
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed (1-minute) CloudWatch monitoring."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
