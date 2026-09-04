output "cluster_api_address" {
  value = module.k8s.api_address
}

output "backup_container_name" {
  value = module.backup_storage.container_name
}

output "ingress_vip_address" {
  value = module.ingress.vip_address
}
