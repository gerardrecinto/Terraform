variable "subscription_id" {
  description = "Azure subscription ID the APIM instance and Front Door profile are provisioned in"
  type        = string

  validation {
    condition     = length(var.subscription_id) > 0
    error_message = "subscription_id must not be empty."
  }
}

variable "prefix" {
  description = "Naming prefix applied to resources this workflow creates besides the APIM/Front Door names"
  type        = string
  default     = "PLACEHOLDER_PREFIX"
}

variable "location" {
  description = "Azure region the APIM instance is created in"
  type        = string
  default     = "PLACEHOLDER_AZURE_REGION"
}

variable "networking_resource_group" {
  description = "Resource group containing the VNet APIM's subnet lives in"
  type        = string
}

variable "apim_vnet_name" {
  description = "VNet containing the subnet APIM is injected into"
  type        = string
}

variable "apim_subnet_name" {
  description = "Dedicated /27+ subnet for APIM within apim_vnet_name"
  type        = string
}

variable "dns_resource_group" {
  description = "Resource group containing the private DNS zone used for Key Vault private endpoint resolution"
  type        = string
}

variable "keyvault_name" {
  description = "Key Vault name (3-24 chars, globally unique) APIM pulls named values from"
  type        = string
}

variable "apim_name" {
  description = "APIM service name (globally unique)"
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

variable "apim_sku_tier" {
  description = "APIM SKU tier: Developer or Premium. Premium required for multi-region and zone redundancy"
  type        = string
  default     = "Developer"

  validation {
    condition     = contains(["Developer", "Premium"], var.apim_sku_tier)
    error_message = "apim_sku_tier must be either Developer or Premium."
  }
}

variable "apim_sku_capacity" {
  description = "Number of scale units for the chosen SKU tier"
  type        = number
  default     = 1

  validation {
    condition     = var.apim_sku_capacity > 0
    error_message = "apim_sku_capacity must be greater than zero."
  }
}

variable "apim_hostname" {
  description = "APIM gateway hostname (internal FQDN) used as origin host header by Front Door"
  type        = string
}

variable "jwt_tenant_id" {
  description = "Azure AD tenant ID the inbound JWT validation policy checks tokens against"
  type        = string
  default     = "PLACEHOLDER_TENANT_ID"
}

variable "jwt_audience" {
  description = "Expected audience (aud) claim the inbound JWT validation policy checks tokens against"
  type        = string
}

variable "waf_mode" {
  description = "Front Door WAF policy mode: Detection or Prevention"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be either Detection or Prevention."
  }
}

variable "alert_email_receivers" {
  description = "Email addresses notified when a monitoring alert fires"
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "Days Log Analytics retains ingested logs; Azure allows 30 to 730"
  type        = number
  default     = 90

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default = {
    managed-by  = "terraform"
    environment = "PLACEHOLDER_ENV"
  }
}
