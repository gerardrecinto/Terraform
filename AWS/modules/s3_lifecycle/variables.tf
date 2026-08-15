variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

# Prefix filter -- target specific log paths (e.g., "app-logs/")
variable "log_prefix" {
  type    = string
  default = ""
}

# Days in S3 Standard before moving to Standard-IA
variable "transition_to_ia_days" {
  type    = number
  default = 30
}

# Days in Standard-IA before archiving to Glacier Deep Archive
variable "transition_to_glacier_days" {
  type    = number
  default = 90
}

# Hard delete after N days -- set to 0 to disable
variable "expiration_days" {
  type    = number
  default = 0
}

# KMS key ARN for SSE-KMS; leave empty for SSE-S3
variable "kms_key_arn" {
  type    = string
  default = ""
}

# Explicit deny for non-HTTPS and non-KMS access
variable "enforce_encryption_policy" {
  type    = bool
  default = true
}

variable "replication_regions" {
  description = "Additional regions to replicate to (e.g., ap-south-1, eu-central-1)"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
