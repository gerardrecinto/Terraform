variable "ssh_user" {
  description = "SSH user terraform connects as to run provisioning commands on each node"
  type        = string
  default     = "deploy"
}

variable "ssh_private_key_path" {
  description = "Local path to the private key matching deploy_user_ssh_pubkey"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "kubeconfig_path" {
  type        = string
  description = "Local path where the cluster kubeconfig will be written after init."
  default     = "~/.kube/config"
}

variable "deploy_user" {
  description = "Unprivileged user created on each node for terraform/SSH-driven provisioning"
  type        = string
  default     = "deploy"
}

variable "deploy_user_ssh_pubkey" {
  type        = string
  description = "SSH public key installed for the deploy user on each node."
}

variable "ntp_servers" {
  description = "NTP servers each node syncs its clock against; clock skew breaks etcd and TLS certificate validation"
  type        = list(string)
  default     = ["PLACEHOLDER_NTP_1", "PLACEHOLDER_NTP_2"]
}

variable "ssh_allowed_users" {
  description = "Usernames allowed to authenticate over SSH; enforced by the security-hardening module"
  type        = list(string)
  default     = ["deploy"]
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR that may reach SSH (management network)."
}

variable "allowed_service_ports" {
  description = "Kubernetes control-plane and etcd ports (6443 API, 10250 kubelet, 2379/2380 etcd) opened between cluster nodes"
  type        = list(number)
  default     = [6443, 10250, 2379, 2380]
}

variable "control_plane_host" {
  description = "SSH-reachable address of the control-plane node terraform provisions"
  type        = string

  validation {
    condition     = length(var.control_plane_host) > 0
    error_message = "control_plane_host must not be empty."
  }
}

variable "control_plane_hostname" {
  description = "Hostname set on the control-plane node itself"
  type        = string

  validation {
    condition     = length(var.control_plane_hostname) > 0
    error_message = "control_plane_hostname must not be empty."
  }
}

variable "control_plane_endpoint" {
  type        = string
  description = "VIP or DNS name used as the kubeadm control-plane endpoint (host:port)."
}

variable "kubernetes_version" {
  description = "Kubernetes version kubeadm initializes the cluster with"
  type        = string

  validation {
    condition     = length(var.kubernetes_version) > 0
    error_message = "kubernetes_version must not be empty."
  }
}

variable "pod_cidr" {
  description = "CIDR block for pod IPs; must match the range the CNI plugin (Flannel by default) is configured for"
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrhost(var.pod_cidr, 0))
    error_message = "pod_cidr must be a valid CIDR block."
  }
}

variable "cni_manifest_url" {
  description = "URL of the CNI plugin manifest applied after cluster init"
  type        = string
  default     = "https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"
}

variable "worker_hosts" {
  description = "SSH-reachable addresses of worker nodes terraform provisions and joins to the cluster"
  type        = list(string)
}

variable "worker_hostnames" {
  description = "Hostnames set on each worker node, same order as worker_hosts"
  type        = list(string)
}

variable "metallb_ip_pool" {
  description = "CIDR ranges or individual IPs MetalLB hands out to LoadBalancer-type Services"
  type        = list(string)

  validation {
    condition     = length(var.metallb_ip_pool) > 0
    error_message = "metallb_ip_pool must contain at least one range or address."
  }
}

variable "ingress_ip" {
  description = "LoadBalancer IP (from metallb_ip_pool) the ingress controller Service is assigned"
  type        = string

  validation {
    condition     = length(var.ingress_ip) > 0
    error_message = "ingress_ip must not be empty."
  }
}

variable "upstream_dns_servers" {
  description = "DNS servers CoreDNS forwards non-cluster queries to"
  type        = list(string)

  validation {
    condition     = length(var.upstream_dns_servers) > 0
    error_message = "upstream_dns_servers must contain at least one server."
  }
}

variable "internal_search_domains" {
  description = "Search domains appended to CoreDNS's forwarding config for internal hostname resolution"
  type        = list(string)
  default     = []
}
