variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default = {
    "Platform" = "airflow-spark-eks-cluster"
  }
}

variable "cluster" {
  description = "The ID of the EKS Cluster"
  type        = string
  default     = "airflow-spark-eks-cluster"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "A list of CIDRs to allow access to the kubernetes control plane"
  type        = list(string)

  default = [
  "0.0.0.0/0"]
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
  default     = "ON_DEMAND"
}

variable "eks_node_storage" {
  description = "Node Disk Size"
  type = number
  default = 100
}

variable "ami_type" {
  description = "Amazon Machine Image Type"
  type        = string
  default     = "AL2_x86_64"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
  default     = "ami-02330eda12049c1e0"
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
