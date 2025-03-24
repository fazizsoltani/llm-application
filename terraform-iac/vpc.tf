
resource "opentelekomcloud_vpc_v1" "vpc" {
  name = var.vpc_name
  cidr = var.vpc_cidr
  tags = var.tags
}

resource "opentelekomcloud_vpc_subnet_v1" "kubernetes_subnet" {
  name   = "kubernetes_subnet"
  cidr   = var.subnet_cidr
  vpc_id = opentelekomcloud_vpc_v1.vpc.id

  gateway_ip    = cidrhost(var.subnet_cidr, 1)
  ntp_addresses = "10.100.0.33,10.100.0.34"
  tags          = var.tags
}