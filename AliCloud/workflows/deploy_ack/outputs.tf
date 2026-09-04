output "cluster_id" {
  value = module.ack.cluster_id
}

output "log_bucket_name" {
  value = module.log_bucket.bucket_name
}

output "internal_api_domain" {
  value = module.internal_api.group_sub_domain
}
