################################################################################
# Network Module
################################################################################
# Local variables to be used in the module
locals {
  tags = var.tags
}

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(local.tags, { Name = "ec2-ssm-terraform-module" })
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zone
  cidr_block              = var.public_subnet_ids[0]
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "Public-Subnet" })
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block        = var.private_subnet_ids[0]

  tags = merge(local.tags, { Name = "Private-Subnet" })
}

# Internet NAT Gateway - Public
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = "IGW-platform-deployment" })
}

# Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"

  tags = merge(local.tags, { Name = "EIP-platform-deployment" })
}

# Internet NAT Gateway - Private
resource "aws_nat_gateway" "private" {
  connectivity_type = "public"
  allocation_id     = aws_eip.main.id
  subnet_id         = aws_subnet.public.id

  depends_on = [aws_internet_gateway.public]

  tags = merge(local.tags, { Name = "NGW-platform-deployment" })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.public.id
  }

  tags = merge(local.tags, { Name = "PublicRT-platform-deployment" })
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.private.id
  }

  tags = merge(local.tags, { Name = "PrivateRT-platform-deployment" })
}

# Route Table Association - Public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route Table Association - Private
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

