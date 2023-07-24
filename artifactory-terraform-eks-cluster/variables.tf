variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default = {
    "Environment"  = "Dev"
    "Project_Name" = "artifactory-terraform-eks-cluster"
  }
}

variable "cluster_id" {
  description = "The ID of the EKS Cluster to create"
  type        = string
  default     = "Artifactory-Cluster"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.26"
}

variable "cidr_block" {
  description = "CIDR Range for cluster public & private subnets"
  type        = string
  default     = "0.0.0.0/0"
}

variable "node_group" {
  description = "Name of Artifactory Instance"
  type        = string
  default     = "Artifactory"
}

variable "instance_types" {
  description = "A variable used to alter the type of instance created by the cluster for the resources being made"
  type        = list(string)
  default     = ["t2.small"]
}

variable "capacity_type" {
  description = "Type of Cluster Instance used"
  type        = string
  default     = "SPOT"
}

variable "ami_type" {
  description = "Amazon Machine Image Type"
  type        = string
  default     = "AL2_x86_64"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
  default     = "ami-07ef8ebdaf2749119"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "The VPC to deploy into"
  type        = string
  default     = "vpc-bb0a42d3"
}

variable "private_subnet_ids" {
  description = "subnet IDs which resources will be launched in"
  type        = list(string)
  default     = ["subnet-0b42cdef7145e6f8c", "subnet-06abc783c2b177896", "subnet-0ef45509bbb6c650b"]
}

variable "public_subnet_ids" {
  description = "subnet IDs which resources will be launched in"
  type        = list(string)
  default     = ["subnet-4b7bd607", "subnet-34d7494e", "subnet-842072ed"]
}

