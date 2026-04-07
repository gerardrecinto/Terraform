output "ingress_class_name" {
  description = "Ingress class name to use in Ingress resources targeting this controller."
  value       = "nginx"
}

output "namespace" {
  description = "Kubernetes namespace where the NGINX ingress controller is deployed."
  value       = var.namespace
}

output "helm_release_name" {
  description = "Name of the Helm release managing the NGINX ingress controller."
  value       = helm_release.nginx_ingress.name
}

output "helm_release_version" {
  description = "Chart version of the deployed NGINX ingress controller."
  value       = helm_release.nginx_ingress.version
}

output "tcp_services_configmap_name" {
  description = "Name of the ConfigMap mapping external NLB ports (22, 443) to internal Kubernetes services."
  value       = kubernetes_config_map.tcp_services.metadata[0].name
}

output "ssh_adb_target_group_arn" {
  description = "ARN of the NLB target group for SSH/ADB gateway pods (port 22). Null when dynamic_pod_targeting = false."
  value       = var.dynamic_pod_targeting ? aws_lb_target_group.ssh_adb[0].arn : null
}

output "device_streaming_target_group_arn" {
  description = "ARN of the NLB target group for device streaming pods (port 443). Null when dynamic_pod_targeting = false."
  value       = var.dynamic_pod_targeting ? aws_lb_target_group.device_streaming[0].arn : null
}

output "ssh_adb_registered_pod_ips" {
  description = "Set of pod IPs currently registered as SSH/ADB NLB targets. Updates on every terraform apply."
  value = var.dynamic_pod_targeting ? toset([
    for att in aws_lb_target_group_attachment.ssh_adb_pods : att.target_id
  ]) : toset([])
}

output "device_streaming_registered_pod_ips" {
  description = "Set of pod IPs currently registered as device streaming NLB targets. Updates on every terraform apply."
  value = var.dynamic_pod_targeting ? toset([
    for att in aws_lb_target_group_attachment.device_streaming_pods : att.target_id
  ]) : toset([])
}
