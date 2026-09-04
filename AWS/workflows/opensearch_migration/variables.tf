variable "domain_name" {
  description = "Name of the destination OpenSearch domain"
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

variable "aws_region" {
  description = "AWS region the destination OpenSearch domain is provisioned in"
  type        = string
  default     = "us-west-2"
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
  description = "Number of data nodes in the destination domain"
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
  default     = 200

  validation {
    condition     = var.ebs_volume_size_gb > 0
    error_message = "ebs_volume_size_gb must be greater than zero."
  }
}

variable "vpc_id" {
  description = "VPC the destination domain's endpoint is provisioned in"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs the destination domain's endpoint attaches to"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
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

# Cognito resources (set false if user pool already exists)
variable "create_cognito_resources" {
  description = "Create a new Cognito user pool and identity pool for Dashboards SSO; set false to reuse existing ones"
  type        = bool
  default     = true
}

variable "cognito_user_pool_id" {
  description = "Existing Cognito user pool ID to reuse; required when create_cognito_resources is false"
  type        = string
  default     = ""
}

variable "cognito_identity_pool_id" {
  description = "Existing Cognito identity pool ID to reuse; required when create_cognito_resources is false"
  type        = string
  default     = ""
}

# Azure AD OIDC IDP
variable "azure_ad_client_id" {
  description = "Azure AD application (client) ID for federating Cognito to Azure AD OIDC"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_ad_client_secret" {
  description = "Azure AD application client secret for federating Cognito to Azure AD OIDC"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID the OIDC federation issuer belongs to"
  type        = string
  default     = ""
}
