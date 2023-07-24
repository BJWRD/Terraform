###########################################################################################################
# EKS Module 
###########################################################################################################

# Local variables to be used in the module
locals {
  tags = var.tags
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  config_path            = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.20.2"
  cluster_name    = var.cluster_id
  cluster_version = var.cluster_version
  subnet_ids      = var.public_subnet_ids #Change to private_subnet_ids if you have a VPC Endpoint configured

  vpc_id = var.vpc_id

  # Webhooks need access from control plane to node groups. This is a recommended configuration
  node_security_group_additional_rules = {
    control_plane_access = {
      description                   = "All access within cluster"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    all_self = {
      description = "All access within cluster"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = "true"
    }
    all_self_egress = {
      description = "All access within cluster"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = "true"
    }
  }

  eks_managed_node_groups = {
    Artifactory = {
      name           = var.node_group
      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }
  tags = local.tags
}

# Sets the AWS-hosted cluster authentication for later bolt-ons
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Calls the artifactory module, used to add Artifactory software to EKS cluster in AWS deployment
module "artifactory" {
  source = "./modules/artifactory"

  tags = local.tags
  depends_on = [
    module.eks
  ]
}

# Calls the encryption module, used to add security precautions in preparation for the EKS cluster in AWS deployment
module "encryption" {
  source                  = "./modules/encryption"
  cluster_iam_role_arn    = module.eks.cluster_iam_role_arn

  tags = local.tags
}

# Calls the network module, used to add the necessary infrastructure to an existing VPC to support an EKS cluster
module "network" {
  source                 = "./modules/network"
  vpc_id                 = var.vpc_id
  cluster_id             = var.cluster_id
  cidr_block             = var.cidr_block
  private_subnet_ids     = var.private_subnet_ids
  public_subnet_ids      = var.public_subnet_ids

  tags = local.tags
}

# Calls the storage-controller module, which adds an adaptive storage facility to the cluster
module "storage-controller" {
  source                        = "./modules/storage-controller"
  cluster_oidc_provider_arn     = module.eks.oidc_provider_arn

  tags = local.tags
  depends_on = [
    module.eks
  ]
}
}
