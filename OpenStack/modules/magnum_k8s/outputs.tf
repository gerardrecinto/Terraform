output "cluster_id" {
  value = openstack_containerinfra_cluster_v1.this.id
}

output "cluster_template_id" {
  value = openstack_containerinfra_clustertemplate_v1.this.id
}

output "api_address" {
  value = openstack_containerinfra_cluster_v1.this.api_address
}

output "master_addresses" {
  value = openstack_containerinfra_cluster_v1.this.master_addresses
}
