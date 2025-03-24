resource "tls_private_key" "cluster_keypair_gpu" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "opentelekomcloud_compute_keypair_v2" "cluster_keypair_gpu" {
  name       = "${var.cluster_name}-cluster-keypair"
  public_key = tls_private_key.cluster_keypair.public_key_openssh
}

resource "opentelekomcloud_kms_key_v1" "node_gpu_key" {
  key_alias       = "node-key"
  pending_days    = "7"
  key_description = "test key"
  realm           = "eu-de-01"
  is_enabled      = true

  tags = var.tags
}


resource "opentelekomcloud_cce_node_pool_v3" "cluster_node_pool" {
  cluster_id         = opentelekomcloud_cce_cluster_v3.cluster.id
  name               = "opentelekomcloud-cce-node-pool-test-gpu"
  flavor             = var.gpu_node_flavor
  initial_node_count = var.gpu_node_count
  availability_zone  = var.availability_zone
  key_pair           = opentelekomcloud_compute_keypair_v2.cluster_keypair_gpu.name
  os                 = var.gpu_node_os
  runtime            = "containerd"

  scale_enable             = true
  min_node_count           = var.autoscaler_node_min
  max_node_count           = var.autoscaler_node_max
  scale_down_cooldown_time = 15
  priority                 = 1
  user_tags                = var.tags
  docker_base_size         = 20

    taints {
      effect = "PreferNoSchedule"
      key    = "gpu-node"
      value  = "true"
    }

  root_volume {
    size       = 50
    volumetype = "SSD"
    kms_id     = opentelekomcloud_kms_key_v1.node_gpu_key[0].id
  }

  data_volumes {
    size       = var.node_storage_size
    volumetype = var.node_storage_type
    kms_id     = opentelekomcloud_kms_key_v1.node_gpu_key[0].id
  }

}