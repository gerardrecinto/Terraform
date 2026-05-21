variable "ssh_user" {
  type    = string
  default = "deploy"
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519"
}

variable "kubeconfig_path" {
  type        = string
  description = "Local path where the cluster kubeconfig will be written after init."
  default     = "~/.kube/config"
}

variable "deploy_user" {
  type    = string
  default = "deploy"
}

variable "deploy_user_ssh_pubkey" {
  type        = string
  description = "SSH public key installed for the deploy user on each node."
}

variable "ntp_servers" {
  type    = list(string)
  default = ["PLACEHOLDER_NTP_1", "PLACEHOLDER_NTP_2"]
}

variable "ssh_allowed_users" {
  type    = list(string)
  default = ["deploy"]
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR that may reach SSH (management network)."
}

variable "allowed_service_ports" {
  type    = list(number)
  default = [6443, 10250, 2379, 2380]
}

variable "control_plane_host" {
  type = string
}

variable "control_plane_hostname" {
  type = string
}

variable "control_plane_endpoint" {
  type        = string
  description = "VIP or DNS name used as the kubeadm control-plane endpoint (host:port)."
}

variable "kubernetes_version" {
  type = string
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "cni_manifest_url" {
  type    = string
  default = "https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"
}

variable "worker_hosts" {
  type = list(string)
}

variable "worker_hostnames" {
  type = list(string)
}

variable "metallb_ip_pool" {
  type = list(string)
}

variable "ingress_ip" {
  type = string
}

variable "upstream_dns_servers" {
  type = list(string)
}

variable "internal_search_domains" {
  type    = list(string)
  default = []
}
