################################################################################
# variables.tf
################################################################################

################################################################################
# variables.tf
################################################################################

variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default = {
    "Module"   = "ec2-ssm-terraform-module"
    "Platform" = "Platform-Deployment"
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "availability_zone" {
  description = "Availability Zone used"
  type        = string
  default     = "eu-west-2a"
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

variable "cidr_block" {
  description = "CIDR Range for cluster public & private subnets"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_subnet_ids" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.100.1.0/24"]
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.100.2.0/24"]
}

variable "ec2_id" {
  description = "Name of EC2 instance"
  type        = string
  default     = "SSM-Instance" # Update accordingly
}

variable "ami_type" {
  description = "AMI type"
  type        = string
  default     = "ami-09d6bbc1af02c2ca1"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.medium"
}

variable "security_group" {
  description = "Name of the EC2 Security Group"
  type        = string
  default     = "SSM-SG"
}
