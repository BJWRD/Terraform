terraform {
  required_version = "~>1.3.6"

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
  }

  backend "s3" {
    bucket = "artifactory-terraform-eks-cluster"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
