


provider "opentelekomcloud" {
  access_key  = var.otc_access_key
  secret_key  = var.otc_secret_key
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  auth_url    = "https://iam.eu-de.otc.t-systems.com/v3"
}

resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"
  content = templatefile("${path.module}/kubeconfig.tmpl", {
    certificate_authority_data = opentelekomcloud_cce_cluster_v3.cluster.certificate_clusters[0].certificate_authority_data
    server                     = opentelekomcloud_cce_cluster_v3.cluster.certificate_clusters[0].server
    cluster_name               = var.cluster_name
    client_certificate_data    = opentelekomcloud_cce_cluster_v3.cluster.certificate_users[0].client_certificate_data
    client_key_data            = opentelekomcloud_cce_cluster_v3.cluster.certificate_users[0].client_key_data
  })
}