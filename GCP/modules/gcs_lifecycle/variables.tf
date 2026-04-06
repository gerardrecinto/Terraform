variable "project_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "location" {
  type    = string
  default = "US"
}

variable "environment" {
  type = string
}

variable "object_prefix" {
  type    = string
  default = ""
}

variable "transition_to_nearline_days" {
  type    = number
  default = 30
}

variable "transition_to_coldline_days" {
  type    = number
  default = 90
}

variable "transition_to_archive_days" {
  type    = number
  default = 365
}

variable "expiration_days" {
  type    = number
  default = 0
}

variable "kms_key_name" {
  type    = string
  default = ""
}

variable "labels" {
  type    = map(string)
  default = {}
}
