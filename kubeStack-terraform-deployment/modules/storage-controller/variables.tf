variable "cluster_oidc_provider_arn" {
  description = "ARN of the cluster's OIDC provider"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
}