# =============================================================================
# OpenStack Provider Variables
# =============================================================================

variable "openstack_auth_url" {
  description = "OpenStack Keystone authentication URL"
  type        = string
}

variable "openstack_username" {
  description = "OpenStack username"
  type        = string
}

variable "openstack_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

variable "openstack_tenant_name" {
  description = "OpenStack project/tenant name"
  type        = string
}

variable "openstack_domain_name" {
  description = "OpenStack domain name"
  type        = string
  default     = "Default"
}

variable "openstack_region" {
  description = "OpenStack region"
  type        = string
  default     = "RegionOne"
}

# =============================================================================
# Rancher Provider Variables
# =============================================================================

variable "rancher_api_url" {
  description = "Rancher API URL (e.g. https://rancher.example.com)"
  type        = string
}

variable "rancher_token_key" {
  description = "Rancher API bearer token (Access Key:Secret Key)"
  type        = string
  sensitive   = true
}

# =============================================================================
# Cluster Configuration
# =============================================================================

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "openstack-k8s"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the RKE2 cluster"
  type        = string
  default     = "v1.31.6+rke2r1"
}

# =============================================================================
# OpenStack Network Configuration
# =============================================================================

variable "external_network_name" {
  description = "Name of the external/public network in OpenStack"
  type        = string
  default     = "public"
}

variable "network_cidr" {
  description = "CIDR for the internal network subnet"
  type        = string
  default     = "192.168.100.0/24"
}

variable "dns_nameservers" {
  description = "DNS nameservers for the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# =============================================================================
# OpenStack Instance Configuration
# =============================================================================

variable "image_name" {
  description = "OpenStack image name for cluster nodes (must support cloud-init)"
  type        = string
  default     = "ubuntu-22.04"
}

variable "ssh_user" {
  description = "SSH user for the image"
  type        = string
  default     = "ubuntu"
}

variable "keypair_name" {
  description = "Name of the SSH keypair to create in OpenStack"
  type        = string
  default     = "rancher-k8s"
}

variable "ssh_public_key" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/work/rancher/id_ed25519.pub"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/work/rancher/id_ed25519"
}

# Control plane nodes
variable "cp_flavor" {
  description = "OpenStack flavor for control plane nodes"
  type        = string
  default     = "m1.large"
}

variable "cp_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "cp_disk_size" {
  description = "Root disk size in GiB for control plane nodes"
  type        = number
  default     = 40
}

# Worker nodes
variable "worker_flavor" {
  description = "OpenStack flavor for worker nodes"
  type        = string
  default     = "m1.large"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "worker_disk_size" {
  description = "Root disk size in GiB for worker nodes"
  type        = number
  default     = 40
}

variable "availability_zone" {
  description = "OpenStack availability zone"
  type        = string
  default     = "nova"
}
