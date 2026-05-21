variable "control_plane_host" {
  type        = string
  description = "IP or hostname of the control plane node"
}

variable "worker_hosts" {
  type        = list(string)
  description = "Worker node IPs in the order they should be upgraded"
}

variable "worker_node_names" {
  type        = list(string)
  description = "Kubernetes node names — same order as worker_hosts"
}

variable "ssh_user" {
  type        = string
  description = "SSH user with sudo access on all nodes"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Absolute path to the SSH private key"
}

variable "target_kubernetes_version" {
  type        = string
  description = "Full target version string (e.g. 1.29.4)"
}

variable "kubeconfig_path" {
  type        = string
  description = "Local path to the cluster kubeconfig"
  default     = "~/.kube/config"
}
