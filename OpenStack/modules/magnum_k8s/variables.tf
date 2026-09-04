variable "cluster_name" {
  description = "Name of the Magnum cluster and its cluster template"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into cluster labels"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "cluster_image" {
  description = "Fedora CoreOS or Ubuntu image name registered in Glance with a Magnum-compatible driver"
  type        = string
  default     = "fedora-coreos-stable"
}

variable "master_flavor" {
  description = "Nova flavor for master (control plane) nodes"
  type        = string
  default     = "m1.large"
}

variable "node_flavor" {
  description = "Nova flavor for worker nodes"
  type        = string
  default     = "m1.xlarge"
}

variable "external_network_id" {
  description = "ID of the external (floating IP) network the cluster's master load balancer attaches to"
  type        = string

  validation {
    condition     = length(var.external_network_id) > 0
    error_message = "external_network_id must not be empty."
  }
}

variable "dns_nameserver" {
  description = "DNS nameserver configured on cluster nodes"
  type        = string
  default     = "8.8.8.8"
}

variable "kubernetes_version" {
  description = "Kubernetes version label applied to the cluster template (kube_tag)"
  type        = string
  default     = "v1.30.1"
}

variable "availability_zone" {
  description = "Nova availability zone for cluster nodes"
  type        = string
  default     = "nova"
}

variable "master_count" {
  description = "Number of master (control plane) nodes; use an odd number for etcd quorum"
  type        = number
  default     = 3

  validation {
    condition     = var.master_count > 0 && var.master_count % 2 == 1
    error_message = "master_count must be a positive odd number for etcd quorum."
  }
}

variable "initial_node_count" {
  description = "Number of worker nodes to create at cluster creation time"
  type        = number
  default     = 3

  validation {
    condition     = var.initial_node_count >= 0
    error_message = "initial_node_count must be zero or greater."
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
