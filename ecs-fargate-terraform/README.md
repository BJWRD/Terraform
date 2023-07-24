# ecs-fargate-terraform
An ECS/Fargate Jenkins Container solution. The container logs are exported to Cloudwatch; permissions are managed via IAM roles/policies and the container uses EFS for additional storage - provisioned via Terraform.

# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS EC2 key pair - [steps](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
* Environment Variables for AWS CLI - [steps](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* tfupdate installation - [steps](https://github.com/antonbabenko/pre-commit-terraform#how-to-install)
* tfsec installation - [steps](https://github.com/antonbabenko/pre-commit-terraform#how-to-install)

# How to Apply/Destroy
This section details the deployment and teardown of the three-tier-architecture. **Warning: this will create AWS resources that costs money**

## Deployment Steps

#### 1.	Clone the repo
    git clone https://github.com/BJWRD/Terraform/ecs-fargate-terraform && cd ecs-fargate-terraform
    
#### 2. Update the s3 bucket name to your own - `versions.tf`

    backend "s3" {
      bucket = "ENTER HERE"
      key    = "terraform.tfstate"
      region = "eu-west-2"
    }
    

#### 3. Update `versions.tf`
    tfupdate terraform versions.tf && tfupdate provider aws versions.tf
    
#### 4.	Initialise the TF directory
    terraform init

#### 5. VPC & Subnet Updates
Update both the VPC and Subnet variables within the `variables.tf`file - with your own VPC and Subnet ID's.

#### 6. Ensure the terraform code is formatted and validated 
    terraform fmt && terraform validate

#### 7. `tfsec` - vulnerability check
    tfsec
    
#### 8. Create an execution plan
    terraform plan

#### 9. Execute terraform configuration 
    terraform apply --auto-approve
    
<img width="521" alt="image" src="https://user-images.githubusercontent.com/83971386/224559680-dcb6b91c-6ed2-42d4-aa06-3ffd2ce7b9f4.png">


## Verification Steps 

#### 1. Check AWS Infrastructure
Check the infrastructure deployment status, by enter the following terraform command -

     terraform show

<img width="521" alt="image" src="https://user-images.githubusercontent.com/83971386/224559718-b917bcbf-29dd-4ef1-bfa8-13d8a57caea4.png">

**NOTE:** You may want to ouput `terraform show` to a .txt file for easier viewing i.e. terraform show > tf_infrastructure.txt

Alternatively, log into the AWS Console and verify your AWS infrastructure deployment from there.

#### ECS Verification

<img width="633" alt="image" src="https://user-images.githubusercontent.com/83971386/224559972-bcf8cb2a-001a-47c4-a65a-c3654af3b74b.png">

#### EFS Verification

<img width="653" alt="image" src="https://user-images.githubusercontent.com/83971386/224560002-0ea0b114-fac2-49aa-8b0a-f6d0fead00fe.png">

#### Cloudwatch Verification

<img width="568" alt="image" src="https://user-images.githubusercontent.com/83971386/224560045-15d180fe-9ee1-4c75-9c32-4226f8cfe470.png">

#### 2. Verify Application accessibility 
Access the ECS Container's external link and search within your browser to access the Jenkins application -

<img width="627" alt="image" src="https://user-images.githubusercontent.com/83971386/224561337-7bc623ed-95ce-436d-8888-827de6f680e9.png">

<img width="719" alt="image" src="https://user-images.githubusercontent.com/83971386/224560457-3c22207f-8f8a-4f2c-9466-932f2ca4085d.png">

## Teardown Steps

####  1. Destroy the deployed AWS Infrastructure 
`terraform destroy --auto-approve`

<img width="394" alt="image" src="https://user-images.githubusercontent.com/83971386/224560852-57f09123-93b3-4f64-9652-cd5ad26c9e8e.png">

## Requirements
| Name          | Version       |
| ------------- |:-------------:|
| [terraform](https://registry.terraform.io)     | ~>1.3.9       |
| [aws](https://registry.terraform.io/providers/hashicorp/aws)         | ~>3.50.0      |

## Providers
| Name          | Version       |
| ------------- |:-------------:|
| [aws](https://registry.terraform.io/providers/hashicorp/aws)           | ~>3.50.0      |

## Data Blocks
| Name          | Type       |
| ------------- |:-------------:|
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_vpc) | Data |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_subnet) | Data |

## Resources
| Name          | Type       |
| ------------- |:-------------:|
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_internet_gateway) | resource |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route_table) | resource |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route_table_association) | resource |
| [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_lb) | resource |
| [aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_lb_listener) | resource |
| [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_lb_target_group) | resource |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_security_group) | resource |
| [aws_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_ecs_cluster) | resource |
| [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_ecs_task_definition) | resource |
| [aws_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_ecs_service) | resource |
| [aws_efs_file_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_efs_file_system) | resource |
| [aws_efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_efs_mount_target) | resource |
| [aws_efs_access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_efs_access_point) | resource |
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_cloudwatch_log_stream) | resource |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_iam_role) | resource |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_iam_policy) | resource |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_iam_role_policy_attachment) | resource |

