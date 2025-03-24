
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

# How would you provide a monitoring solution for the cluster?

Monitoring (or observability in a broader context) can be achieved through four main areas:

## 1. Metrics
For metrics, we can use different tools at various levels (cluster, application, service, and container):

- **Node-level metrics** – Use **node-exporter** to collect metrics from nodes (CPU, memory, disk, etc.).
- **Cluster-level metrics** – Use **kube-state-metrics** to gather cluster state data (pod status, deployment state, etc.).
- **Container-level metrics** – Use **cAdvisor** to collect container-specific metrics (resource usage, container restarts, etc.).
- **Service-level metrics** – Use specific Prometheus exporters for different services:
  - MySQL → `mysql-exporter`
  - Postgres → `postgres-exporter`
  - RabbitMQ → `RabbitMQ exporter`
  - NVIDIA GPU → `nvidia gpu prometheus exporter`
  - …and more for other services.
- **Application-level metrics** – Use the **Prometheus SDK** to create custom application-level metrics and expose them through a `/metrics` endpoint.

---

## 2. Logs
For logging, we can use:

- **ELK Stack** (Elasticsearch, Logstash, Kibana) – For log aggregation, indexing, and visualization.
- **Loki** – For lightweight log aggregation and querying directly from Grafana.

---

## 3. Traces
For tracing, we can use:

- **Jaeger** – To track request flows and identify performance bottlenecks across microservices.

---

## 4. Alerts
For alerting, we can create alerts in **Alert Manager** and send notifications to different destinations like:

- Email  
- Slack  
- PagerDuty  
- Webhook endpoints  

---

## 5. Open Telekom Cloud (OTC) Solutions
OTC also provides native solutions for monitoring and logging:

- **ICAgent** – Helps collect logs and metrics, including:
  - Host metrics  
  - Container metrics  
  - Node logs  
  - Container logs  
  - Standard output logs  

- **Cloud Container Engine (CCE)** – Provides the Cloud Native Cluster Monitoring add-on to monitor custom metrics using Prometheus.

---

# How can the cluster be accessed without having it publicly available?
To access the cluster API without exposing it publicly, the client must be within the same VPC as the cluster. This can be achieved by using a VPN to connect to the internal network, which will allow secure access to the API server. Alternatively, if the client is in a different VPC, you can establish VPC peering between the client and the cluster VPCs to enable secure communication.

---

# How do we make sure that no vulnerabilities are present?
To ensure that no vulnerabilities are present, we need to address security at multiple layers — infrastructure, container images, cluster configuration, and application code.

## 1. Scan for Vulnerabilities in Docker Images
- Use a container vulnerability scanner (e.g., **Trivy**) to analyze Docker images before deployment and ensure no known vulnerabilities are present.  
- Follow **Dockerfile** and **Docker image** best practices.  

## 2. Follow Kubernetes Security Best Practices
- **Pod Security** – Apply **PodSecurity Standards** to restrict container privileges.  
- **RBAC (Role-Based Access Control)** – Follow the **Principle of Least Privilege (PoLP)** to limit permissions to the minimum required for each component.  

## 3. Secure Network Communication
- **Network Policies** – Define **NetworkPolicies** to control traffic between pods and namespaces.  
- **TLS for Encryption** – Use **mTLS (Mutual TLS)** to encrypt communication between services.  

## 4. Secrets and Sensitive Data Management
- Store and manage sensitive data securely using a secret manager like **HashiCorp Vault**.  

## 5. Automate Infrastructure Scanning
- Use infrastructure-as-code security scanners such as **tfsec** and **Checkov** to identify misconfigurations and security issues in Terraform code.  

## 6. Enforce Centralized Policy for Infrastructure
- Implement policy-based controls (e.g., **OPA** or **Kyverno**) to enforce security standards in cloud-native environments.  

## 7. Dependency Scanning
- Use tools like **Dependabot** or **Renovate** to detect and update vulnerable dependencies, images, and modules.  

## 8. Regularly Upgrade Cluster and Dependencies
- Keep Kubernetes clusters and dependencies up to date to mitigate vulnerabilities and benefit from security patches.  

## 9. Audit Logging and Monitoring
- Enable **Kubernetes audit logs** to track API calls, access attempts, and unusual behavior for early threat detection.  
- Set up a centralized monitoring and alerting system to detect and respond to security incidents in real time.  

---

# Which components need to be maintained and updated in order to keep everything up to date? How would you implement such a maintenance process?

To keep everything up to date, we can leverage auto-updater tools and integrate them into our pipeline, such as GitHub or ArgoCD, to automatically check for updates when possible. Tools like Dependabot and Renovate can help identify newer versions of dependencies in Terraform, Helm charts, container images, and more, creating merge requests (MRs) for review. If the updates are appropriate, we can apply them to our codebase.

For updating our environment, deployment strategies like blue-green and canary deployments can help achieve zero-downtime updates. It’s important to thoroughly test updates before applying them. Setting up a staging environment allows us to validate new versions and catch potential issues before deploying them to production.

After applying updates, monitoring performance and detecting issues are crucial. We can configure alerts for failed updates and performance drops to address issues promptly.

Regular backups of the cluster configuration and application state ensure that we can restore to a previous version if needed. Having a well-defined rollback strategy allows us to quickly revert to a stable state if updates cause issues.

It’s also important to plan updates and maintenance in advance and notify stakeholders, such as developers and users, about planned maintenance and potential impacts. Clear communication helps set expectations and avoid disruption.

While some parts of the process may need to be handled manually, automating as much as possible helps minimize human error and improve consistency.