include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/AliCloud//workflows/deploy_ack"
}

inputs = {
  region      = "cn-hangzhou"
  environment = include.root.locals.environment

  vpc_id      = "vpc-prod0000000000000000"
  vswitch_ids = ["vsw-prod00000000000001", "vsw-prod00000000000002", "vsw-prod00000000000003"]
}
