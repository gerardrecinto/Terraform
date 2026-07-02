variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "environment" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "latest"
}

variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type = string
}

# Secondary ranges for pods and services (required for VPC-native clusters)
variable "pods_range_name" {
  type    = string
  default = "pods"
}

variable "services_range_name" {
  type    = string
  default = "services"
}

variable "node_pools" {
  type = map(object({
    machine_type  = string
    min_count     = number
    max_count     = number
    initial_count = number
    disk_size_gb  = number
    disk_type     = string
    preemptible   = bool
    spot          = bool
    labels        = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {}
}

# Workload Identity -- maps K8s service accounts to GCP service accounts
variable "workload_identity_enabled" {
  type    = bool
  default = true
}

# Private cluster -- nodes have no public IPs
variable "private_cluster" {
  type    = bool
  default = true
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

# Authorized networks for master API access
variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
