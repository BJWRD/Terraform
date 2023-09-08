###########################################################################################################
# EKS Module 
###########################################################################################################

# Local variables to be used in the module
locals {
  tags = var.tags
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  config_path            = "/root/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "rancher2" {
  api_url   = "https://${kubernetes_config_map.cluster-info.data["ingress_hostname"]}"
  bootstrap = true
  insecure  = true
}

module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.20.2"
  cluster_name    = var.cluster
  cluster_version = var.cluster_version
  subnet_ids      = [for sn in module.network.private_subnets : sn.id]

  vpc_id = module.network.vpc_id


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
    for subnet in module.network.private_subnets: 
    "Primary-${subnet.availability_zone}" => {
      subnet_ids = [subnet.id]
      name           = var.node_group
      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      min_size     = 1
      max_size     = 5
      desired_size = 1
    }
  }
  tags = local.tags
}

# Sets the AWS-hosted cluster authentication for later bolt-ons
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

# Calls the rancher module, used to add K8s management & Fleet platform.
module "rancher" {
  source   = "./modules/rancher"
  hostname = "rancher.terraform-eks-cluster.com"

  depends_on = [
    module.eks_cluster
  ]
}

# Calls the network module, used to add the necessary infrastructure to an existing VPC to support an EKS cluster
module "network" {
  source             = "./modules/network"
  vpc_id             = var.vpc_id
  vpc_cidr           = var.vpc_cidr
  cluster_id         = var.cluster
  cidr_block         = var.cidr_block
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  tags = local.tags
}

# Calls the autoscaler module, which adds a Helm Autoscaler to the cluster
module "autoscaler" {
  source                    = "./modules/autoscaler"
  cluster_id                = module.eks_cluster.cluster_id
  cluster_oidc_provider_arn = module.eks_cluster.oidc_provider_arn

  tags = local.tags
  depends_on = [
    module.eks_cluster
  ]
}

# Calls the ingress module, which adds the ability to host webpages and resources across the cluster through one path
module "ingress" {
  source = "./modules/ingress"
  # Note - We require access from the VPC CIDR Block so that the Network Load Balancer can perform health checks.
  access_cidrs      = concat(var.cluster_endpoint_public_access_cidrs, var.nginx_additional_access_cidrs, [var.cidr_block, format("%s/32", join(",", module.network.external_nat_ip))])

  tags = local.tags
  depends_on = [
    module.eks_cluster
  ]
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

# Resource that holds the information of the kubernets cluster when deployed, used for outputs and bolt-on modules
resource "kubernetes_config_map" "cluster-info" {
  metadata {
    name      = "cluster-info"
    namespace = "default"
  }
  data = {
    "ingress_hostname"          = module.ingress.hostname
    "cluster_oidc_provider_arn" = module.eks_cluster.oidc_provider_arn
    "cluster_id"                = "${var.cluster}"
  }
}
