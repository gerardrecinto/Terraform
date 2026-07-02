variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

# OIDC IDP for federated auth (Azure AD, Okta, etc.)
variable "oidc_issuer_url" {
  type    = string
  default = ""
}

# CNI custom networking -- 100-series subnets to avoid exhaustion in large clusters
variable "cni_custom_networking_enabled" {
  type    = bool
  default = true
}

variable "eni_config_subnets" {
  description = "Secondary subnets for VPC CNI eniconfigs (100.x.x.x range)"
  type        = map(string) # az -> subnet_id
  default     = {}
}

variable "linux_node_groups" {
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
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
