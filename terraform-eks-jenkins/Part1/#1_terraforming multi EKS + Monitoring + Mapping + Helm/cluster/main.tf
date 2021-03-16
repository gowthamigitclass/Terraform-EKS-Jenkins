provider "aws" {
  region = "ap-south-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

variable "cluster_name" {
  default = "our-cluster"
}

variable "instance_type" {
  default = "m5.large"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.47.0"

  name                 = "k8s-${var.cluster_name}-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "12.2.0"

  cluster_name    = "eks-${var.cluster_name}"
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = var.instance_type
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy-${var.cluster_name}"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

###Monitoring and Mapping section
module "cloudwatch_log_aggregation" {
  source  = "cn-terraform/cloudwatch-logs/aws"
  version = "1.0.7"
  name_prefix = var.cluster_name
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_log_aggregation_policy" {
  name       = "attach-cloudwatch-log-aggregation-policy"
  roles      = [module.eks.eks_worker_iam_role_name]
  policy_arn = module.cloudwatch_log_aggregation.cloudwatch_log_aggregation_policy_arn
}

module "cloudwatch_metrics" {
  source  = "cn-terraform/cloudwatch-logs/aws"
  name_prefix = var.cluster_name
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_metrics_policy" {
  name       = "attach-cloudwatch-metrics-policy"
  roles      = [module.eks.eks_worker_iam_role_name]
  policy_arn = module.cloudwatch_metrics.cloudwatch_metrics_policy_arn
}

module "eks_k8s_role_mapping" {
  source = "terraform-aws-modules/eks/aws"
  version = "14.0.0"
  # This will configure the worker nodes' IAM role to have access to the system:node Kubernetes role
  eks_worker_iam_role_arns = [module.eks.eks_worker_iam_role_arn]

  # The IAM role to Kubernetes role mappings are passed in via a variable
  iam_role_to_rbac_group_mappings = var.iam_role_to_rbac_group_mappings

  config_map_labels = {
    eks-cluster = module.eks.eks_cluster_name
  }
}

provider "helm" {
  version = "1.3.1"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-alb-ingress-controller"
  repository = "https://charts.helm.sh/stable"
  version    = "2.17.0"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}