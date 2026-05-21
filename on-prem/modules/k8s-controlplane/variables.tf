variable "host" {
  type        = string
  description = "IP or hostname of the control plane node"
}

variable "ssh_user" {
  type        = string
  description = "SSH user with sudo access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Absolute path to the SSH private key"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes minor version (e.g. 1.29)"
  default     = "1.29"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR block for pod networking"
  default     = "192.168.0.0/16"
}

variable "control_plane_endpoint" {
  type        = string
  description = "Stable API server endpoint — VIP or load balancer (host:port)"
}

variable "cni_manifest_url" {
  type        = string
  description = "URL to the CNI plugin manifest"
  default     = "https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml"
}
