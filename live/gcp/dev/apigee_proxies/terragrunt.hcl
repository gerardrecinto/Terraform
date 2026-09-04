include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/GCP//workflows/deploy_apigee_proxies"
}

inputs = {
  project_id  = "example-platform-dev"
  environment = include.root.locals.environment
  region      = "us-central1"

  api_hostname         = "api-dev.example.internal"
  token_validation_url = "https://auth-dev.example.internal/oauth2/introspect"

  device_api_backend_host    = "device-api-dev.example.internal"
  package_api_backend_host   = "package-api-dev.example.internal"
  inference_api_backend_host = "inference-api-dev.example.internal"
}
