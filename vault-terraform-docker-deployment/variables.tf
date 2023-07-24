variable "project_name" {
  type    = string
  default = "vault"
}

variable "environment" {
  type    = string
  default = "prod"
}

#EC2 Module Variables
variable "ami_id" {
  type    = string
  default = "ami-00785f4835c6acf64"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "instance_count" {
  default = 1
}

#VPC Module Variables
variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "vpc_id" {
  type    = string
  default = "aws_vpc.vpc.id"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "route_table_id" {
  type    = string
  default = "aws_route_table.public.id"
}

variable "gateway_id" {
  type    = string
  default = "aws_internet_gateway.igw.id"
}

variable "destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "subnet_id" {
  type    = string
  default = "aws_subnet.public_subnet.id"
}

variable "az_public_subnet" {
  type = map(string)
  default = {
    "eu-west-2a" : "10.0.0.0/24",
    "eu-west-2b" : "10.0.1.0/24",
    "eu-west-2c" : "10.0.2.0/24"
  }
}

variable "aws_subnet_public_subnet" {
  type    = string
  default = "aws_subnet.public_subnet.id"
}

#Security Module Variables
variable "vpc_security_group_ids" {
  type    = string
  default = "aws_security_group.app_instance_sg.id"
}

variable "cidr_blocks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "app_instance_security_group" {
  type    = string
  default = "app-instance-security-group"
}
