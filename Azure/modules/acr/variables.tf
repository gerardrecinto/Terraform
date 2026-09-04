variable "registry_name" {
  description = "Globally unique ACR registry name (alphanumeric only, no hyphens)"
  type        = string

  validation {
    condition     = length(var.registry_name) > 0
    error_message = "registry_name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group the registry is created in"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region the registry is created in"
  type        = string
  default     = "westus2"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "sku" {
  description = "ACR SKU tier; Premium required for geo-replication and network rules"
  type        = string
  default     = "Premium" # Premium required for geo-replication and network rules
}

variable "geo_replication_locations" {
  description = "Additional Azure regions to geo-replicate the registry to"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "CIDRs allowed through the network rule (AKS egress IPs, VPN, etc.)"
  type        = list(string)
  default     = []
}

variable "enable_retention_policy" {
  description = "Enable the weekly cleanup task that untags images older than the retention window"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
