terraform {
  required_version = "~>1.5.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }

    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }

  }

  backend "s3" {
    bucket = "rancher-terraform-eks-cluster"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
