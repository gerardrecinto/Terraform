terraform {
  required_version = ">= 1.5"
  required_providers {
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

# MetalLB — bare-metal load balancer
resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = var.metallb_chart_version
  namespace        = "metallb-system"
  create_namespace = true

  set {
    name  = "speaker.frr.enabled"
    value = "false"
  }

  wait          = true
  wait_for_jobs = true
  timeout       = 180
}

resource "null_resource" "metallb_webhook_ready" {
  depends_on = [helm_release.metallb]

  provisioner "local-exec" {
    command = <<-EOF
      kubectl --kubeconfig=${var.kubeconfig_path} \\
        rollout status deployment/metallb-controller \\
        -n metallb-system --timeout=120s
    EOF
  }
}

resource "kubernetes_manifest" "ip_address_pool" {
  depends_on = [null_resource.metallb_webhook_ready]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "onprem-pool"
      namespace = "metallb-system"
    }
    spec = {
      addresses = var.metallb_ip_pool
    }
  }
}

resource "kubernetes_manifest" "l2_advertisement" {
  depends_on = [kubernetes_manifest.ip_address_pool]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "onprem-l2"
      namespace = "metallb-system"
    }
    spec = {
      ipAddressPools = ["onprem-pool"]
    }
  }
}

# NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_manifest.l2_advertisement]

  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_chart_version
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_ip
  }

  set {
    name  = "controller.replicaCount"
    value = tostring(var.ingress_replica_count)
  }

  set {
    name  = "controller.config.use-forwarded-headers"
    value = "\"true\""
  }

  set {
    name  = "controller.config.compute-full-forwarded-for"
    value = "\"true\""
  }

  wait    = true
  timeout = 180
}

# CoreDNS — patch upstream forwarders and search domains
resource "kubernetes_config_map_v1_data" "coredns_custom" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }

  data = {
    Corefile = templatefile("${path.module}/templates/Corefile.tpl", {
      upstream_dns   = var.upstream_dns_servers
      search_domains = var.internal_search_domains
      cluster_domain = var.cluster_domain
    })
  }

  force = true
}

resource "null_resource" "coredns_rollout" {
  depends_on = [kubernetes_config_map_v1_data.coredns_custom]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_path} rollout restart deployment/coredns -n kube-system"
  }
}
