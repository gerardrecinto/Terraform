include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/AWS//workflows/blue_green_eks"
}

inputs = {
  environment        = include.root.locals.environment
  aws_region         = "us-west-2"
  vpc_id             = "vpc-dev0000000000000000"
  k8s_namespace      = "default"
  eks_traffic_weight = 10
}
