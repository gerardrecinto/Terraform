include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/OpenStack//workflows/deploy_magnum_k8s"
}

inputs = {
  environment         = include.root.locals.environment
  external_network_id = "00000000-0000-0000-0000-0000000000ex"
  keypair_name        = "platform-prod-keypair"
  vip_subnet_id       = "00000000-0000-0000-0000-0000000000v2"
  member_subnet_id    = "00000000-0000-0000-0000-0000000000m2"
  tls_container_ref   = "https://barbican.example.internal:9311/v1/secrets/prod-tls-cert"

  ingress_node_addresses = ["10.30.0.10", "10.30.0.11", "10.30.0.12"]
}
