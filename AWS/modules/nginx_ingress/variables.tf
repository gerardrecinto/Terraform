variable "cluster_name" {
  type        = string
  description = "EKS cluster name. Used to namespace NLB target group names."
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, prod). Appended to resource names."
}

variable "namespace" {
  type        = string
  default     = "ingress-nginx"
  description = "Kubernetes namespace for the NGINX ingress controller Helm release."
}

variable "replicas" {
  type        = number
  default     = 2
  description = "Number of NGINX controller pods. Must be >= 2 for HA; hard anti-affinity spreads them across nodes."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for NLB target groups. Required when dynamic_pod_targeting = true."
}

# NLB instead of CLB -- NLB supports TCP passthrough (L4), which CLB does not.
# SSH and ADB are raw TCP; a CLB would attempt HTTP parsing and corrupt the stream.
variable "use_nlb" {
  type        = bool
  default     = true
  description = "Use NLB (L4) instead of CLB. Required for TCP passthrough on port 22 and raw streaming."
}

variable "nlb_internal" {
  type        = bool
  default     = true
  description = "Deploy NLB as internal (not internet-facing). Traffic enters only via PrivateLink VPC endpoints."
}

# Cross-zone enabled: NLB distributes traffic to targets in all AZs, not just its own.
# Required when pods may schedule to any AZ -- without this, AZ-local NLB nodes
# only route to same-AZ pod IPs and cross-AZ pods are unreachable.
variable "nlb_cross_zone_enabled" {
  type        = bool
  default     = true
  description = "Enable NLB cross-zone load balancing. Required for IP-type targets spread across AZs."
}

variable "ssl_termination" {
  type        = bool
  default     = false
  description = "Terminate TLS at NGINX (L7). Set false for TCP passthrough (L4) -- SSH and ADB must use passthrough."
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN for TLS termination. Only used when ssl_termination = true."
}

variable "extra_annotations" {
  type        = map(string)
  default     = {}
  description = "Additional NLB service annotations merged with module defaults."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all AWS resources created by this module."
}

# ─── TCP services (additional ports beyond built-in 22/443) ──────────────────
variable "tcp_services" {
  type        = map(string)
  default     = {}
  description = "Additional TCP port mappings beyond the built-in 22/443. Key = external port, value = 'namespace/service:port'."
}

# ─── SSH/ADB Gateway ──────────────────────────────────────────────────────────

variable "ssh_gateway_namespace" {
  type        = string
  default     = "device-gateway"
  description = "Kubernetes namespace containing the SSH/ADB gateway service."
}

variable "ssh_gateway_service" {
  type        = string
  default     = "ssh-gateway"
  description = "Kubernetes service name for the SSH/ADB gateway. Referenced in the TCP services ConfigMap."
}

variable "ssh_gateway_pod_labels" {
  type        = map(string)
  default     = { "app" = "ssh-gateway" }
  description = "Label selector to identify SSH/ADB gateway pods for dynamic NLB target registration."
}

# ─── Device Streaming ─────────────────────────────────────────────────────────

variable "device_streaming_namespace" {
  type        = string
  default     = "device-gateway"
  description = "Kubernetes namespace containing the device streaming service."
}

variable "device_streaming_service" {
  type        = string
  default     = "device-streaming"
  description = "Kubernetes service name for device streaming. Referenced in the TCP services ConfigMap on port 443."
}

variable "device_streaming_pod_labels" {
  type        = map(string)
  default     = { "app" = "device-streaming" }
  description = "Label selector to identify device streaming pods for dynamic NLB target registration."
}

# ─── Dynamic Pod Targeting ────────────────────────────────────────────────────
# When enabled, this module:
#   1. Queries the Kubernetes API for live pod IPs matching the label selectors above
#   2. Creates two NLB target groups (ssh_adb, device_streaming) with target_type = "ip"
#   3. Registers each live pod IP as an NLB target via for_each
#   4. Filters out Pending/Terminating pods (no pod_ip yet)
#
# Why target_type = "ip" and not "instance":
#   - "instance" requires NodePort -- adds a NAT hop, breaks source IP preservation
#   - "ip" routes directly to the pod, preserves client IP end-to-end
#   - Required for externalTrafficPolicy = Local to work correctly

variable "dynamic_pod_targeting" {
  type        = bool
  default     = false
  description = <<-EOT
    Enable dynamic NLB target registration from live Kubernetes pod IPs.
    When true: creates NLB target groups for ssh_adb (port 22) and device_streaming (port 443),
    queries live pod IPs via Kubernetes data sources, and registers each pod as an IP-type target.
    Pod IPs are re-evaluated on every terraform apply, keeping targets in sync with live pod state.
    Requires vpc_id, ssh_gateway_pod_labels, and device_streaming_pod_labels to be set.
  EOT
}
