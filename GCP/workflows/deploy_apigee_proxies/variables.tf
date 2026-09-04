variable "project_id" {
  description = "GCP project ID the Apigee organization and its runtime resources are provisioned in"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); used as the Apigee environment name and merged into resource tags"
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

variable "api_hostname" {
  description = "External hostname for the Apigee environment group (e.g., api.example.com)"
  type        = string
}

variable "token_validation_url" {
  description = "Token introspection endpoint -- JS policy validates Bearer tokens here"
  type        = string
  sensitive   = true
}

variable "vpc_network" {
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

# Backend host for each proxy (internal service URLs)
variable "device_api_backend_host" {
  description = "Internal service host the device-api proxy forwards requests to"
  type        = string
  sensitive   = true
}

variable "package_api_backend_host" {
  description = "Internal service host the package-api proxy forwards requests to"
  type        = string
  sensitive   = true
}

variable "inference_api_backend_host" {
  description = "Internal service host the inference-api proxy forwards requests to"
  type        = string
  sensitive   = true
}
