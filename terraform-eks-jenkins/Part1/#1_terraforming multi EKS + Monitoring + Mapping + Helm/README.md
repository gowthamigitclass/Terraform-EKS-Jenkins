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
