variable "region" {
  type    = string
  default = "RegionOne"
}

variable "container_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_read" {
  type    = bool
  default = false
}

variable "default_object_ttl_days" {
  description = "Informational default for callers setting X-Delete-After; Swift enforces per-object expiry, not container-level"
  type        = number
  default     = 365
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "enable_tempurl_key" {
  type    = bool
  default = false
}

variable "tempurl_probe_object" {
  type    = string
  default = ""
}

variable "tempurl_ttl_seconds" {
  type    = number
  default = 3600
}
