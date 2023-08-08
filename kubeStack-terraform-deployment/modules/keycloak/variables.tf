# A variable to store the hostname of the machine
variable "hostname" {
  type        = string
  description = "The forward-facing hostname of the Kubernetes Cluster being deployed to"
}
