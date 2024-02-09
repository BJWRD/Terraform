# ec2-ssm-terraform-module

# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS EC2 key pair - [steps](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

# How to Apply/Destroy
This section details the deployment and teardown of the three-tier-architecture. **Warning: this will create AWS resources that costs money**

## Deployment steps

### Applying the Terraform Configuration

#### 1.	Clone the repo

    git clone https://github.com/BJWRD/Terraform && cd ec2-ssm-terraform-module
    
#### 2. Update the vpc_id variable to your own VPC ID - `variables.tf`

    variable "vpc_id" {
        description = "The VPC to deploy into"
        type        = string
        default     = "ENTER HERE"
    }
    
#### 3. Update the s3 bucket name to your own - `versions.tf`

    backend "s3" {
      bucket = "ENTER HERE"
      key    = "terraform.tfstate"
      region = "eu-west-2"
    }

#### 4. Update the Security Group Ingress
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [""] # Update to your own current IP Address
    } 

#### 5. AZ & Region Updates

Finally, update all area's of code which include the AWS Availability Zones & Regions to values that are specific to your own requirements.

#### 6.	Initialise the TF directory

    terraform init

#### 7.	 Ensure the terraform code is formatted and validated 

    terraform fmt && terraform validate

#### 8.	Create an execution plan

    terraform plan

#### 9.	Execute terraform configuration - Creating the EC2 Infrastructure

    terraform apply --auto-approve
    
## Verification Steps 

#### 1. Check AWS Infrastructure
Check the infrastructure deployment status, by enter the following terraform command -

     terraform show

Alternatively, log into the AWS Console and verify your AWS infrastructure deployment from there.

## Teardown steps

#### 1.	Destroy the deployed AWS Infrastructure 
`terraform destroy --auto-approve`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2/aws | ~> 3.0 |
| <a name="module_ec2"></a> [network](#module\_ec2) | ec2-ssm-terraform-module/modules/network | ~> N/A |
| <a name="module_ec2"></a> [ssm](#module\_ec2) | ec2-ssm-terraform-module/modules/ssm | ~> N/A |
