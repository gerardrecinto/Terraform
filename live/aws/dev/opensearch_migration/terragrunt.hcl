include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/AWS//workflows/opensearch_migration"
}

inputs = {
  domain_name    = "platform-dev-search"
  environment    = include.root.locals.environment
  aws_region     = "us-west-2"
  instance_count = 2

  vpc_id     = "vpc-dev0000000000000000"
  subnet_ids = ["subnet-dev0000000000001", "subnet-dev0000000000002"]

  create_cognito_resources = true
  azure_tenant_id          = "00000000-0000-0000-0000-000000000dev"
}
