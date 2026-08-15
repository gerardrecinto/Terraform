# network

Shared VPC module: public + private subnets across N Availability Zones, with
NAT Gateway and VPC Flow Logs both off by default.

## Why NAT is off by default

The other modules in `secure-connectivity/` (`private-compute-access`,
`access-gateway`) are built around Systems Manager Session Manager, which
reaches private instances through VPC interface endpoints, not outbound
internet access. A private instance that only needs SSM connectivity and
S3/CloudWatch access doesn't need a NAT Gateway -- each NAT Gateway costs
roughly $0.045/hr plus $0.045/GB processed (us-east-1, 2025 pricing; check
current AWS pricing for your region), which adds up fast for a demo that's
just proving a pattern. Turn `enable_nat_gateway = true` on when a workload
in this VPC actually needs outbound internet (e.g. pulling from a public
package registry).

## Known, accepted finding

`trivy config` flags `map_public_ip_on_launch = true` on the public subnets
(AWS-0164, HIGH). This is intentional: the public subnets exist specifically
to host internet-facing resources (ALB/NLB, NAT Gateway). Private workloads
are placed in the private subnets, which do not set this flag.

## Inputs / outputs

See `variables.tf` / `outputs.tf`. Key inputs: `vpc_cidr`, `availability_zones`
(min 2), `enable_nat_gateway`, `single_nat_gateway` (cost vs. AZ-independence
tradeoff), `enable_flow_logs`.
