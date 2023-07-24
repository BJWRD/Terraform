variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
}

variable "cluster_iam_role_arn" {
  description = "ARN of the iam role for the cluster to use decrypting secrets"
  type        = string
}

