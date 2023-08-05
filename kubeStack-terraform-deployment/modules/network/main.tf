################################################################################
# Base AWS VPC Deployment Module
################################################################################
# Local variables to be used in the module
locals {
  tags = var.tags
}

data "aws_availability_zones" "available" {}

#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = local.tags
}

#Public Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  for_each                = var.public_subnet_ids
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = "true" #makes this a public subnet

  tags = local.tags
}

#Private Subnets
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  for_each          = var.private_subnet_ids
  availability_zone = each.key
  cidr_block        = each.value

  tags = local.tags
}

#Internet NAT Gateway - Public
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = local.tags
}


#Elastic IP 
resource "aws_eip" "main" {
  domain   = "vpc"
  for_each = var.private_subnet_ids

  tags = local.tags
}

#Internet NAT Gateway - Private
resource "aws_nat_gateway" "private" {
  for_each = var.public_subnet_ids

  connectivity_type = "public"
  allocation_id     = aws_eip.main[each.key].id
  subnet_id         = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.public]

  tags = local.tags
}

#Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.public.id
  }

  tags = local.tags
}

#Private Route Table
resource "aws_route_table" "private" {
  vpc_id   = aws_vpc.main.id
  for_each = var.private_subnet_ids

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.private[each.key].id
  }

  tags = local.tags
}

#Route Table Association - Public
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_ids
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

#Route Table Association - Private
resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_ids
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

#Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = "kubestack.com"

  tags = local.tags
}

#Route53 DNS CNAME Record - Rancher
resource "aws_route53_record" "rancher" {
  zone_id = aws_route53_zone.main.id
  name    = "rancher.terraform.eks.cluster.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["Enter the Load Balancer DNS here"]
}

#Route53 DNS CNAME Record - Harbor
resource "aws_route53_record" "harbor" {
  zone_id = aws_route53_zone.main.id
  name    = "harbor.kubestack.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["Enter the Load Balancer DNS here"]

#Route53 DNS CNAME Record - Keycloak
resource "aws_route53_record" "keycloak" {
  zone_id = aws_route53_zone.main.id
  name    = "keycloak.kubestack.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["Enter the Load Balancer DNS here"]

#Route53 DNS CNAME Record - Grafana
resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.main.id
  name    = "grafana.kubestack.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["Enter the Load Balancer DNS here"]

#Route53 DNS CNAME Record - Prometheus
resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.id
  name    = "prometheus.kubestack.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["Enter the Load Balancer DNS here"]
}
