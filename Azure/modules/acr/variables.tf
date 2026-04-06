variable "registry_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "environment" {
  type = string
}

variable "sku" {
  type    = string
  default = "Premium"  # Premium required for geo-replication and network rules
}

variable "geo_replication_locations" {
  type    = list(string)
  default = []
}

variable "allowed_ip_ranges" {
  description = "CIDRs allowed through the network rule (AKS egress IPs, VPN, etc.)"
  type        = list(string)
  default     = []
}

variable "enable_retention_policy" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
