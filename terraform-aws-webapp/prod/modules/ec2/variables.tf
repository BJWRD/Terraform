variable "instance_count" {
  default = 1
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpc_security_group_ids" {
  type = string
}

variable "resource_tags" {
  description = "Tags to set for all EC2 resources"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type = string
  default = "aws_subnet.public_subnet.id"
}
