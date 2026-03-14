# Rancher K8s Cluster on OpenStack — Terraform Project

Provisions OpenStack networking infrastructure and creates an RKE2 Kubernetes cluster via Rancher 2.13.2 using the OpenStack node driver.

## What Gets Created

### OpenStack Resources
- **Network & Subnet** — isolated tenant network with configurable CIDR
- **Router** — connects the internal subnet to the external/public network
- **Security Group** — rules for SSH, K8s API (6443), RKE2 supervisor (9345), HTTPS (443), HTTP (80), NodePorts (30000–32767), VXLAN, etcd, kubelet, and full intra-cluster communication
- **SSH Keypair** — imported from your local public key

### Rancher Resources
- **Cloud Credential** — OpenStack credentials stored in Rancher
- **Machine Configs** — separate configs for control plane and worker node pools
- **RKE2 Cluster** — multi-node cluster with configurable control plane and worker pool sizes

## Prerequisites

- Terraform >= 1.5
- Rancher 2.13.2 with the OpenStack node driver enabled
- An OpenStack account with permissions to create networks, routers, security groups, and instances
- A Rancher API token (Settings → API Keys)
- An SSH keypair (default: `~/.ssh/id_rsa.pub`)

## Quick Start

```bash
# 1. Copy and fill in your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values

# 2. Initialize
terraform init

# 3. Review the plan
terraform plan

# 4. Apply
terraform apply
```

## Variables Reference

| Variable | Description | Default |
|---|---|---|
| `openstack_auth_url` | Keystone auth URL | — |
| `openstack_username` | OpenStack user | — |
| `openstack_password` | OpenStack password | — |
| `openstack_tenant_name` | Project/tenant name | — |
| `openstack_domain_name` | Domain name | `Default` |
| `openstack_region` | Region | `RegionOne` |
| `rancher_api_url` | Rancher server URL | — |
| `rancher_token_key` | Rancher bearer token | — |
| `cluster_name` | K8s cluster name | `openstack-k8s` |
| `kubernetes_version` | RKE2 version | `v1.34.4+rke2r1` |
| `external_network_name` | Public/external network | `public` |
| `network_cidr` | Subnet CIDR | `192.168.100.0/24` |
| `image_name` | VM image (needs cloud-init) | `ubuntu-22.04` |
| `ssh_user` | SSH user for the image | `ubuntu` |
| `cp_flavor` / `worker_flavor` | Instance flavors | `m1.large` |
| `cp_count` / `worker_count` | Pool sizes | `3` / `2` |
| `cp_disk_size` / `worker_disk_size` | Root disk (MB) | `40960` |

## Notes

- The `kubernetes_version` must match a version available in your Rancher installation. Check **Tools → RKE2 Releases** in the Rancher UI.
- `image_name` must be a cloud-init capable image available in your OpenStack Glance (e.g. Ubuntu 22.04 cloud image).
- `external_network_name` should match the shared/provider network in your OpenStack that provides floating IPs.
- The security group allows intra-cluster traffic between members. External access is limited to SSH, K8s API, HTTPS, HTTP, and NodePorts.
- Disk sizes in the machine config are in **GB** (e.g. `40` = 40 GB).

## Cleanup

```bash
terraform destroy
```

This removes the Rancher cluster and all OpenStack infrastructure.
