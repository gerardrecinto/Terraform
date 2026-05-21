variable "host" {
  type        = string
  description = "IP or hostname of the worker node"
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
  description = "Kubernetes minor version — must match control plane"
  default     = "1.29"
}

variable "join_command" {
  type        = string
  description = "Full kubeadm join command from the control plane"
  sensitive   = true
}
