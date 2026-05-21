variable "name" {
  type        = string
  description = "Key Vault name (3-24 chars, globally unique)."
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "privatelink.vaultcore.azure.net DNS zone resource ID."
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "allowed_subnet_ids" {
  type    = list(string)
  default = []
}

variable "allowed_ip_ranges" {
  type    = list(string)
  default = []
}

variable "grant_deployer_admin" {
  type    = bool
  default = false
}

variable "reader_principal_ids" {
  type    = list(string)
  default = []
}

variable "officer_principal_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
