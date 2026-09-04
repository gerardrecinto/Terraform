variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); sizes the master count and drives resource naming"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "external_network_id" {
  description = "ID of the external (floating IP) network the Magnum cluster's master load balancer attaches to"
  type        = string

  validation {
    condition     = length(var.external_network_id) > 0
    error_message = "external_network_id must not be empty."
  }
}

variable "keypair_name" {
  description = "Nova keypair injected into cluster nodes for emergency SSH access"
  type        = string

  validation {
    condition     = length(var.keypair_name) > 0
    error_message = "keypair_name must not be empty."
  }
}

variable "vip_subnet_id" {
  description = "Subnet the ingress load balancer's virtual IP is allocated from"
  type        = string

  validation {
    condition     = length(var.vip_subnet_id) > 0
    error_message = "vip_subnet_id must not be empty."
  }
}

variable "member_subnet_id" {
  description = "Subnet the ingress load balancer's backend members are reachable on"
  type        = string

  validation {
    condition     = length(var.member_subnet_id) > 0
    error_message = "member_subnet_id must not be empty."
  }
}

variable "tls_container_ref" {
  description = "Barbican secret container ref holding the ingress TLS certificate/key pair"
  type        = string
}

variable "ingress_node_addresses" {
  description = "Addresses of the Magnum worker nodes running the in-cluster ingress controller; one load balancer member is created per address"
  type        = list(string)
  default     = []
}
