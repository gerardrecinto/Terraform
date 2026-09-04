variable "region" {
  description = "OpenStack region the container is created in"
  type        = string
  default     = "RegionOne"
}

variable "container_name" {
  description = "Name of the primary Swift container; its versions container is named \"<container_name>-versions\""
  type        = string

  validation {
    condition     = length(var.container_name) > 0
    error_message = "container_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into container metadata"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "public_read" {
  description = "Whether the container allows anonymous read access (.r:*); leave false for anything not meant to be public"
  type        = bool
  default     = false
}

variable "default_object_ttl_days" {
  description = "Informational default for callers setting X-Delete-After; Swift enforces per-object expiry, not container-level"
  type        = number
  default     = 365

  validation {
    condition     = var.default_object_ttl_days > 0
    error_message = "default_object_ttl_days must be greater than zero."
  }
}

variable "metadata" {
  description = "Additional container metadata merged with the environment and terraform-managed keys"
  type        = map(string)
  default     = {}
}

variable "enable_tempurl_key" {
  description = "Whether to generate a signed, time-limited temp URL for tempurl_probe_object instead of exposing the container publicly"
  type        = bool
  default     = false
}

variable "tempurl_probe_object" {
  description = "Object name to generate the temp URL for; required when enable_tempurl_key is true"
  type        = string
  default     = ""
}

variable "tempurl_ttl_seconds" {
  description = "How long the generated temp URL stays valid, in seconds"
  type        = number
  default     = 3600

  validation {
    condition     = var.tempurl_ttl_seconds > 0
    error_message = "tempurl_ttl_seconds must be greater than zero."
  }
}
