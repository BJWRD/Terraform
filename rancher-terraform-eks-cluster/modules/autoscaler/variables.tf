variable "cluster_id" {
  type        = string
  description = "ID of the cluster - Used for autodiscovery of node groups"
}

variable "cluster_oidc_provider_arn" {
  type        = string
  description = "ARN of the cluster's OIDC provider"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources"
}