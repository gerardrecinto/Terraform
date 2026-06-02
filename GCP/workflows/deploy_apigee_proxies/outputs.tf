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
    device_service = "https://${var.api_hostname}/device_service/v1"
    package_service = "https://${var.api_hostname}/package_service/v1"
    inference_service    = "https://${var.api_hostname}/inference_service/v1"
  }
}

output "artifact_bucket" {
  value = module.apigee_artifacts.bucket_name
}
