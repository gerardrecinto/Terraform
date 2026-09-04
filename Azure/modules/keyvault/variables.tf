variable "name" {
  type        = string
  description = "Key Vault name (3-24 chars, globally unique)."
}

variable "location" {
  description = "Azure region the Key Vault is created in"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the Key Vault is created in"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet the vault's private endpoint NIC attaches to"
  type        = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "privatelink.vaultcore.azure.net DNS zone resource ID."
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID vault diagnostic logs (secret access, etc.) are sent to"
  type        = string
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed through the vault's network ACL, in addition to the private endpoint"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "Public CIDR ranges allowed through the vault's network ACL"
  type        = list(string)
  default     = []
}

variable "grant_deployer_admin" {
  description = "Grant the identity running terraform full admin access to secrets/keys/certificates, needed the first time a vault is created before officer/reader roles exist"
  type        = bool
  default     = false
}

variable "reader_principal_ids" {
  description = "Principal IDs granted read-only access to secrets, keys, and certificates"
  type        = list(string)
  default     = []
}

variable "officer_principal_ids" {
  description = "Principal IDs granted full manage access to secrets, keys, and certificates"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
