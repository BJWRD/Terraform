terraform {
  required_version = "~>1.3.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50.0"
    }
  }

  backend "s3" {
    bucket = "jenkins-tfstate-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }

}