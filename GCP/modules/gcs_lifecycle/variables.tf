variable "project_id" {
  description = "GCP project ID the bucket is created in"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "bucket_name" {
  description = "Globally unique GCS bucket name"
  type        = string

  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "bucket_name must not be empty."
  }
}

variable "location" {
  description = "GCS bucket location: a region (e.g. \"us-central1\") or a multi-region (e.g. \"US\")"
  type        = string
  default     = "US"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into bucket labels"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "object_prefix" {
  description = "Key prefix the lifecycle rules apply to; empty string applies them to the whole bucket"
  type        = string
  default     = ""
}

variable "transition_to_nearline_days" {
  description = "Days after object creation before transitioning to Nearline storage"
  type        = number
  default     = 30

  validation {
    condition     = var.transition_to_nearline_days >= 0
    error_message = "transition_to_nearline_days must be zero or greater."
  }
}

variable "transition_to_coldline_days" {
  description = "Days after object creation before transitioning to Coldline storage; must exceed transition_to_nearline_days"
  type        = number
  default     = 90

  validation {
    condition     = var.transition_to_coldline_days >= 0
    error_message = "transition_to_coldline_days must be zero or greater."
  }
}

variable "transition_to_archive_days" {
  description = "Days after object creation before transitioning to Archive storage; must exceed transition_to_coldline_days"
  type        = number
  default     = 365

  validation {
    condition     = var.transition_to_archive_days >= 0
    error_message = "transition_to_archive_days must be zero or greater."
  }
}

variable "expiration_days" {
  description = "Days after object creation before permanent deletion; 0 disables the expiration rule entirely"
  type        = number
  default     = 0

  validation {
    condition     = var.expiration_days >= 0
    error_message = "expiration_days must be zero or greater (0 disables expiration)."
  }
}

variable "kms_key_name" {
  description = "CMEK key name for bucket default encryption; empty string uses Google-managed encryption"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Additional bucket labels merged with the environment and terraform-managed labels"
  type        = map(string)
  default     = {}
}
