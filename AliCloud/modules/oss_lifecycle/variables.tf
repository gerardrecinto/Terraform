variable "bucket_name" {
  description = "Globally unique OSS bucket name"
  type        = string

  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "bucket_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "object_prefix" {
  description = "Key prefix the lifecycle rule applies to; empty string applies it to the whole bucket"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Whether to keep prior versions of overwritten or deleted objects"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for server-side encryption; empty string falls back to bucket-managed AES256"
  type        = string
  default     = ""
}

variable "access_log_bucket" {
  description = "Bucket to write access logs to; empty string logs to this bucket itself"
  type        = string
  default     = ""
}

variable "transition_to_ia_days" {
  description = "Days after object creation before transitioning to Infrequent Access storage"
  type        = number
  default     = 30

  validation {
    condition     = var.transition_to_ia_days >= 0
    error_message = "transition_to_ia_days must be zero or greater."
  }
}

variable "transition_to_archive_days" {
  description = "Days after object creation before transitioning to Archive storage; must exceed transition_to_ia_days"
  type        = number
  default     = 90

  validation {
    condition     = var.transition_to_archive_days >= 0
    error_message = "transition_to_archive_days must be zero or greater."
  }
}

variable "transition_to_cold_archive_days" {
  description = "Days after object creation before transitioning to Cold Archive storage; must exceed transition_to_archive_days"
  type        = number
  default     = 180

  validation {
    condition     = var.transition_to_cold_archive_days >= 0
    error_message = "transition_to_cold_archive_days must be zero or greater."
  }
}

variable "expiration_days" {
  description = "Days after object creation before the object is permanently deleted"
  type        = number
  default     = 365

  validation {
    condition     = var.expiration_days > 0
    error_message = "expiration_days must be greater than zero."
  }
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
