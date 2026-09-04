variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "object_prefix" {
  type    = string
  default = ""
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "access_log_bucket" {
  type    = string
  default = ""
}

variable "transition_to_ia_days" {
  type    = number
  default = 30
}

variable "transition_to_archive_days" {
  type    = number
  default = 90
}

variable "transition_to_cold_archive_days" {
  type    = number
  default = 180
}

variable "expiration_days" {
  type    = number
  default = 365
}

variable "tags" {
  type    = map(string)
  default = {}
}
