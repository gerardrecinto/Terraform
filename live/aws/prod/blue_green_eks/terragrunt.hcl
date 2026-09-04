include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/AWS//workflows/blue_green_eks"
}

inputs = {
  environment   = include.root.locals.environment
  aws_region    = "us-west-2"
  vpc_id        = "vpc-prod0000000000000000"
  k8s_namespace = "default"

  # Migration sequence: 0 -> 10 -> 50 -> 100; leave at 0 until the migration
  # is actually kicked off, then bump this value and re-apply at each step
  eks_traffic_weight = 0
}
