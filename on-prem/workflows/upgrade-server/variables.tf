variable "host" {
  type        = string
  description = "IP or hostname of the server to upgrade"
}

variable "ssh_user" {
  type        = string
  description = "SSH user with sudo access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Absolute path to the SSH private key"
}

variable "k8s_node_name" {
  type        = string
  description = "Kubernetes node name — set to empty string if this is not a K8s node"
  default     = ""
}

variable "kubeconfig_path" {
  type        = string
  description = "Local kubeconfig path, used only when k8s_node_name is set"
  default     = "~/.kube/config"
}

variable "reboot_if_required" {
  type        = bool
  description = "Reboot when /var/run/reboot-required is present after upgrade"
  default     = true
}

variable "reboot_wait_seconds" {
  type        = number
  description = "Seconds to wait after issuing a reboot before running post-upgrade checks"
  default     = 90
}
