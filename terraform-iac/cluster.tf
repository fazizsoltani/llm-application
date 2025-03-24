
resource "opentelekomcloud_cce_cluster_v3" "cluster" {
  name                    = var.cluster_name
  cluster_type            = "VirtualMachine"
  flavor_id               = var.flavor_id
  vpc_id                  = opentelekomcloud_vpc_v1.vpc.id
  subnet_id               = opentelekomcloud_vpc_subnet_v1.kubernetes_subnet.network_id
  container_network_type  = "eni"
  kubernetes_svc_ip_range = "10.247.0.0/16"
  ignore_addons           = true
  eni_subnet_id           = opentelekomcloud_vpc_subnet_v1.kubernetes_subnet.subnet_id
  eni_subnet_cidr         = opentelekomcloud_vpc_subnet_v1.kubernetes_subnet.cidr
  annotations            = { "cluster.install.addons.external/install" = "[{\"addonTemplateName\":\"icagent\"}]" } # install ICAgent

  masters {
    availability_zone = "${var.region_name}-01"
  }
  masters {
    availability_zone = "${var.region_name}-02"
  }
  masters {
    availability_zone = "${var.region_name}-03"
  }

}

resource "opentelekomcloud_kms_key_v1" "node_key" {
  key_alias       = "node-key"
  pending_days    = "7"
  key_description = "test key"
  realm           = "eu-de-01"
  is_enabled      = true

  tags = var.tags
}

resource "tls_private_key" "cluster_keypair" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "opentelekomcloud_compute_keypair_v2" "cluster_keypair" {
  name       = "${var.cluster_name}-cluster-keypair"
  public_key = tls_private_key.cluster_keypair.public_key_openssh
}

resource "opentelekomcloud_cce_node_pool_v3" "node_pool_1" {
  cluster_id         = opentelekomcloud_cce_cluster_v3.cluster.id
  name               = "opentelekomcloud-cce-node-pool-test"
  os                 = var.os
  flavor             = var.flavor
  initial_node_count = var.initial_node_count
  availability_zone  = var.availability_zone
  key_pair           = opentelekomcloud_compute_keypair_v2.cluster_keypair.name

  scale_enable             = true
  min_node_count           = 2
  max_node_count           = 9
  scale_down_cooldown_time = 100
  priority                 = 1
  runtime                  = "containerd"
  agency_name              = "test-agency"

  root_volume {
    size       = 40
    volumetype = "SSD"
    kms_id     = opentelekomcloud_kms_key_v1.node_key[0].id

  }
  data_volumes {
    size       = var.node_storage_size
    volumetype = var.node_storage_type
    kms_id     = opentelekomcloud_kms_key_v1.node_key[0].id
  }
}

