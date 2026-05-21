variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster."
}

variable "metallb_chart_version" {
  type        = string
  default     = "0.14.5"
  description = "MetalLB Helm chart version."
}

variable "metallb_ip_pool" {
  type        = list(string)
  description = "CIDR ranges or explicit IP ranges assigned to the MetalLB pool (e.g. [\"10.0.10.100-10.0.10.150\"])."
}

variable "ingress_ip" {
  type        = string
  description = "Fixed IP from the MetalLB pool reserved for the NGINX ingress LoadBalancer service."
}

variable "nginx_chart_version" {
  type        = string
  default     = "4.10.1"
  description = "NGINX Ingress Controller Helm chart version."
}

variable "ingress_replica_count" {
  type        = number
  default     = 2
  description = "Number of NGINX controller replicas."
}

variable "upstream_dns_servers" {
  type        = list(string)
  description = "On-prem recursive DNS servers CoreDNS forwards to."
}

variable "internal_search_domains" {
  type        = list(string)
  default     = []
  description = "Internal DNS search domains to add to CoreDNS stub zones."
}

variable "cluster_domain" {
  type        = string
  default     = "cluster.local"
  description = "Kubernetes cluster DNS domain."
}
