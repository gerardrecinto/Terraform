variable "project_id" {
  description = "GCP project ID the Apigee organization and its runtime resources are provisioned in"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "org_id" {
  description = "Apigee organization ID (usually same as GCP project ID)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "GCP region for the Apigee instance and its VPC peering range"
  type        = string
  default     = "us-central1"
}

variable "apigee_env_name" {
  description = "Apigee environment name (e.g. \"prod\", \"dev\") that proxies are deployed into"
  type        = string
}

variable "apigee_env_group_hostname" {
  description = "External-facing hostname routed to this Apigee environment group (e.g. \"api.example.com\")"
  type        = string
}

variable "api_proxies" {
  description = "Map of proxy name to its config; each entry becomes one Apigee API proxy. token_auth_enabled validates the Bearer token via a JS policy before forwarding, path_routes maps a path prefix to a backend URL override"
  type = map(object({
    display_name       = string
    description        = string
    base_path          = string
    target_url         = string
    token_auth_enabled = bool
    path_routes        = map(string)
  }))
  default = {}
}

variable "token_validation_url" {
  description = "OAuth2/API key introspection endpoint used by the JS token-auth policy; required when any proxy has token_auth_enabled"
  type        = string
  default     = ""
}

variable "vpc_network_name" {
  description = "VPC network the Apigee managed instance peers with"
  type        = string
  default     = "default"
}

variable "vpc_peering_cidr" {
  description = "CIDR range for Apigee managed VPC peering"
  type        = string
  default     = "10.0.0.0/22"

  validation {
    condition     = can(cidrhost(var.vpc_peering_cidr, 0))
    error_message = "vpc_peering_cidr must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
