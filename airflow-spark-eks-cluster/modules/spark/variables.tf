variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources"
}

variable "access_cidrs" {
  type        = list(string)
  description = "A list of CIDRs to allow access to the cluster"
}

variable "hostname" {
  type        = string
  description = "The forward-facing hostname of the Kubernetes Cluster being deployed to"
}