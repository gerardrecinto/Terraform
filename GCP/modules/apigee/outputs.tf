output "org_id" {
  value = google_apigee_organization.this.id
}

output "environment_name" {
  value = google_apigee_environment.this.name
}

output "envgroup_hostname" {
  value = var.apigee_env_group_hostname
}

output "instance_host" {
  value = google_apigee_instance.this.host
}

output "proxy_service_account_email" {
  value = google_service_account.apigee_proxy.email
}

output "deployed_proxies" {
  value = keys(google_apigee_api_deployment.proxies)
}
