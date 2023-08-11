# kubeStack-terraform-deployment
A EKS Cluster using Helm Charts Rancher, Rancher-Monitoring (Grafana/Prometheus), Keycloak, Harbor, and Hashicorp Vault for multi-deployment - provisioned via IAC (Terraform).

# Architecture
Enter Image


# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS EC2 key pair - [steps](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
* Environment Variables for AWS CLI - [steps](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* VPC Endpoint Configuration - [article](https://docs.aws.amazon.com/whitepapers/latest/aws-privatelink/what-are-vpc-endpoints.html)
* Public & Private Subnet Setup - [article](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)

# How to Apply/Destroy
This section details the deployment and teardown of the kubeStack EKS Cluster. **Warning: this will create AWS resources that costs money**

## Deployment Steps

#### 1.	Clone the repo
    git clone https://github.com/BJWRD/Terraform/kubeStack-terraform-deployment && cd kubeStack-terraform-deployment
    
#### 2. Update the s3 bucket name to your own - `versions.tf`

    backend "s3" {
      bucket = "ENTER HERE"
      key    = "terraform.tfstate"
      region = "eu-west-2"
    }
    
#### 3. Update the EKS / Helm Chart versions if required.

#### 4. Update `versions.tf`
    tfupdate terraform versions.tf && tfupdate provider aws versions.tf
    
#### 5.	Initialise the TF directory
    terraform init

#### 6. Ensure the terraform code is formatted and validated 
    terraform fmt && terraform validate

#### 7. Create an execution plan
    terraform plan

#### 8. Execute terraform configuration 
    terraform apply --auto-approve
    
## Further Deployment Steps 


## Verification Steps

#### 1. Check AWS Infrastructure
Check the infrastructure deployment status, by enter the following terraform command -

     terraform show

Alternatively, view the resources directly via the AWS GUI.

#### 2. Check K8s Infrastructure
Check the K8s infrastructure deployment status, by enter the following commands -

    aws eks update-kubeconfig --name kubeStack-Cluster && kubectl get all --all-namespaces

#### 3. Verify Application accessibility 
Access the respective Application DNS's below -

``rancher.kubestack.com``
``harbor.kubestack.com``
``keycloak.kubestack.com``
``grafana.kubestack.com``
``prometheus.kubestack.com``

**NOTE:** Ensure the Route53 DNS record entered, includes the latest LB URL

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
| [keycloak](https://registry.terraform.io/providers/hashicorp/aws)           | ~>4.3.1      |
| [rancher2](https://registry.terraform.io/providers/hashicorp/aws)           | ~>3.0.1      |
| [harbor](https://registry.terraform.io/providers/hashicorp/aws)           | >3.9.4      |

## Modules
| Name          | Version       |
| ------------- |:-------------:|
| [eks](https://registry.terraform.io/providers/hashicorp/aws)           | ~>18.20.2     |
| [rancher](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |
| [ingress](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |
| [network](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |
| [keycloak](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |
| [harbor](https://registry.terraform.io/providers/hashicorp/aws)           | ~>      |
| [rancher-monitoring](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |
| [vault](https://registry.terraform.io/providers/hashicorp/aws)           | ~>    |

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
| [kubernetes_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kubernetes_secret) | resource |
| [rancher2_bootstrap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rancher2_bootstrap) | resource |
| [time_sleep](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/time_sleep) | resource |



