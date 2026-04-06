output "apigee_org_id" {
  value = module.apigee.org_id
}

output "api_base_url" {
  value = "https://${var.api_hostname}"
}

output "deployed_proxies" {
  value = module.apigee.deployed_proxies
}

output "proxy_endpoints" {
  value = {
    devicecloud   = "https://${var.api_hostname}/devicecloud/v1"
    softwarehub   = "https://${var.api_hostname}/softwarehub/v1"
    modelhub = "https://${var.api_hostname}/modelhub/v1"
  }
}

output "artifact_bucket" {
  value = module.apigee_artifacts.bucket_name
}
