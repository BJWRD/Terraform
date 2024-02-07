################################################################################
# versions.tf
################################################################################

terraform {
  required_version = "~>1.3.6"

  backend "s3" {
    bucket = "ec2-ssm-terraform-module-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

