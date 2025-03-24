variable "vpc_name" {
  type        = string
  description = "Name of the VPC."
}

variable "tags" {
  type        = map(string)
  description = "Common tag set for project resources."
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "IP range of the VPC in CIDR notation."
}

variable "otc_access_key" {
  type        = string
  description = "Open Telekom Cloud access key."
  sensitive = true
}

variable "otc_secret_key" {
  type        = string
  description = "Open Telekom Cloud secret key."
  sensitive = true
}

variable "dns_config" {
  type        = list(string)
  description = "List of DNS server IP addresses for all subnets."
  default = [
    "100.125.4.25",
    "100.125.129.199"
  ]
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster."
}

variable "flavor_id" {
  type        = string
  description = "ID of the Open Telekom Cloud flavor for the nodes."
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range of the subnet."
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for deploying the resources."
}

variable "region_name" {
  type        = string
  description = "Open Telekom Cloud region name."
}

variable "domain_name" {
  type        = string
  description = "Domain name for the Kubernetes cluster."
}

variable "tenant_id" {
  type        = string
  description = "Open Telekom Cloud tenant ID."
}

variable "os" {
  description = "Operating system for the Kubernetes nodes"
  type        = string
  default     = "EulerOS 2.9"
}

variable "flavor" {
  description = "Flavor for the Kubernetes nodes"
  type        = string
  default     = "s2.xlarge.2"
}

variable "initial_node_count" {
  description = "Initial number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "gpu_node_storage_size" {
  description = "Size of the GPU node storage in GB"
  type        = number
  default     = 200
}

variable "gpu_node_storage_type" {
  description = "Type of storage volume for the GPU node (e.g., SSD, SATA)"
  type        = string
  default     = "SSD"
}

variable "node_storage_size" {
  description = "Size of the GPU node storage in GB"
  type        = number
  default     = 100
}

variable "node_storage_type" {
  description = "Type of storage volume for the GPU node (e.g., SSD, SATA)"
  type        = string
  default     = "SSD"
}