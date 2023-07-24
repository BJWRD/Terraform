locals {
  name_suffix = "${var.project_name}-${var.environment}"
}

locals {
  required_tags = {
    project     = var.project_name,
    environment = var.environment,
  }
  tags = merge(var.resource_tags, local.required_tags)
}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(local.tags, { Name = "VPC" })
}

#Internet gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "Internet-Gateway" })
}

#Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  for_each                = var.az_public_subnet
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = "true" #makes this a public subnet

  tags = merge(local.tags, { Name = "Public-Subnet" })
}

# Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, { Name = "Public-Route-Table" })
}

#aws_route adds a route to the aws_route_table
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.igw.id
}

#Route table associations
resource "aws_route_table_association" "public" {
  for_each       = var.az_public_subnet
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public.id
}
