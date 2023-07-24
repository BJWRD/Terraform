################################################################################
# Network Module
################################################################################
# Local variables to be used in the module
locals {
  tags = var.tags
}

#VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

#Private Subnets
data "aws_subnet" "private" {
  id = var.private_subnet_ids[0]
}

#Public Subnets
data "aws_subnet" "public" {
  id = var.public_subnet_ids[0]
}

#Internet NAT Gateway - Public
resource "aws_internet_gateway" "public" {
  vpc_id = data.aws_vpc.main.id

  tags = local.tags
}

#NAT Gateway - Private
resource "aws_nat_gateway" "private" {
  connectivity_type = "private"
  subnet_id         = data.aws_subnet.private.id
}

#Public Route Table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.public.id
  }

  tags = local.tags
}

#Private Route Table
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.private.id
  }

  tags = local.tags
}

#Route Table Association - Public
resource "aws_route_table_association" "public" {
  subnet_id      = data.aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#Route Table Association - Private
resource "aws_route_table_association" "private" {
  subnet_id      = data.aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

#Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = "terraform-eks-cluster.com"

  tags = var.tags
}

#Route53 DNS CNAME Record
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.id
  name    = "artifactory.terraform-eks-cluster.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["ad2d55a275be14c3a8fc971238aa8c36-849296602.eu-west-2.elb.amazonaws.com"] #Enter the Load Balancer DNS here
}
