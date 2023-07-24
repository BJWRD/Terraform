provider "aws" {
  region = "eu-west-2"
}

module "ec2" {
  source                 = "./modules/ec2"
  instance_count         = var.instance_count
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.subnet_id
  vpc_security_group_ids = module.security.vpc_security_group_ids
  project_name           = var.project_name
  environment            = var.environment
}

module "vpc" {
  source                   = "./modules/vpc"
  vpc_id                   = var.vpc_id
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  route_table_id           = var.route_table_id
  gateway_id               = var.gateway_id
  destination_cidr_block   = var.destination_cidr_block
  aws_subnet_public_subnet = var.aws_subnet_public_subnet
  subnet_id                = var.subnet_id
  az_public_subnet         = var.az_public_subnet
  project_name             = var.project_name
  environment              = var.environment
}

module "security" {
  source                      = "./modules/security"
  vpc_id                      = module.vpc.vpc_id
  app_instance_security_group = var.app_instance_security_group
  project_name                = var.project_name
  environment                 = var.environment
  cidr_blocks                 = var.cidr_blocks
}
