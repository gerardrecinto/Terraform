variable "domain_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
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
  default = 200
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

# Cognito resources (set false if user pool already exists)
variable "create_cognito_resources" {
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

# Azure AD OIDC IDP
variable "azure_ad_client_id" {
  type      = string
  sensitive = true
  default   = ""
}

variable "azure_ad_client_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "azure_tenant_id" {
  type    = string
  default = ""
}
