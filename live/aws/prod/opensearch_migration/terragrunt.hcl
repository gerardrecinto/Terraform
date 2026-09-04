include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/AWS//workflows/opensearch_migration"
}

inputs = {
  domain_name    = "platform-prod-search"
  environment    = include.root.locals.environment
  aws_region     = "us-west-2"
  instance_count = 3

  vpc_id     = "vpc-prod0000000000000000"
  subnet_ids = ["subnet-prod0000000000001", "subnet-prod0000000000002", "subnet-prod0000000000003"]

  create_cognito_resources = true
  azure_tenant_id          = "00000000-0000-0000-0000-000000000prd"
}
