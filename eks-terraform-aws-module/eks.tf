################################################################################
# eks.tf
################################################################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

locals {
  required_tags = {
    project     = "eks-aws-terraform-module"
    environment = "Dev"
  }
  cluster_name    = "eks-cluster-1"
  cluster_version = "1.24"
  ami_type        = "AL2_x86_64"
}

module "eks" {

  source          = "terraform-aws-modules/eks/aws"
  version         = "19.5.1"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  subnet_ids                     = module.vpc.private_subnets
  vpc_id                         = module.vpc.vpc_id
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = local.ami_type

  }

  eks_managed_node_groups = {
    worker_one = {
      name = "worker-node-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
    tags = local.required_tags

    worker_two = {
      name = "worker-node-2"

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
    tags = local.required_tags
  }
}