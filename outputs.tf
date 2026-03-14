# =============================================================================
# Outputs
# =============================================================================

output "network_id" {
  description = "OpenStack network ID"
  value       = openstack_networking_network_v2.cluster.id
}

output "subnet_id" {
  description = "OpenStack subnet ID"
  value       = openstack_networking_subnet_v2.cluster.id
}

output "router_id" {
  description = "OpenStack router ID"
  value       = openstack_networking_router_v2.cluster.id
}

output "security_group_id" {
  description = "OpenStack security group ID"
  value       = openstack_networking_secgroup_v2.cluster.id
}

output "keypair_name" {
  description = "OpenStack keypair name"
  value       = openstack_compute_keypair_v2.cluster.name
}

output "cluster_name" {
  description = "Rancher cluster name"
  value       = rancher2_cluster_v2.cluster.name
}

output "cluster_id" {
  description = "Rancher cluster ID"
  value       = rancher2_cluster_v2.cluster.cluster_v1_id
}
