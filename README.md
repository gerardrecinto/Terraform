# Terraform

Infrastructure-as-code for cloud environments using Terraform. Currently covers AWS EKS cluster provisioning for CI/CD workloads.

## Structure

```
AWS/
└── workflows/
    └── deploy_eks/
        ├── main.tf       # EKS cluster + VPC + Helm/K8s providers
        ├── data.tf       # data sources (existing VPC, cluster lookup)
        └── versions.tf   # provider version constraints
```

## AWS / deploy_eks

Provisions an EKS cluster (v1.31) in `us-west-1` using the `terraform-aws-modules/eks` community module with EKS Auto Mode enabled (general-purpose node pool).

**What gets created:**
- EKS control plane with public endpoint access
- Cluster access entry granting the caller admin permissions
- Kubernetes and Helm provider configs using `aws eks get-token` for auth

**Usage:**

```bash
cd AWS/workflows/deploy_eks

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Tear down:**

```bash
terraform destroy
```

**Prerequisites:**
- AWS CLI configured with credentials that have EKS + IAM permissions
- An existing VPC with at least two subnets across different AZs
- Terraform >= 1.9 and AWS provider >= 5.x

## Notes

- Node pools are managed by EKS Auto Mode so there are no manually defined node groups
- The `cluster_endpoint_public_access = true` setting is fine for dev/staging; lock it down with `cluster_endpoint_public_access_cidrs` for production
- Helm provider is included for future in-cluster tooling (metrics-server, cert-manager, etc.)
