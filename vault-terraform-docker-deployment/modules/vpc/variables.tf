variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "az_public_subnet" {
  type = map(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "route_table_id" {
  type = string
}

variable "gateway_id" {
  type = string
}

variable "destination_cidr_block" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "aws_subnet_public_subnet" {
  type = string
}

variable "resource_tags" {
  description = "Tags to set for RDS resource"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}
