include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/GCP//workflows/deploy_apigee_proxies"
}

inputs = {
  project_id  = "example-platform-prod"
  environment = include.root.locals.environment
  region      = "us-central1"

  api_hostname         = "api.example.internal"
  token_validation_url = "https://auth.example.internal/oauth2/introspect"

  device_api_backend_host    = "device-api.example.internal"
  package_api_backend_host   = "package-api.example.internal"
  inference_api_backend_host = "inference-api.example.internal"
}
