output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ."
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Availability Zones used by this VPC."
  value       = var.availability_zones
}

output "nat_gateway_enabled" {
  description = "Whether NAT Gateway(s) were created for private-subnet egress."
  value       = var.enable_nat_gateway
}
