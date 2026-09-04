output "bucket_name" {
  value = alicloud_oss_bucket.this.bucket
}

output "bucket_id" {
  value = alicloud_oss_bucket.this.id
}

output "extranet_endpoint" {
  value = alicloud_oss_bucket.this.extranet_endpoint
}

output "intranet_endpoint" {
  value = alicloud_oss_bucket.this.intranet_endpoint
}
