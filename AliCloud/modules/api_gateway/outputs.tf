output "group_id" {
  value = alicloud_api_gateway_group.this.id
}

output "group_sub_domain" {
  value = alicloud_api_gateway_group.this.sub_domain
}

output "app_id" {
  value = alicloud_api_gateway_app.this.id
}

output "api_ids" {
  value = { for k, v in alicloud_api_gateway_api.routed : k => v.api_id }
}
