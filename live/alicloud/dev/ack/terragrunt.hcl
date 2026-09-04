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

  # Dev VPC -- separate from prod so a bad node pool change can't take out
  # anything real
  vpc_id      = "vpc-dev0000000000000000"
  vswitch_ids = ["vsw-dev00000000000001", "vsw-dev00000000000002"]
}
