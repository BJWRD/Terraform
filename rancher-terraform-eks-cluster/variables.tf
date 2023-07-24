variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default = {
    "Platform" = "rancher-terraform-eks-cluster"
  }
}

variable "cluster" {
  description = "The ID of the EKS Cluster"
  type        = string
  default     = "Rancher-Cluster"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.25"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "A list of CIDRs to allow access to the kubernetes control plane"
  type        = list(string)
}

variable "cidr_block" {
  description = "CIDR Range for cluster public & private subnets"
  type        = string
  default     = "0.0.0.0/0"
}

variable "nginx_additional_access_cidrs" {
  description = "A list of CIDRs to allow access to the cluster HTTP ingress, in addition to cluster_endpoint_public_access_cidrs"
  type        = list(string)
  default     = []
}

variable "node_group" {
  description = "Name of Arcus Instance"
  type        = string
  default     = "Primary"
}

variable "instance_types" {
  description = "A variable used to alter the type of instance created by the cluster for the resources being made"
  type        = list(string)
  default     = ["t2.xlarge"]
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
  default     = "ami-0cd581b47b849ce0a " #1.27 - ami-05cfe9967bd1de489 # 1.26 - ami-07ef8ebdaf2749119 - #1.25 - ami-0cd581b47b849ce0a 
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "The VPC Network Range"
  type        = string
  default     = "10.100.0.0/16"
}

variable "vpc_id" {
  description = "The VPC to be deployed"
  type        = string
  default     = "aws_vpc.main.id"
}

variable "public_subnet_ids" {
  description = "A list of public subnets inside the VPC"
  type        = map(string)
  default = {
    "eu-west-2a" : "10.100.7.0/24",
    "eu-west-2b" : "10.100.8.0/24",
    "eu-west-2c" : "10.100.9.0/24"
  }
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = map(string)
  default = {
    "eu-west-2a" : "10.100.10.0/24",
    "eu-west-2b" : "10.100.11.0/24",
    "eu-west-2c" : "10.100.12.0/24"
  }
}
