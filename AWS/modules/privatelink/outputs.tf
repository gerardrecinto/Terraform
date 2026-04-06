output "endpoint_service_name" {
  value = aws_vpc_endpoint_service.this.service_name
}

output "endpoint_service_id" {
  value = aws_vpc_endpoint_service.this.id
}

output "vpc_endpoint_id" {
  value = try(aws_vpc_endpoint.this[0].id, null)
}

output "vpc_endpoint_dns" {
  value = try(aws_vpc_endpoint.this[0].dns_entry[0].dns_name, null)
}

output "security_group_id" {
  value = aws_security_group.endpoint.id
}
