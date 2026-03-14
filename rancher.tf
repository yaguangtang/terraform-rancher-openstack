# =============================================================================
# Rancher2 Resources — Cloud Credential, Machine Config, Cluster
# =============================================================================

# -----------------------------------------------------------------------------
# Cloud Credential (OpenStack)
# -----------------------------------------------------------------------------

resource "rancher2_cloud_credential" "openstack" {
  name = "${var.cluster_name}-openstack"

  openstack_credential_config {
    password = var.openstack_password
  }
}

# -----------------------------------------------------------------------------
# Machine Config — Control Plane Nodes
# -----------------------------------------------------------------------------

resource "rancher2_machine_config_v2" "control_plane" {
  generate_name = "${var.cluster_name}-cp"

  openstack_config {
    auth_url            = var.openstack_auth_url
    availability_zone   = var.availability_zone
    region              = var.openstack_region
    username            = var.openstack_username
    domain_name         = var.openstack_domain_name
    tenant_name         = var.openstack_tenant_name
    image_name          = var.image_name
    flavor_name         = var.cp_flavor
    keypair_name        = openstack_compute_keypair_v2.cluster.name
    private_key_file    = file(pathexpand(var.ssh_private_key))
    net_name            = openstack_networking_network_v2.cluster.name
    sec_groups          = openstack_networking_secgroup_v2.cluster.name
    floating_ip_pool    = var.external_network_name
    ssh_user            = var.ssh_user
    boot_from_volume    = true
    volume_size         = tostring(var.cp_disk_size)
    active_timeout      = "300"
  }
}

# -----------------------------------------------------------------------------
# Machine Config — Worker Nodes
# -----------------------------------------------------------------------------

resource "rancher2_machine_config_v2" "worker" {
  generate_name = "${var.cluster_name}-worker"

  openstack_config {
    auth_url            = var.openstack_auth_url
    availability_zone   = var.availability_zone
    region              = var.openstack_region
    username            = var.openstack_username
    domain_name         = var.openstack_domain_name
    tenant_name         = var.openstack_tenant_name
    image_name          = var.image_name
    flavor_name         = var.worker_flavor
    keypair_name        = openstack_compute_keypair_v2.cluster.name
    private_key_file    = file(pathexpand(var.ssh_private_key))
    net_name            = openstack_networking_network_v2.cluster.name
    sec_groups          = openstack_networking_secgroup_v2.cluster.name
    floating_ip_pool    = var.external_network_name
    ssh_user            = var.ssh_user
    boot_from_volume    = true
    volume_size         = tostring(var.worker_disk_size)
    active_timeout      = "300"
  }
}

# -----------------------------------------------------------------------------
# RKE2 Cluster
# -----------------------------------------------------------------------------

resource "rancher2_cluster_v2" "cluster" {
  name                         = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  cloud_credential_secret_name = rancher2_cloud_credential.openstack.id

  rke_config {
    # Control plane pool
    machine_pools {
      name                         = "control-plane"
      cloud_credential_secret_name = rancher2_cloud_credential.openstack.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = var.cp_count

      machine_config {
        kind = rancher2_machine_config_v2.control_plane.kind
        name = rancher2_machine_config_v2.control_plane.name
      }
    }

    # Worker pool
    machine_pools {
      name                         = "worker"
      cloud_credential_secret_name = rancher2_cloud_credential.openstack.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = var.worker_count

      machine_config {
        kind = rancher2_machine_config_v2.worker.kind
        name = rancher2_machine_config_v2.worker.name
      }
    }

  }

  depends_on = [
    openstack_networking_router_interface_v2.cluster,
  ]
}
