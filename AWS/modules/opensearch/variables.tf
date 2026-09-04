variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string

  validation {
    condition     = length(var.domain_name) > 0
    error_message = "domain_name must not be empty."
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

variable "engine_version" {
  description = "OpenSearch engine version string (e.g. \"OpenSearch_2.13\")"
  type        = string
  default     = "OpenSearch_2.13"
}

variable "instance_type" {
  description = "Instance type for data nodes"
  type        = string
  default     = "r6g.large.search"
}

variable "instance_count" {
  description = "Number of data nodes in the domain"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count > 0
    error_message = "instance_count must be greater than zero."
  }
}

variable "ebs_volume_size_gb" {
  description = "EBS volume size in GB attached to each data node"
  type        = number
  default     = 100

  validation {
    condition     = var.ebs_volume_size_gb > 0
    error_message = "ebs_volume_size_gb must be greater than zero."
  }
}

variable "vpc_id" {
  description = "VPC the domain's endpoint is provisioned in"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs the domain's endpoint attaches to"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

# OIDC / Cognito SSO -- used for migrating on-prem ES to AWS OpenSearch with Azure AD auth
variable "cognito_enabled" {
  description = "Enable Cognito-backed SSO for OpenSearch Dashboards"
  type        = bool
  default     = true
}

variable "cognito_user_pool_id" {
  description = "Cognito user pool ID; required when cognito_enabled is true"
  type        = string
  default     = ""
}

variable "cognito_identity_pool_id" {
  description = "Cognito identity pool ID; required when cognito_enabled is true"
  type        = string
  default     = ""
}

# SAML for Azure AD federation (alternative to Cognito)
variable "saml_enabled" {
  description = "Enable SAML-based SSO via Azure AD federation, as an alternative to Cognito"
  type        = bool
  default     = false
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
  description = "KMS key ARN for encryption at rest; empty string uses the AWS-managed OpenSearch key"
  type        = string
  default     = ""
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the domain's endpoint via its resource-based access policy"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
