variable "subscription_id" {
  type = string
}

variable "prefix" {
  type    = string
  default = "PLACEHOLDER_PREFIX"
}

variable "location" {
  type    = string
  default = "PLACEHOLDER_AZURE_REGION"
}

variable "networking_resource_group" {
  type = string
}

variable "apim_vnet_name" {
  type = string
}

variable "apim_subnet_name" {
  type = string
}

variable "dns_resource_group" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "apim_name" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "apim_sku_tier" {
  type    = string
  default = "Developer"
}

variable "apim_sku_capacity" {
  type    = number
  default = 1
}

variable "apim_hostname" {
  type = string
}

variable "jwt_tenant_id" {
  type    = string
  default = "PLACEHOLDER_TENANT_ID"
}

variable "jwt_audience" {
  type = string
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "alert_email_receivers" {
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    environment = "PLACEHOLDER_ENV"
  }
}
