# Parameterising clusters as Terraform modules

Pretty simple with terraform modules and expressions, I can refactor the code and extract the instance type as a variable without impacting overal acrhitecture. 

Since the module is reusable, I can create more than a single cluster. In the root main.tf I can reference to that module with proper source (./cluster).

I am able to provision multiple EKS clusters with a single terraform apply command:

```
terraform init
terraform plan
terraform apply
```
It might take a while for the clusters to be created (up to 15 minutes).

*1 cluster for development*

*1 cluster for staging*

*1 cluster for production*

In the same folder you will find a kubeconfig file for each cluster.

```
For example, I want to run smaller instances such as t2.micro in dev and staging and leave the m5.large instance type for production. Like wise, I can modify for security groups, subnets and many other.
```

### Some more info:
Terraform file that I created here is divided into several blocks. Please find the brief of each module:

#### First part is to install the ALB Ingress controller using HELM provider. The actual ALB Ingress Controller (the Kubernetes resources such as Pod, ConfigMaps, etc.) can be installed with Helm as a package manager.
There're two crucial steps that you need to complete to install the controller:
* Grant the relevant permissions to the worker nodes.
* Install the Kubernetes resources (such as Deployment, Service, ConfigMap, etc.) necessary to install the controller.
#### Monioring and Mapping part. In this part, I instruct terraform to create:
* EKS k8 role mapping
* configure the worker nodes IAM roles to have access
* IAM role to K8 role mapping vie avriable
* Cloudwatch monitoing modules and resources
#### VPC module part. In this part, I instruct Terraform to create:
* A VPC.
* Three private and three public subnets.
* A single NAT gateway.
* Tags for the subnets.
* The tags for subnets are quite crucial as those are used by AWS to automatically provision public and internal load balancers in the appropriate subnets.

#### EKS cluster module.The EKS module is responsible of:

* Creating the control plane.
* Setting up autoscaling groups.
* Setting up the proper security groups.
* Creating the kubeconfig file, etc..
Also, the worker nodes for our Kubernetes cluster should be deployed in the private subnets.

#### The final part of the terrafomr file is to:
* Set up the right permissions to connect to the cluster.
* Poll the cluster to make sure it's ready. 

All three cluster have the ALB Ingress Controller installed, so they are ready to handle the production traffic.
