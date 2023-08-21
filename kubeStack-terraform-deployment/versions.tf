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

    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.3.1"
    }

    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 3.0.1"
    }
    
    harbor = {
      source = "goharbor/harbor"
      version = ">= 3.9.4"
    }

  }

  backend "s3" {
    bucket = "kubeStack-terraform-deployment"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
