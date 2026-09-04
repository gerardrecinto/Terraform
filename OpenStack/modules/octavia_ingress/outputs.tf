output "loadbalancer_id" {
  value = openstack_lb_loadbalancer_v2.this.id
}

output "vip_address" {
  value = openstack_lb_loadbalancer_v2.this.vip_address
}

output "pool_id" {
  value = openstack_lb_pool_v2.backend.id
}
