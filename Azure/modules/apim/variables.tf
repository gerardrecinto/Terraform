variable "name" {
  type        = string
  description = "APIM service name (globally unique)."
}

variable "prefix" {
  description = "Naming prefix applied to resources this module creates besides the APIM service itself"
  type        = string
}

variable "location" {
  description = "Azure region the APIM instance is created in"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the APIM instance is created in"
  type        = string
}

variable "publisher_name" {
  description = "Publisher organization name shown in the APIM developer portal"
  type        = string
}

variable "publisher_email" {
  description = "Publisher notification email address for APIM system alerts"
  type        = string
}

variable "sku_tier" {
  type        = string
  default     = "Developer"
  description = "Developer | Premium. Premium required for multi-region and zone redundancy."
}

variable "sku_capacity" {
  description = "Number of scale units for the chosen SKU tier"
  type        = number
  default     = 1

  validation {
    condition     = var.sku_capacity > 0
    error_message = "sku_capacity must be greater than zero."
  }
}

variable "apim_subnet_id" {
  type        = string
  description = "Dedicated /27+ subnet for APIM (NSG must allow management ports 3443/6390)."
}

variable "key_vault_id" {
  description = "Key Vault resource ID APIM's system identity is granted access to; empty string skips Key Vault integration"
  type        = string
  default     = ""
}

variable "key_vault_named_values" {
  type = map(object({
    secret_id = string
  }))
  default     = {}
  description = "Named values to pull from Key Vault at runtime."
}

variable "jwt_tenant_id" {
  description = "Azure AD tenant ID the inbound JWT validation policy checks tokens against"
  type        = string
}

variable "jwt_audience" {
  description = "Expected audience (aud) claim the inbound JWT validation policy checks tokens against"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID APIM diagnostic logs are sent to"
  type        = string
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
