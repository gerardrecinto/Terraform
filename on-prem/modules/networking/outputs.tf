output "ingress_ip" {
  description = "IP address assigned to the NGINX ingress LoadBalancer service."
  value       = var.ingress_ip
}

output "metallb_pool" {
  description = "MetalLB IP pool CIDR/range configured for this cluster."
  value       = var.metallb_ip_pool
}
