variable "prefix" {
  description = "Naming prefix applied to the Front Door profile, endpoint, and WAF policy"
  type        = string
}

variable "location" {
  description = "Azure region used for the WAF policy resource (Front Door itself is global)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the Front Door profile and WAF policy are created in"
  type        = string
}

variable "waf_mode" {
  type        = string
  default     = "Prevention"
  description = "Detection or Prevention."

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be either Detection or Prevention."
  }
}

variable "apim_id" {
  type        = string
  description = "APIM resource ID used as the Private Link origin target."
}

variable "apim_hostname" {
  type        = string
  description = "APIM gateway hostname (internal FQDN) used as origin host header."
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
