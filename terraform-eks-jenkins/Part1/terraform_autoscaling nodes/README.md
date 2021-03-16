asg_node_group
This module provisions nodes for your cluster by managing AWS auto scaling groups.

Features
Will manage spot or on demand instances.
Provisions an auto scaling group per availability zone, to support applications utilizing EBS volumes via PVC.
Prepares the auto scaling group(s) to be scaled by the cluster autoscaler.
Uses the official AWS EKS optimised Amazon Linux AMI

Usage
module "nodes" {
  source = "eks/aws//modules/aws_node_group"

  cluster_config     = module.cluster.config
  max_size           = 60
  instance_family    = "memory_optimized"
  instance_size      = "4xlarge"
}

Instance type Usage
There are two ways to choose the instance types launched by the autoscaling groups:

instance_family & instance_size

module "nodes" {
  source = "eks/aws//modules/aws_node_group"

  cluster_config     = module.cluster.config
  instance_family    = "compute_optimized"
  instance_lifecycle = "on_demand"
}

module "nodes" {
  source = "eks/aws//modules/aws_node_group"

  cluster_config     = module.cluster.config
  max_size           = 16
  instance_family    = "io_optimised"
  instance_size      = "xlarge"
  instance_types     = ["i3.xlarge", "i3en.xlarge"]
}

Security groups
The module automatically applies the node security group provided by the cluster module to each node. This allows access of the nodes to the control plane, and intra-cluster communication between pods running on the cluster.

If we need to add any additional security groups, e.g. for ssh access, configure security_groups with the security group ids.

SSH key
Set key_name to configure a ssh key pair.

Cloud config
The module will configure the instance user data to use cloud config to add each node to the cluster, via the eks bootsstrap script, as well as setting the instances name tag.

Bottlerocket
Bottlerocket is a free and open-source Linux-based operating system meant for hosting containers.

To use bottlerocket set the bottlerocket variable.

module "bottlerocket_nodes" {
  source = "eks/aws//modules/aws_node_group"

  cluster_config     = module.cluster.config
  bottlerocket       = true
}