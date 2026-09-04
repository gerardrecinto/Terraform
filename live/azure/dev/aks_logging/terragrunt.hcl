include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/Azure//workflows/deploy_aks_logging"
}

inputs = {
  subscription_id    = "00000000-0000-0000-0000-000000000dev"
  project_name       = "iot-platform"
  environment        = include.root.locals.environment
  location           = "westus2"
  azure_ad_tenant_id = "00000000-0000-0000-0000-000000000ten"
}
