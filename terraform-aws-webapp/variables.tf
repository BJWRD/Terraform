variable "project_name" {
  type    = string
  default = "bradwhitcomb.com"
}

variable "environment" {
  type    = string
  default = "prod"
}

#EC2 Module Variables
variable "image_id" {
  type    = string
  default = "ami-00785f4835c6acf64"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "name_prefix" {
  type    = string
  default = "app-launch-template"
}

variable "id_app" {
  type    = string
  default = "aws_launch_template.app_launch_template.id"
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

variable "load_balancer_type" {
  type    = string
  default = "application"
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

variable "az_private_subnet" {
  type = map(string)
  default = {
    "eu-west-2a" : "10.0.101.0/24",
    "eu-west-2b" : "10.0.102.0/24",
    "eu-west-2c" : "10.0.103.0/24"
  }
}
}

variable "aws_subnet_public_subnet" {
  type    = string
  default = "aws_subnet.public_subnet.id"
}

variable "aws_subnet_private_subnet" {
  type    = string
  default = "aws_subnet.private_subnet.id"
}

variable "app_alb_lb" {
  type    = string
  default = "app-alb-lb"
}

variable "app_target_group" {
  type    = string
  default = "app-target-group"
}

variable "app_autoscaling_group" {
  type    = string
  default = "app-autoscaling-group"
}

#Security Module Variables
variable "vpc_security_group_ids" {
  type    = string
  default = "aws_security_group.app_instance_sg.id"
}

variable "security_group_app" {
  type    = string
  default = "aws_security_group.alb_app_http.id"
}

variable "cidr_blocks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "security_group_alb_app_http" {
  type    = string
  default = "aws_security_group.alb_app_http.id"
}

variable "aws_security_group_db_security_group" {
  type    = string
  default = "aws_security_group_db_security_group.id"
}

variable "alb_app_security_group" {
  type    = string
  default = "alb-app-security-group"
}

variable "app_instance_security_group" {
  type    = string
  default = "app-instance-security-group"
}
