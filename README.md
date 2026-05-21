# Terraform

Infrastructure-as-code across On-Premises, AWS, Azure, and GCP. Reusable modules and environment-specific workflows covering EKS, AKS, GKE, Apigee, PrivateLink, observability, and logging pipelines.

> **Note:** This repository is published as supporting evidence for skills listed on my resume. The code structure, patterns, and architecture reflect real work done across production environments. All company-specific values -- including account IDs, hostnames, resource names, VPC CIDRs, ARNs, and endpoint URLs -- have been replaced with generic placeholders to preserve company confidential information (CCI). The underlying infrastructure patterns, module design, and implementation approach are representative of actual production work.

---

## Design Principles

**Separation of concerns at every layer.** Helm release versions, replica counts, and chart config live in Terraform -- not in ad-hoc `helm upgrade` commands. ConfigMaps that drive runtime behavior (TCP port routing, security headers) are Terraform resources with full audit trail and PR-based change control. Business logic lives in shared modules; environment-specific wiring lives in workflows.

**Ephemeral state handled at the IaC layer.** Pod IPs, node IPs, and scaling targets are all transient in Kubernetes. Rather than fighting this with static config or custom controllers, modules use Terraform data sources to query live cluster state (`data "kubernetes_pod_v1"`) and converge AWS resources (NLB target groups) to match. Every `terraform apply` is a reconciliation loop.

**Least-privilege exposure by design.** PrivateLink keeps all cross-account traffic off the public internet. Separate NLB target groups per gateway type (SSH/ADB vs device streaming) enforce protocol-level isolation -- a streaming pod is never reachable on port 22. `target_type = ip` bypasses NodePort NAT, preserves source IP, and eliminates an unnecessary network hop.

**Everything version-controlled, nothing click-ops.** IAM roles, Cognito federation, Grafana alert rules, ACR cleanup tasks -- all Terraform resources. If it can't be reviewed in a PR and rolled back with a revert, it shouldn't exist in production.

---

## Structure

```
AWS/
├── modules/
│   ├── eks/                  multi-account EKS: OIDC IDP, CNI custom networking, mixed Linux/Windows node groups
│   ├── privatelink/          cross-account endpoint service + consumer endpoint (SSH gateway, MSK, internal APIs)
│   ├── s3_lifecycle/         S3 tiering: Standard -> Standard-IA -> Glacier Deep Archive, KMS enforcement
│   ├── grafana_alerting/     Grafana alert rules for ALBs (5XX, P99 latency), MSK, SQS, PrivateLink via CloudWatch
│   ├── nginx_ingress/        NGINX on NLB: TCP ConfigMap for ports 22/443, dynamic pod IP NLB target registration
│   ├── sqs_sns/              SQS + SNS with DLQ, FIFO support, and cross-service subscription
│   └── opensearch/           OpenSearch with Cognito/SAML SSO and Azure AD OIDC federation
└── workflows/
    ├── deploy_eks/           EKS cluster provisioning (EKS Auto Mode, Helm/K8s providers)
    ├── blue_green_eks/       zero-downtime Elastic Beanstalk -> EKS migration via ALB weighted target groups
    └── opensearch_migration/ on-prem Elasticsearch -> AWS OpenSearch with Cognito + Azure AD SSO

Azure/
├── modules/
│   ├── aks/                  AKS cluster: Azure AD RBAC, workload identity, ACR integration, Container Insights
│   └── acr/                  Azure Container Registry with geo-replication and untagged image cleanup
└── workflows/
    └── deploy_aks_logging/   IoT telemetry full logging stack:
                              FluentBit (DaemonSet) -> Azure Event Hubs (Kafka) -> Logstash -> OpenSearch -> Grafana

GCP/
├── modules/
│   ├── apigee/               Apigee X org + environment + instance; JS token auth and path routing policies; proxy bundle rendering
│   ├── gke/                  GKE private cluster: Workload Identity, Binary Authorization, Shielded Nodes, auto-scaling pools
│   └── gcs_lifecycle/        GCS tiering: Standard -> Nearline -> Coldline -> Archive with CMEK and versioning
└── workflows/
    └── deploy_apigee_proxies/ DeviceCloud, SoftwareHub, and ModelHub Apigee proxy deployment with token auth JS policies and path-based routing
```

---

## AWS Modules

### `modules/eks`

Multi-account EKS with:
- VPC CNI custom networking using 100-series secondary subnets (ENIConfig per AZ)
- OIDC IDP federation for external identity providers (Azure AD, Okta)
- Mixed Linux and Windows node groups with Taints/Tolerations for workload isolation
- EBS CSI driver with IRSA role
- Private cluster endpoint

```hcl
module "eks" {
  source = "./AWS/modules/eks"

  cluster_name    = "saga-prod"
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
      labels         = { "node-type" = "general" }
      taints         = []
    }
  }

  windows_node_groups = {
    win = {
      instance_types = ["m6i.2xlarge"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
    }
  }
}
```

---

### `modules/privatelink`

Cross-account PrivateLink for the DeviceCloud SSH/ADB Gateway and device streaming. NLB-backed endpoint service on the provider side; VPC endpoint with Route53 alias on the consumer side. No VPC peering, no public internet exposure.

```hcl
module "ssh_gateway_privatelink" {
  source = "./AWS/modules/privatelink"

  service_name       = "devicecloud-ssh-gateway"
  vpc_id             = var.provider_vpc_id
  subnet_ids         = var.provider_subnet_ids
  nlb_arn            = module.nlb.arn
  consumer_vpc_id    = var.consumer_vpc_id
  allowed_principals = ["arn:aws:iam::123456789012:root"]
  tcp_ports          = [22, 443]
  environment        = "prod"
}
```

---

### `modules/s3_lifecycle`

S3 tiering to Glacier Deep Archive. Delivered $2.19M/month (~$26.28M/year) in cloud cost savings starting July 2024 on ~9 PB of Axiom log data across Oregon, Mumbai, and Frankfurt:

```hcl
module "axiom_logs" {
  source = "./AWS/modules/s3_lifecycle"

  bucket_name                = "examplecorp-axiom-logs-prod"
  environment                = "prod"
  log_prefix                 = "axiom-logs/"
  transition_to_glacier_days = 90
  kms_key_arn                = var.kms_key_arn
  enforce_encryption_policy  = true
  replication_regions        = ["ap-south-1", "eu-central-1"]
}
```

---

### `modules/grafana_alerting`

Terraform-managed Grafana alerts for 10 ALBs and 4 AWS services (MSK, SQS, SNS, PrivateLink) across 5 environments:

```hcl
module "grafana_alerts" {
  source = "./AWS/modules/grafana_alerting"

  grafana_url  = var.grafana_url
  grafana_auth = var.grafana_token
  environment  = "prod"

  alb_arn_suffixes   = [module.alb_devicecloud.arn_suffix, module.alb_modelhub.arn_suffix]
  alb_names          = ["devicecloud", "modelhub"]
  alb_5xx_threshold  = 10
  alb_latency_p99_ms = 2000

  msk_cluster_name  = "aware-iot-prod"
  sqs_queue_names   = ["event-queue-prod", "release-queue-prod"]
  slack_webhook_url = var.slack_webhook
}
```

---

### `modules/nginx_ingress`

NGINX on NLB for the DeviceCloud SSH/ADB gateway and device streaming. The NGINX Helm release is fully Terraform-managed -- chart version, replica count, ConfigMap references, and anti-affinity rules are all version-controlled. A dedicated TCP services ConfigMap routes port 22 (SSH/ADB) and port 443 (device streaming) to their respective Kubernetes services; changing a routing target is a one-line config PR, not a Helm upgrade.

**The hard problem: ephemeral pod IPs.**
NLB `target_type = ip` registers pod IPs directly, bypassing NodePort NAT and preserving the client source IP end-to-end (required for SSH auth). But pod IPs change on every rollout, reschedule, or node drain. A static target group silently routes to stale IPs with no obvious error. The module solves this with Terraform data sources that query the live Kubernetes API for current pod IPs and `for_each` to register each live pod as an NLB target. Every `terraform apply` re-syncs NLB targets to actual pod state.

Two separate target groups scope which pods are reachable per gateway type, enforcing least-privilege at the NLB layer:

| Target Group | Port | Gateway Type | Stickiness |
|---|---|---|---|
| `ssh_adb` | 22 | SSH into Snapdragon devices, ADB over network | None (stateless handshake) |
| `device_streaming` | 443 | Screen copy, NetrisTV device streaming | Source IP (session must pin to pod) |

```hcl
module "nginx" {
  source = "./AWS/modules/nginx_ingress"

  cluster_name = "devicecloud-prod"
  environment  = "prod"
  vpc_id       = var.vpc_id
  use_nlb      = true
  nlb_internal = true   # traffic enters only via PrivateLink

  # Port 22 and 443 are built into the module via the TCP ConfigMap.
  # Add any additional TCP ports here.
  tcp_services = {}

  # SSH/ADB gateway -- pod label selector drives dynamic NLB target registration
  ssh_gateway_namespace  = "devicecloud"
  ssh_gateway_service    = "ssh-gateway"
  ssh_gateway_pod_labels = { "app" = "ssh-gateway" }

  # Device streaming (screen copy / NetrisTV)
  device_streaming_namespace  = "devicecloud"
  device_streaming_service    = "device-streaming"
  device_streaming_pod_labels = { "app" = "device-streaming" }

  # Enables dynamic pod IP registration on NLB target groups
  dynamic_pod_targeting = true
}

# Outputs: registered pod IPs update on every apply
output "ssh_targets"       { value = module.nginx.ssh_adb_registered_pod_ips }
output "streaming_targets" { value = module.nginx.device_streaming_registered_pod_ips }
```

**Traffic path:**
```
Consumer VPC (Intel / external team)
  └─ VPC Endpoint (PrivateLink IP)
       └─ NLB (internal, provider VPC)
            ├─ Target Group: ssh_adb (port 22, target_type=ip)
            │    └─ pod IPs registered dynamically via for_each
            └─ Target Group: device_streaming (port 443, target_type=ip)
                 └─ pod IPs registered dynamically via for_each
                      └─ NGINX TCP stream → SSH/ADB gateway pod | streaming pod
```

---

### `modules/opensearch`

OpenSearch with Cognito + Azure AD OIDC federation (covers on-prem ES -> AWS OpenSearch migration):

```hcl
module "opensearch" {
  source = "./AWS/modules/opensearch"

  domain_name              = "axiom-logs"
  environment              = "prod"
  instance_type            = "r6g.large.search"
  instance_count           = 2
  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  cognito_enabled          = true
  cognito_user_pool_id     = var.cognito_user_pool_id
  cognito_identity_pool_id = var.cognito_identity_pool_id
}
```

---

## AWS Workflows

### `workflows/deploy_eks`

EKS cluster provisioning using EKS Auto Mode with Helm and Kubernetes providers. See [AWS/workflows/deploy_eks](AWS/workflows/deploy_eks/).

### `workflows/blue_green_eks`

Zero-downtime migration from Elastic Beanstalk to EKS using ALB weighted target groups and TargetGroupBinding. Traffic shifts from 0% to 100% EKS in increments while a CloudWatch alarm guards against 5XX spikes. See [AWS/workflows/blue_green_eks](AWS/workflows/blue_green_eks/).

### `workflows/opensearch_migration`

Full workflow for migrating on-prem Elasticsearch to AWS OpenSearch with Cognito + Azure AD SSO. Includes Cognito user pool, Azure AD OIDC identity provider, and S3 snapshot bucket for index migration. See [AWS/workflows/opensearch_migration](AWS/workflows/opensearch_migration/).

---

## Azure Modules

### `modules/aks`

AKS cluster with Azure AD RBAC, workload identity (OIDC issuer), ACR pull role assignment, Container Insights, and auto-scaling user node pools.

### `modules/acr`

Azure Container Registry with network rules, geo-replication, and a weekly ACR Task to purge untagged images.

## Azure Workflows

### `workflows/deploy_aks_logging`

Full logging pipeline for IoT telemetry on AKS. Deploys all infrastructure and Helm releases in one workflow:

| Component | Role |
|---|---|
| FluentBit DaemonSet | Tails all pod logs, ships to Event Hubs via Kafka protocol |
| Azure Event Hubs | Kafka-compatible message bus (replaces MSK in Azure) |
| Logstash | Consumes from Event Hubs, parses and enriches, indexes to OpenSearch |
| OpenSearch (on AKS) | Log storage and full-text search |
| Grafana | Dashboards over OpenSearch datasource, internal LoadBalancer |

See [Azure/workflows/deploy_aks_logging](Azure/workflows/deploy_aks_logging/).

---

## GCP Modules

### `modules/apigee`

Full Apigee X setup: org, environment, environment group, and instance provisioning. Renders proxy bundles from templates using Terraform's `archive_file` datasource. Each bundle includes:

- **JS-ValidateToken** -- extracts the `Authorization: Bearer` header, calls a token introspection endpoint, raises a 401 if inactive or missing
- **JS-PathRouter** -- inspects `proxy.pathsuffix` and sets `target.url` dynamically, enabling one proxy to fan out to multiple backend services
- **SpikeArrest** -- smooths traffic bursts at 600 req/min per client IP before they reach backends

```hcl
module "apigee" {
  source = "./GCP/modules/apigee"

  project_id                = "examplecorp-saga-prod"
  org_id                    = "examplecorp-saga-prod"
  environment               = "prod"
  region                    = "us-central1"
  apigee_env_name           = "prod"
  apigee_env_group_hostname = "api.example.com"
  token_validation_url      = var.token_validation_url

  api_proxies = {
    modelhub = {
      display_name       = "ModelHub API"
      description        = "AI model inference and benchmark routing"
      base_path          = "/modelhub/v1"
      target_url         = "https://modelhub-internal.examplecorp.com"
      token_auth_enabled = true
      path_routes = {
        "/models"    = "https://modelhub-internal.examplecorp.com/api/models"
        "/inference" = "https://modelhub-internal.examplecorp.com/api/inference"
      }
    }
  }
}
```

---

### `modules/gke`

Private, VPC-native GKE cluster with:
- Workload Identity for pod-level GCP IAM (no key files)
- Binary Authorization (only Artifact Registry images)
- Shielded Nodes (Secure Boot + integrity monitoring)
- Least-privilege node service account (no default editor role)
- Maintenance windows and auto-upgrade via REGULAR release channel

```hcl
module "gke" {
  source = "./GCP/modules/gke"

  project_id   = "examplecorp-saga-prod"
  cluster_name = "saga-prod"
  region       = "us-central1"
  environment  = "prod"
  network      = "saga-vpc"
  subnetwork   = "saga-nodes"

  node_pools = {
    general = {
      machine_type  = "n2-standard-4"
      min_count     = 2
      max_count     = 10
      initial_count = 3
      disk_size_gb  = 100
      disk_type     = "pd-ssd"
      preemptible   = false
      spot          = false
      labels        = { "node-type" = "general" }
      taints        = []
    }
  }

  master_authorized_networks = [{
    cidr_block   = "10.0.0.0/8"
    display_name = "internal"
  }]
}
```

---

### `modules/gcs_lifecycle`

GCS bucket with tiered storage lifecycle and CMEK, mirroring the `s3_lifecycle` module for GCP workloads:

```hcl
module "logs_bucket" {
  source = "./GCP/modules/gcs_lifecycle"

  project_id                  = "examplecorp-saga-prod"
  bucket_name                 = "saga-logs-prod"
  location                    = "US"
  environment                 = "prod"
  object_prefix               = "app-logs/"
  transition_to_nearline_days = 30
  transition_to_coldline_days = 90
  transition_to_archive_days  = 365
}
```

---

## GCP Workflows

### `workflows/deploy_apigee_proxies`

Deploys three production Apigee proxies for DeviceCloud, SoftwareHub, and ModelHub using the `apigee` module. Each proxy has token auth and path routing wired in from variables. Also provisions a GCS bucket for proxy bundle artifacts.

See [GCP/workflows/deploy_apigee_proxies](GCP/workflows/deploy_apigee_proxies/).

**Proxy endpoints deployed:**

| Proxy | Base Path | Auth | Path Routes |
|---|---|---|---|
| DeviceCloud | `/devicecloud/v2` | Bearer token | `/devices`, `/ssh`, `/workspaces`, `/builds` |
| SoftwareHub | `/softwarehub/v2` | Bearer token | `/packages`, `/download`, `/catalog`, `/releases` |
| ModelHub | `/modelhub/v2` | Bearer token | `/models`, `/inference`, `/benchmarks`, `/compile`, `/profile` |
