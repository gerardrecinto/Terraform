# Terraform

![Terraform Platform IaC logo](docs/assets/logo.svg)

Infrastructure-as-code across on-premises, AWS, Azure, and GCP. Reusable modules and environment-specific workflows covering EKS, AKS, GKE, Apigee, PrivateLink, S3 tiering, observability, and logging pipelines.

![Terraform](https://img.shields.io/badge/Terraform-1.7%2B-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20S3%20%7C%20OpenSearch-FF9900?logo=amazon-aws&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-AKS%20%7C%20ACR-0089D6?logo=microsoft-azure&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-GKE%20%7C%20Apigee%20X-4285F4?logo=google-cloud&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

![demo](docs/assets/demo.gif)

Commercial angle and consulting hooks: [docs/go-to-market.md](docs/go-to-market.md).

> **Note:** This is a personal portfolio repository. Module design and provisioning patterns are original implementations inspired by common enterprise infrastructure problems. All company names, internal system names, account IDs, hostnames, ARNs, VPC CIDRs, and business metrics have been removed or replaced with generic placeholders — none of the figures or names in this repository refer to a real employer, deployment, or production outcome.

---

## Design principles

**Separation of concerns at every layer.** Helm release versions, replica counts, and chart config live in Terraform, not ad-hoc `helm upgrade` commands. ConfigMaps that drive runtime behavior are Terraform resources with full audit trail and PR-based change control.

**Ephemeral state handled at the IaC layer.** Pod IPs are transient. Rather than fighting this, modules use `data "kubernetes_pod_v1"` to query live cluster state and converge AWS resources (NLB target groups) to match. Every `terraform apply` is a reconciliation loop.

**Least-privilege exposure by design.** PrivateLink keeps cross-account traffic off the public internet. Separate NLB target groups per gateway type enforce protocol-level isolation. `target_type = ip` bypasses NodePort NAT and preserves source IP end-to-end.

**Everything version-controlled, nothing click-ops.** IAM roles, Cognito federation, Grafana alert rules, ACR cleanup tasks: all Terraform resources. If it can't be reviewed in a PR and rolled back with a revert, it doesn't exist in production.

---

## Structure

```
AWS/
├── modules/
│   ├── eks/               multi-account EKS: OIDC, CNI custom networking, Linux/Windows node groups
│   ├── privatelink/       cross-account endpoint service + consumer (SSH/ADB, MSK, internal APIs)
│   ├── s3_lifecycle/      Standard → IA → Glacier Deep Archive, KMS enforcement
│   ├── grafana_alerting/  Grafana rules for ALBs (5XX, P99), MSK, SQS, PrivateLink
│   ├── nginx_ingress/     NGINX on NLB, TCP ConfigMap, dynamic pod IP NLB target registration
│   ├── sqs_sns/           SQS + SNS with DLQ, FIFO, cross-service subscriptions
│   └── opensearch/        OpenSearch with Cognito/SAML SSO + Azure AD OIDC
└── workflows/
    ├── deploy_eks/        EKS cluster provisioning (EKS Auto Mode, Helm/K8s providers)
    ├── blue_green_eks/    zero-downtime EB → EKS via ALB weighted target groups
    └── opensearch_migration/ on-prem ES → AWS OpenSearch with Cognito + Azure AD SSO

Azure/
├── modules/
│   ├── aks/               Azure AD RBAC, workload identity, ACR integration, Container Insights
│   └── acr/               geo-replication, weekly untagged image cleanup Task
└── workflows/
    └── deploy_aks_logging/ FluentBit → Event Hubs → Logstash → OpenSearch → Grafana

GCP/
├── modules/
│   ├── apigee/            Apigee X org + env + instance; JS token auth; path routing; SpikeArrest
│   ├── gke/               private cluster: Workload Identity, Binary Authorization, Shielded Nodes
│   └── gcs_lifecycle/     Standard → Nearline → Coldline → Archive with CMEK
└── workflows/
    └── deploy_apigee_proxies/ three example API proxies with token auth + path routing
```

---

## AWS Modules

### `modules/s3_lifecycle`

Tiered log storage: Standard → Standard-IA → Glacier Deep Archive, with KMS enforcement and optional cross-region replication. This models a common cost-optimization pattern for large, append-only log buckets where recent data needs fast access and older data can move to cold storage.

```hcl
module "log_archive" {
  source = "./AWS/modules/s3_lifecycle"

  bucket_name                = "app-logs-prod"
  environment                = "prod"
  log_prefix                 = "logs/"
  transition_to_glacier_days = 90
  kms_key_arn                = var.kms_key_arn
  enforce_encryption_policy  = true
  replication_regions        = ["ap-south-1", "eu-central-1"]
}
```

### `modules/eks`

Multi-account EKS with VPC CNI custom networking, OIDC federation, mixed Linux/Windows node groups:

```hcl
module "eks" {
  source = "./AWS/modules/eks"

  cluster_name    = "platform-prod"
  cluster_version = "1.31"
  environment     = "prod"
  vpc_id          = "vpc-0abc123"
  subnet_ids      = ["subnet-aaa", "subnet-bbb"]

  cni_custom_networking_enabled = true
  eni_config_subnets = {
    "us-west-2a" = "subnet-100a"
    "us-west-2b" = "subnet-100b"
  }

  linux_node_groups = {
    general = {
      instance_types = ["m6i.xlarge"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      capacity_type  = "ON_DEMAND"
    }
  }
}
```

### `modules/nginx_ingress`

NGINX on NLB for an SSH/ADB-style device gateway plus a general streaming target. The hard problem is ephemeral pod IPs: NLB `target_type = ip` registers pod IPs directly (preserves source IP for SSH auth), but pod IPs change on every rollout. The module uses `data "kubernetes_pod_v1"` + `for_each` so every `terraform apply` re-syncs NLB targets to actual pod state.

```
Traffic path:
  Consumer VPC
    └─ VPC Endpoint (PrivateLink)
         └─ NLB (internal)
              ├─ Target Group: ssh_adb (port 22, target_type=ip)
              │    └─ pod IPs registered dynamically via for_each
              └─ Target Group: streaming (port 443, target_type=ip)
                   └─ source IP sticky → NGINX TCP stream → pod
```

### `modules/grafana_alerting`

Terraform-managed Grafana alert rules for ALBs, MSK, and SQS, parameterized by ARN suffixes and thresholds so the same module can be reused across environments:

```hcl
module "grafana_alerts" {
  source = "./AWS/modules/grafana_alerting"

  environment        = "prod"
  alb_arn_suffixes   = [module.alb_app_a.arn_suffix, module.alb_app_b.arn_suffix]
  alb_5xx_threshold  = 10
  alb_latency_p99_ms = 2000
  msk_cluster_name   = "events-prod"
  sqs_queue_names    = ["event-queue-prod", "release-queue-prod"]
  slack_webhook_url  = var.slack_webhook
}
```

---

## Azure

### `modules/aks`

AKS with Azure AD RBAC, workload identity (OIDC issuer), ACR pull role, Container Insights, auto-scaling node pools.

### `workflows/deploy_aks_logging`

Example telemetry logging stack:

| Component | Role |
|---|---|
| FluentBit DaemonSet | Tails all pod logs → Event Hubs (Kafka protocol) |
| Azure Event Hubs | Kafka-compatible message bus |
| Logstash | Parses, enriches, indexes to OpenSearch |
| OpenSearch (on AKS) | Log storage and full-text search |
| Grafana | Dashboards, internal LoadBalancer |

---

## GCP

### `modules/apigee`

Apigee X setup with org/env/instance provisioning. Proxy bundles are rendered from templates via `archive_file`. Each bundle includes JS-ValidateToken (Bearer token introspection), JS-PathRouter (dynamic `target.url`), and SpikeArrest (600 req/min) — a pattern for consolidating many single-purpose API proxies into fewer parameterized ones, reducing duplicated auth and routing logic across an org.

### `modules/gke`

Private, VPC-native GKE with Workload Identity, Binary Authorization, Shielded Nodes, and REGULAR release channel auto-upgrades.

### `workflows/deploy_apigee_proxies`

Three example proxies showing the path-routing and token-auth pattern:

| Proxy | Base Path | Routes |
|---|---|---|
| device-api | `/device-api/v2` | `/devices`, `/ssh`, `/workspaces`, `/builds` |
| package-api | `/package-api/v2` | `/packages`, `/download`, `/catalog`, `/releases` |
| inference-api | `/inference-api/v2` | `/models`, `/inference`, `/benchmarks`, `/compile`, `/profile` |

---

## License

MIT
