variable "name" {
  type        = string
  description = "APIM service name (globally unique)."
}

variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "sku_tier" {
  type        = string
  default     = "Developer"
  description = "Developer | Premium. Premium required for multi-region and zone redundancy."
}

variable "sku_capacity" {
  type    = number
  default = 1
}

variable "apim_subnet_id" {
  type        = string
  description = "Dedicated /27+ subnet for APIM (NSG must allow management ports 3443/6390)."
}

variable "key_vault_id" {
  type    = string
  default = ""
}

variable "key_vault_named_values" {
  type = map(object({
    secret_id = string
  }))
  default     = {}
  description = "Named values to pull from Key Vault at runtime."
}

variable "jwt_tenant_id" {
  type = string
}

variable "jwt_audience" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
