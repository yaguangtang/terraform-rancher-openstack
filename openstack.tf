# =============================================================================
# OpenStack Infrastructure Resources for Rancher K8s Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# -----------------------------------------------------------------------------
# SSH Keypair
# -----------------------------------------------------------------------------

resource "openstack_compute_keypair_v2" "cluster" {
  name       = var.keypair_name
  public_key = file(pathexpand(var.ssh_public_key))
}

# -----------------------------------------------------------------------------
# Network & Subnet
# -----------------------------------------------------------------------------

resource "openstack_networking_network_v2" "cluster" {
  name           = "${var.cluster_name}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "cluster" {
  name            = "${var.cluster_name}-subnet"
  network_id      = openstack_networking_network_v2.cluster.id
  cidr            = var.network_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

# -----------------------------------------------------------------------------
# Router (connects internal network to external/public network)
# -----------------------------------------------------------------------------

resource "openstack_networking_router_v2" "cluster" {
  name                = "${var.cluster_name}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "cluster" {
  router_id = openstack_networking_router_v2.cluster.id
  subnet_id = openstack_networking_subnet_v2.cluster.id
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

resource "openstack_networking_secgroup_v2" "cluster" {
  name        = "${var.cluster_name}-secgroup"
  description = "Security group for Rancher-managed K8s cluster ${var.cluster_name}"
}

# SSH
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# Kubernetes API server
resource "openstack_networking_secgroup_rule_v2" "kube_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# Rancher agent communication (cattle-cluster-agent)
resource "openstack_networking_secgroup_rule_v2" "rancher_webhook" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# HTTP (for ingress controller)
resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# RKE2 supervisor API
resource "openstack_networking_secgroup_rule_v2" "rke2_supervisor" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9345
  port_range_max    = 9345
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# NodePort services range
resource "openstack_networking_secgroup_rule_v2" "nodeports" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# Intra-cluster communication (all TCP between cluster nodes)
resource "openstack_networking_secgroup_rule_v2" "intra_cluster_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# Intra-cluster communication (all UDP between cluster nodes)
resource "openstack_networking_secgroup_rule_v2" "intra_cluster_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# ICMP (ping) between cluster nodes
resource "openstack_networking_secgroup_rule_v2" "intra_cluster_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# VXLAN overlay (used by Canal/Flannel CNI)
resource "openstack_networking_secgroup_rule_v2" "vxlan" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# etcd client & peer ports
resource "openstack_networking_secgroup_rule_v2" "etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2381
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

# kubelet API
resource "openstack_networking_secgroup_rule_v2" "kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}
