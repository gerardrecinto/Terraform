output "tag_policy_id" {
  description = "ID of the Organizations tag policy (empty if enable_org_policy = false)"
  value       = var.enable_org_policy ? aws_organizations_policy.cost_tagging[0].id : ""
}

output "activated_cost_allocation_tags" {
  description = "Tags activated in Cost Explorer for allocation reporting"
  value       = toset(var.required_tags)
}
