#variable "aws_region" {
# description = "The AWS region in which all resources will be created"
#  type        = string
#}

#variable "cluster_name" {
#  description = "The name of the EKS cluster"
#  type        = string
#}

#variable "iam_role_to_rbac_group_mappings" {
#  description = "Mapping of AWS IAM roles to RBAC groups, where the keys are the AWS ARN of IAM roles and the values are the mapped k8s RBAC group names as a list."
#  type        = map(list(string))
#  default     = {}
#}
