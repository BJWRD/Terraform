variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "The VPC to deploy into"
  type        = string
}

variable "vpc_cidr" {
  description = "The VPC Network Range"
  type        = string
}

variable "cluster_id" {
  description = "The cluster ID to associate with the subnets"
  type        = string
}

variable "cidr_block" {
  description = "CIDR Block for cluster public & private subnets. This will be cut into 8 equal subnets of which 6 will be allocated."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = map(string)
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = map(string)
}