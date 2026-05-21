terraform {
  required_version = ">= 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# 1. Baseline + hardening on every node

module "baseline_controlplane" {
  source = "../../modules/server-baseline"

  host                   = var.control_plane_host
  hostname               = var.control_plane_hostname
  ssh_user               = var.ssh_user
  ssh_private_key_path   = var.ssh_private_key_path
  deploy_user            = var.deploy_user
  deploy_user_ssh_pubkey = var.deploy_user_ssh_pubkey
  ntp_servers            = var.ntp_servers
}

module "hardening_controlplane" {
  depends_on = [module.baseline_controlplane]
  source     = "../../modules/security-hardening"

  host                  = var.control_plane_host
  ssh_user              = var.ssh_user
  ssh_private_key_path  = var.ssh_private_key_path
  ssh_allowed_users     = var.ssh_allowed_users
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  allowed_service_ports = var.allowed_service_ports
}

module "baseline_workers" {
  for_each = { for i, h in var.worker_hosts : var.worker_hostnames[i] => h }
  source   = "../../modules/server-baseline"

  host                   = each.value
  hostname               = each.key
  ssh_user               = var.ssh_user
  ssh_private_key_path   = var.ssh_private_key_path
  deploy_user            = var.deploy_user
  deploy_user_ssh_pubkey = var.deploy_user_ssh_pubkey
  ntp_servers            = var.ntp_servers
}

module "hardening_workers" {
  depends_on = [module.baseline_workers]
  for_each   = { for i, h in var.worker_hosts : var.worker_hostnames[i] => h }
  source     = "../../modules/security-hardening"

  host                  = each.value
  ssh_user              = var.ssh_user
  ssh_private_key_path  = var.ssh_private_key_path
  ssh_allowed_users     = var.ssh_allowed_users
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  allowed_service_ports = var.allowed_service_ports
}

# 2. Control plane

module "controlplane" {
  depends_on = [module.hardening_controlplane]
  source     = "../../modules/k8s-controlplane"

  host                   = var.control_plane_host
  ssh_user               = var.ssh_user
  ssh_private_key_path   = var.ssh_private_key_path
  kubernetes_version     = var.kubernetes_version
  control_plane_endpoint = var.control_plane_endpoint
  pod_cidr               = var.pod_cidr
  cni_manifest_url       = var.cni_manifest_url
}

# 3. Worker nodes

module "workers" {
  depends_on = [module.controlplane]
  for_each   = { for i, h in var.worker_hosts : var.worker_hostnames[i] => h }
  source     = "../../modules/k8s-worker"

  host                 = each.value
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
  kubernetes_version   = var.kubernetes_version
  join_command         = module.controlplane.join_command
}

# 4. In-cluster networking (MetalLB + NGINX + CoreDNS)

module "networking" {
  depends_on = [module.workers]
  source     = "../../modules/networking"

  kubeconfig_path         = var.kubeconfig_path
  metallb_ip_pool         = var.metallb_ip_pool
  ingress_ip              = var.ingress_ip
  upstream_dns_servers    = var.upstream_dns_servers
  internal_search_domains = var.internal_search_domains
}
