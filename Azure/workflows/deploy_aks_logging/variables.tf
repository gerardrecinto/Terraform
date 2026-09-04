variable "subscription_id" {
  description = "Azure subscription ID the AKS cluster and logging pipeline are provisioned in"
  type        = string

  validation {
    condition     = length(var.subscription_id) > 0
    error_message = "subscription_id must not be empty."
  }
}

variable "project_name" {
  description = "Naming prefix applied to the AKS cluster and its logging pipeline resources"
  type        = string
  default     = "iot-platform"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region the AKS cluster and logging pipeline are created in"
  type        = string
  default     = "westus2"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the AKS control plane"
  type        = string
  default     = "1.29"
}

variable "azure_ad_tenant_id" {
  description = "Azure AD tenant ID used for Azure AD-integrated cluster RBAC"
  type        = string

  validation {
    condition     = length(var.azure_ad_tenant_id) > 0
    error_message = "azure_ad_tenant_id must not be empty."
  }
}
