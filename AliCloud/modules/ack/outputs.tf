output "cluster_id" {
  value = alicloud_cs_managed_kubernetes.this.id
}

output "cluster_name" {
  value = alicloud_cs_managed_kubernetes.this.name
}

output "connections" {
  value     = alicloud_cs_managed_kubernetes.this.connections
  sensitive = true
}

output "node_role_arn" {
  value = alicloud_ram_role.node.arn
}

output "node_pool_ids" {
  value = { for k, v in alicloud_cs_kubernetes_node_pool.pools : k => v.id }
}
