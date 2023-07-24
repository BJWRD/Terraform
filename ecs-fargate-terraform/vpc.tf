locals {
  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

provider "aws" {
  region = var.region
}

#VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

#Subnets
data "aws_subnet" "main" {
  id = var.subnet_ids[0]
}

#Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id

  tags = local.tags
}

#Route Table
resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.main.id
  }

  tags = local.tags
}

#Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = data.aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

#Application Load Balancer
resource "aws_lb" "main" {
  name               = var.ecs_alb
  internal           = var.alb_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = local.tags
}

#Application Load Balancer Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = var.alb_listener_type
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = local.tags
}

#Application Load Balancer Target Group
resource "aws_lb_target_group" "main" {
  name        = var.alb_target_group
  port        = var.alb_target_group_port
  protocol    = var.alb_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path     = var.alb_target_group_path
    interval = var.alb_target_group_interval
    timeout  = var.alb_target_group_timeout
  }

  tags = local.tags
}

#ALB Security Group
resource "aws_security_group" "alb" {
  name        = var.alb_security_group
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }
}

#ECS Security Group
resource "aws_security_group" "ecs" {
  name        = var.ecs_security_group
  description = "Security Group for ECS Container"
  vpc_id      = var.vpc_id


  ingress {
    description     = "Allow inbound traffic from the load balancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = [var.cidr_block]
    #security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    description = "Allow EFS Connectivity"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }
}

#ECS Security Group
resource "aws_security_group" "efs" {
  name        = var.efs_security_group
  description = "Security Group for EFS File System"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow EFS Connectivity"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
}