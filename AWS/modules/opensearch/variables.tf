variable "domain_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "OpenSearch_2.13"
}

variable "instance_type" {
  type    = string
  default = "r6g.large.search"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "ebs_volume_size_gb" {
  type    = number
  default = 100
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

# OIDC / Cognito SSO -- used for migrating on-prem ES to AWS OpenSearch with Azure AD auth
variable "cognito_enabled" {
  type    = bool
  default = true
}

variable "cognito_user_pool_id" {
  type    = string
  default = ""
}

variable "cognito_identity_pool_id" {
  type    = string
  default = ""
}

# SAML for Azure AD federation (alternative to Cognito)
variable "saml_enabled" {
  type    = bool
  default = false
}

variable "saml_metadata_content" {
  description = "Raw XML metadata from Azure AD enterprise app"
  type        = string
  default     = ""
}

variable "saml_master_backend_role" {
  description = "Azure AD group object ID to map to OpenSearch admin role"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
