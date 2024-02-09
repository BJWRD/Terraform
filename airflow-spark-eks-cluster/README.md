# kubeStack-terraform-deployment
An EKS Cluster using Airflow/Spark to perform DAG runs on an S3 Bucket - provisioned via IAC (Terraform).

# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Environment Variables for AWS CLI - [steps](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* S3 Buckets x3 - (tfstate file hosting, Airflow DAG logging, CSV file updates)
* AWS CodeCommit Repository
* Elastic Container Registery to host your Docker Image for the Airflow Chart to then use for Airflow Deployment.

# How to Apply/Destroy
This section details the deployment and teardown of the kubeStack EKS Cluster. **Warning: this will create AWS resources that costs money**

## Deployment Steps

#### 1.	Clone the repo
    git clone https://github.com/BJWRD/Terraform && cd airflow-spark-eks-cluster
    
#### 2. Update the s3 bucket name to your own - `versions.tf`

    backend "s3" {
      bucket = "ENTER HERE"
      key    = "terraform.tfstate"
      region = "eu-west-2"
    }
    
#### 3. Update the Airflow Helm Chart Values
Alter the Airflow Helm Chart Values accordingly inline with your AWS CodeCommit Repository and your ECR config.

#### 4. Update the EKS / Helm Chart versions if required.

#### 5. Update `versions.tf`
    tfupdate terraform versions.tf && tfupdate provider aws versions.tf
    
#### 6.	Initialise the TF directory
    terraform init

#### 7. Ensure the terraform code is formatted and validated 
    terraform fmt && terraform validate

#### 8. Create an execution plan
    terraform plan

#### 9. Execute terraform configuration 
    terraform apply --auto-approve

## Terraform Verification Steps

#### 1. Check AWS Infrastructure
Check the infrastructure deployment status, by enter the following terraform command -

     terraform show

Alternatively, view the resources directly via the AWS GUI.

#### 2. Check K8s Infrastructure
Check the K8s infrastructure deployment status, by enter the following commands -

    aws eks update-kubeconfig --name airflow-spark-eks-cluster && kubectl get all --all-namespaces

#### 3. Verify Application accessibility 
Access the respective Application DNS's below -

``airflow.kubestack.com``
``spark.kubestack.com``

**NOTE:** Ensure the Route53 DNS record entered, includes the latest LB URL

## Further Deployment Steps

## Kubernetes Secret Creations

## Docker Image Build & Push

## DAG Runs

## Airflow/Spark Verification Steps 

## Teardown Steps

####  1. Destroy the deployed AWS Infrastructure 
`terraform destroy --auto-approve`

## Requirements
| Name          | Version       |
| ------------- |:-------------:|
| [terraform](https://registry.terraform.io)     | ~>1.5.2      |

## Providers
| Name          | Version       |
| ------------- |:-------------:|
| [aws](https://registry.terraform.io/providers/hashicorp/aws)           | ~>4.50.0      |
| [kubernetes](https://registry.terraform.io/providers/hashicorp/aws)           | ~>2.10.0      |
| [helm](https://registry.terraform.io/providers/hashicorp/aws)           | >2.4.0      |

## Modules
| Name          | Version       |
| ------------- |:-------------:|
| [eks](https://registry.terraform.io/providers/hashicorp/aws)           | ~>18.20.2     |
| [storage-controller](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |
| [ingress](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |
| [network](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |
| [spark](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |
| [airflow](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |

## Data Blocks
| Name          | Type       |
| ------------- |:-------------:|
| [aws_eks_cluster_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_eks_cluster_auth) | Data |

## Resources
| Name          | Type       |
| ------------- |:-------------:|
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_vpc) | Data |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_subnet) | Data |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_internet_gateway) | resource |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_eip) | resource |
| [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_nat_gateway) | resource |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route_table) | resource |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route_table_association) | resource |
| [aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route53_zone) | resource |
| [aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_route53_record) | resource |
| [kubernetes_config_map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_lb) | resource |
| [helm_release](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_lb_listener) | resource |
| [random_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/random_password) | resource |



