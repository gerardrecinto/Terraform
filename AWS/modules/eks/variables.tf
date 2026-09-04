variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "cluster_version" {
  description = "Kubernetes minor version for the EKS control plane"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC the cluster's control plane ENIs and node groups are provisioned in"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs the control plane and node groups attach to; must span at least two availability zones"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids must contain at least two subnets across separate availability zones."
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
  description = "AWS region the cluster is provisioned in"
  type        = string
  default     = "us-west-2"
}

variable "oidc_issuer_url" {
  description = "OIDC IDP issuer URL for federated auth (Azure AD, Okta, etc.); empty string skips federated auth setup"
  type        = string
  default     = ""
}

variable "cni_custom_networking_enabled" {
  description = "CNI custom networking -- 100-series subnets to avoid IP exhaustion in large clusters"
  type        = bool
  default     = true
}

variable "eni_config_subnets" {
  description = "Secondary subnets for VPC CNI eniconfigs (100.x.x.x range), keyed by availability zone"
  type        = map(string) # az -> subnet_id
  default     = {}
}

variable "linux_node_groups" {
  description = "Map of Linux node group name to its instance types, autoscaling bounds, capacity type (ON_DEMAND or SPOT), labels, and taints"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = string # ON_DEMAND or SPOT
    labels         = map(string)
    taints         = list(object({ key = string, value = string, effect = string }))
  }))
  default = {}
}

variable "windows_node_groups" {
  description = "Map of Windows node group name to its instance types and autoscaling bounds"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
  default = {}
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
