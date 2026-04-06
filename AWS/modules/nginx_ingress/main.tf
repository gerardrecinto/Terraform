# NOTE: Published as supporting evidence for skills on resume.
# All company-specific values (account IDs, hostnames, ARNs, CIDRs, resource names)
# have been replaced with generic placeholders to preserve company CCI.
# NGINX Ingress module with NLB and TCP passthrough
# Covers DeviceService SSH Gateway: port 22 TCP ingress for Snapdragon device SSH sessions
# NLB used for L4 passthrough; NGINX handles TCP stream proxying
# Cross-account traffic comes in via PrivateLink -> NLB -> NGINX -> pod

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

locals {
  nlb_annotations = merge({
    "service.beta.kubernetes.io/aws-load-balancer-type"                            = "external"
    "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"                 = "ip"
    "service.beta.kubernetes.io/aws-load-balancer-scheme"                          = var.nlb_internal ? "internal" : "internet-facing"
    "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = tostring(var.nlb_cross_zone_enabled)
    "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                = "tcp"
  }, var.extra_annotations)
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.1"
  namespace        = var.namespace
  create_namespace = true

  values = [yamlencode({
    controller = {
      replicaCount = var.replicas

      # TCP services config map -- enables port 22 and other TCP ports through NGINX
      tcp = var.tcp_services

      service = {
        type        = "LoadBalancer"
        annotations = local.nlb_annotations
        externalTrafficPolicy = "Local"  # preserve source IP for SSH/WebSocket

        # Expose TCP ports on the NLB for SSH and WebSocket
        ports = merge(
          { http = 80, https = 443 },
          { for port, _ in var.tcp_services : port => tonumber(port) }
        )
      }

      config = {
        # Allow large WebSocket frames and long-lived SSH connections
        "proxy-read-timeout"  = "3600"
        "proxy-send-timeout"  = "3600"
        "proxy-body-size"     = "100m"
        # Required for WebSocket upgrade
        "use-forwarded-headers" = "true"
        # Security headers
        "add-headers"           = "${var.namespace}/custom-headers"
      }

      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }

      # Spread across nodes -- don't co-locate ingress pods
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [{
            labelSelector = {
              matchExpressions = [{
                key      = "app.kubernetes.io/component"
                operator = "In"
                values   = ["controller"]
              }]
            }
            topologyKey = "kubernetes.io/hostname"
          }]
        }
      }

      metrics = {
        enabled = true
        serviceMonitor = { enabled = true }
      }
    }
  })]
}

# ConfigMap for security headers (AppSec requirements: X-Frame-Options, CSP, etc.)
resource "kubernetes_config_map" "security_headers" {
  metadata {
    name      = "custom-headers"
    namespace = var.namespace
  }

  data = {
    "X-Frame-Options"        = "SAMEORIGIN"
    "X-Content-Type-Options" = "nosniff"
    "X-XSS-Protection"       = "1; mode=block"
    "Referrer-Policy"        = "strict-origin-when-cross-origin"
    "Content-Security-Policy" = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains"
  }

  depends_on = [helm_release.nginx_ingress]
}
