variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "waf_mode" {
  type        = string
  default     = "Prevention"
  description = "Detection or Prevention."
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
  type    = map(string)
  default = {}
}
