# on-prem

Terraform modules and workflows for provisioning and upgrading bare-metal Kubernetes clusters. Covers server baseline setup, security hardening, kubeadm-based cluster lifecycle, in-cluster networking (MetalLB + NGINX + CoreDNS), and rolling upgrade runbooks for both the OS and Kubernetes itself.

> All company-specific values — IP addresses, hostnames, NTP servers, SSH keys, CIDR blocks — are replaced with `PLACEHOLDER_*` values. The module logic, provisioning approach, and upgrade sequencing reflect production patterns used on Axiom on-prem infrastructure.

## Structure

```
modules/
├── server-baseline/      OS prep: packages, hostname, NTP, deploy user + SSH key
├── security-hardening/   UFW rules, SSH hardening, Kubernetes API port allowlist
├── k8s-controlplane/     kubeadm init: containerd, kubelet, kubeadm, CNI manifest apply
├── k8s-worker/           containerd + kubelet install, kubeadm join
└── networking/           MetalLB (L2), NGINX ingress (LoadBalancer), CoreDNS upstream config

workflows/
├── deploy-k8s/           Full cluster provisioning: baseline → hardening → CP → workers → networking
├── upgrade-k8s/          Rolling Kubernetes upgrade: CP first, then drain/upgrade/uncordon each worker
└── upgrade-server/       OS-level rolling upgrade with reboot and node drain/uncordon gates

environments/
├── prod/terraform.tfvars.example
└── dev/terraform.tfvars.example
```

## Modules

### `modules/server-baseline`

Run first on every node before any Kubernetes installation.

- Installs a configurable package list via `apt`
- Sets hostname and `/etc/hosts` entry
- Configures `systemd-timesyncd` with on-prem NTP servers
- Creates a deploy user with a given SSH public key and passwordless sudo

### `modules/security-hardening`

- UFW default-deny with explicit allow rules for SSH, Kubernetes API (6443), kubelet (10250), and etcd (2379/2380)
- Restricts SSH to an allowlisted CIDR and named users only
- Disables SSH password authentication and root login
- Installs auditd with rules covering identity changes, sudo, exec, and auth log writes
- Kernel hardening via sysctl: `rp_filter`, `dmesg_restrict`, `kptr_restrict`, source route and redirect blocking

### `modules/k8s-controlplane`

- Disables swap, loads `overlay` and `br_netfilter`, sets bridge sysctl params
- Installs containerd with `SystemdCgroup = true`
- Installs `kubelet`, `kubeadm`, `kubectl` from the upstream Kubernetes APT repo at the specified version
- Runs `kubeadm init` with a stable control-plane endpoint (VIP or DNS)
- Applies the CNI manifest and writes the worker join command to `/tmp/k8s_join_command.sh`

### `modules/k8s-worker`

- Same containerd and kubelet install path as the control plane
- Runs `kubeadm join` using the join command passed from the control plane module output

### `modules/networking`

Configures in-cluster networking after the cluster is up. Uses the Helm and Kubernetes Terraform providers.

**MetalLB** — layer-2 bare-metal load balancer. Assigns IPs from an on-prem VLAN pool to `LoadBalancer` services without a cloud controller. Configures `IPAddressPool` and `L2Advertisement` CRDs via `kubernetes_manifest`.

**NGINX Ingress Controller** — deployed as a `LoadBalancer` service backed by MetalLB. A fixed IP from the pool is pinned via `loadBalancerIP` so DNS can point at a stable address. `X-Forwarded-For` is preserved since there is no cloud NAT layer.

**CoreDNS** — patches the existing `Corefile` ConfigMap to forward external queries to on-prem recursive DNS servers and adds stub zones for internal search domains. Triggers a CoreDNS rollout restart after patching.

## Workflows

### `workflows/deploy-k8s`

Provisions a complete cluster end to end:

1. `server-baseline` on control plane and all workers
2. `security-hardening` on all nodes
3. `k8s-controlplane` — kubeadm init
4. `k8s-worker` — kubeadm join (one `for_each` per worker)
5. `networking` — MetalLB + NGINX + CoreDNS

```bash
cd workflows/deploy-k8s
terraform init
terraform plan  -var-file=../../environments/prod/terraform.tfvars
terraform apply -var-file=../../environments/prod/terraform.tfvars
```

### `workflows/upgrade-k8s`

Rolling Kubernetes version upgrade. Control plane first, then each worker via drain → upgrade → uncordon.

```bash
terraform apply -var="target_kubernetes_version=1.30.2"
```

### `workflows/upgrade-server`

OS-level rolling upgrade with cluster awareness. Drains the node before upgrading, reboots if a kernel update was applied, polls until SSH is back, runs a health check, then uncordons.
