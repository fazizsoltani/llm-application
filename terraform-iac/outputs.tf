output "client_key_data" {
  value     = opentelekomcloud_cce_cluster_v3.cluster.certificate_users[0].client_key_data
  sensitive = true
}

output "client_certificate_data" {
  value     = opentelekomcloud_cce_cluster_v3.cluster.certificate_users[0].client_certificate_data
  sensitive = true
}

output "cluster_private_ip" {
  value = opentelekomcloud_cce_cluster_v3.cluster.certificate_clusters[0].server
}

output "cluster_certificate_authority_data" {
  value     = opentelekomcloud_cce_cluster_v3.cluster.certificate_clusters[0].certificate_authority_data
  sensitive = true
}

output "node_pool_keypair_name" {
  value = opentelekomcloud_compute_keypair_v2.cluster_keypair.name
}

output "node_pool_keypair_private_key" {
  sensitive = true
  value     = tls_private_key.cluster_keypair.private_key_openssh
}

output "node_pool_keypair_public_key" {
  sensitive = true
  value     = tls_private_key.cluster_keypair.public_key_openssh
}