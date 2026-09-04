variable "project_id" {
  description = "GCP project ID the cluster is created in"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "cluster_name" {
  description = "Name of the GKE cluster and its node service account"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "region" {
  description = "GCP region for the cluster's control plane and node pools"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource labels"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes minor version to pin the control plane to; \"latest\" tracks the release channel's current default"
  type        = string
  default     = "latest"
}

variable "network" {
  description = "VPC network the cluster is created in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork the cluster's nodes attach to; must have secondary ranges named by pods_range_name and services_range_name"
  type        = string

  validation {
    condition     = length(var.subnetwork) > 0
    error_message = "subnetwork must not be empty."
  }
}

variable "pods_range_name" {
  description = "Name of the subnetwork's secondary range used for pod alias IPs (VPC-native networking)"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name of the subnetwork's secondary range used for Service cluster IPs (VPC-native networking)"
  type        = string
  default     = "services"
}

variable "node_pools" {
  description = "Map of node pool name to its instance sizing, autoscaling bounds, and optional taints"
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

variable "workload_identity_enabled" {
  description = "Whether pods can assume GCP service accounts via a Kubernetes service account annotation, instead of node-wide credentials"
  type        = bool
  default     = true
}

variable "private_cluster" {
  description = "Whether nodes get only private IPs (no direct internet-routable address)"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the control plane's private endpoint; must be a /28 not overlapping the cluster's other ranges"
  type        = string
  default     = "172.16.0.0/28"

  validation {
    condition     = can(cidrhost(var.master_ipv4_cidr_block, 0))
    error_message = "master_ipv4_cidr_block must be a valid CIDR block."
  }
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the control plane's API endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "tags" {
  description = "Additional resource labels merged with the environment and terraform-managed labels"
  type        = map(string)
  default     = {}
}
