
# **LLM Training Platform on Open Telekom Cloud**

This project contains Infrastructure as Code (IaC) written in Terraform for deploying a Kubernetes cluster on **Open Telekom Cloud (OTC)** to train a Large Language Model (LLM). The cluster is provisioned using Terraform, and the LLM application is deployed with a custom Helm chart.

---

## **Project Structure**
```
├── terraform-iac
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   ├── ...
├── helm/llm-application
│   ├── chart.yaml
│   ├── values.yaml
│   ├── templates/
└── README.md
```

---

## **Terraform Configuration**

### **Requirements**
| Name | Version |
|-------|---------|
| terraform | >= 1.2.0 |

---

### **Providers**
| Name | Version |
|-------|---------|
| opentelekomcloud | 1.36.33 |

---

### **variables.tf**  
Defines input variables for the Terraform configuration. Below are the key variables:

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `vpc_name` | string | Name of the VPC | `"dev_vpc"` |
| `tags` | map(string) | Common tags for project resources | `{}` |
| `vpc_cidr` | string | CIDR range of the VPC | `"10.0.0.0/16"` |
| `otc_access_key` | string | Open Telekom Cloud access key | - |
| `otc_secret_key` | string | Open Telekom Cloud secret key | - |
| `dns_config` | list(string) | List of DNS server IP addresses for all subnets | `["100.125.4.25", "100.125.129.199"]` |
| `cluster_name` | string | Name of the Kubernetes cluster | `"llm-cluster"` |
| `flavor_id` | string | ID of the Open Telekom Cloud flavor for the nodes | `"c3.large.2"` |
| `subnet_cidr` | string | CIDR range of the subnet | `"10.0.1.0/24"` |
| `availability_zone` | string | Availability zone for deploying the resources | `"eu-de-01"` |
| `region_name` | string | Open Telekom Cloud region name | `"eu-de"` |
| `domain_name` | string | Domain name for the Kubernetes cluster | `""` |
| `tenant_id` | string | Open Telekom Cloud tenant ID | `""` |
| `os` | string | Operating system for the Kubernetes nodes | `"EulerOS 2.9"` |
| `flavor` | string | Flavor for the Kubernetes nodes | `"s2.xlarge.2"` |
| `initial_node_count` | number | Initial number of nodes in the cluster | `2` |
| `gpu_node_storage_size` | number | Size of the GPU node storage in GB | `200` |
| `gpu_node_storage_type` | string | Type of storage volume for the GPU node (e.g., SSD, SATA) | `"SSD"` |
| `node_storage_size` | number | Size of the node storage in GB | `100` |
| `node_storage_type` | string | Type of storage volume for the node (e.g., SSD, SATA) | `"SSD"` |

---

### **output.tf**  
Defines the outputs of the Terraform configuration:

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `client_key_data` | Client key for the Kubernetes cluster | ✅ |
| `client_certificate_data` | Client certificate for the Kubernetes cluster | ✅ |
| `cluster_private_ip` | Private IP of the cluster | ❌ |
| `cluster_certificate_authority_data` | Certificate authority for the cluster | ✅ |
| `node_pool_keypair_name` | Name of the node pool keypair | ❌ |
| `node_pool_keypair_private_key` | Private key for the node pool | ✅ |
| `node_pool_keypair_public_key` | Public key for the node pool | ✅ |

---

## **Helm Chart Configuration**
The Helm chart is located in the `helm-chart` directory and is used to deploy the LLM training application on the Kubernetes cluster.

### **values.yaml**  
Defines the configuration values for the Helm chart:

| Key | Description | Default |
|-----|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repository | `registry.example.com/llm-training` |
| `image.tag` | Image tag | - |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `resources.requests.cpu` | CPU requests | `8` |
| `resources.requests.memory` | Memory requests | `32Gi` |
| `resources.requests.nvidia.com/gpu` | GPU requests | `1` |
| `resources.limits.cpu` | CPU limits | `16` |
| `resources.limits.memory` | Memory limits | `64Gi` |
| `resources.limits.nvidia.com/gpu` | GPU limits | `1` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `tolerations` | Node tolerations | `gpu-node` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class | `csi-disk` |
| `persistence.size` | Size of the persistent volume | `100Gi` |
| `persistence.volumeType` | Type of storage volume | `SAS` |
| `autoscaling.enabled` | Enable autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `100` |

---

## **Deployment Guide**

### **1. Configure Terraform Providers**
Before starting to apply the Terraform configuration, you need to provide credentials for Open Telekom Cloud to initialize the backend. Then, run the terraform init command to configure the backend:

```bash
export TF_VAR_otc_access_key=<your ACCESS KEY>
export TF_VAR_otc_secret_key=<your SECRET KEY>
```

```bash
cd terraform-iac
terraform init
```

### **2. Set Variables**
Create a `terraform.tfvars` file like this:
```hcl
vpc_name            = "dev_vpc"
vpc_cidr            = "10.0.0.0/16"
subnet_cidr         = "10.0.1.0/24"
availability_zone   = "eu-de-01"
region_name         = "eu-de"
domain_name         = "your_domain_name"
tenant_id           = "your_tenant_id"
```

### **3. Plan Terraform Deployment**
Check the configuration plan:
```bash
terraform plan -out=tf.plan
```

### **4. Apply Terraform Configuration**
Deploy infrastructure using Terraform:
```bash
terraform apply tf.plan
```
This command will generate a kubeconfig file, which you can use later to configure Kubernetes.

### **5. Set Kubeconfig Path**
Export the KUBECONFIG environment variable:
```bash
export KUBECONFIG=$(pwd)/kubeconfig
```
You can also copy the kubeconfig file to your $HOME/.kube/ directory:

```bash
cp $(pwd)/kubeconfig $HOME/.kube/config
```

## **Cluster Access**
To access the cluster, you may need to connect through a VPN or a private network solution. Once connected, you can interact with the cluster using kubectl:
```bash
kubectl get nodes
```


### **6. Deploy Helm Chart**
Install the Helm chart:
```bash
cd helm/llm-application
helm upgrade --install llm-application ./helm-chart
```

---

## **Cleanup**
To remove the deployment:
```bash
terraform destroy -auto-approve
```

---