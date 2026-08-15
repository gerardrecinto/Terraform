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
    device_api    = "https://${var.api_hostname}/device-api/v1"
    package_api   = "https://${var.api_hostname}/package-api/v1"
    inference_api = "https://${var.api_hostname}/inference-api/v1"
  }
}

output "artifact_bucket" {
  value = module.apigee_artifacts.bucket_name
}
