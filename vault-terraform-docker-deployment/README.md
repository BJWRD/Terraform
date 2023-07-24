# vault-terraform-aws
[Hashicorp Vault](https://developer.hashicorp.com/vault) application which is provisioned by [Terraform](https://www.terraform.io/) and hosted within a [Docker](https://www.docker.com/) container on [AWS](https://aws.amazon.com/) Public Cloud.


# Architecture
This network architecture has one subnet tier on the *eu-west-2a* availability zone. The subnet will also have a VPC routing table that will provide it access to the internet. The Security Group will allow port 22 access to those that have the relevant .pem file, this will allow the EC2 host to be accessed and then configured using the specified commands further down this README.


![image](https://user-images.githubusercontent.com/83971386/198644799-1e3e2a34-8409-4678-8934-679e5172b68c.png)

# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS EC2 key pair - [steps](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

# How to Apply/Destroy
This section details the deployment and teardown of the architecture. **Warning: this will create AWS resources that costs money**

### Terraform Deployment steps

#### 1.	Clone the vault-terraform-aws repo
        
    git clone https://github.com/BJWRD/Terraform/vault-terraform-aws

#### 2.	Initialise the working directory, which contains the tf configuration 

    terraform init

#### 3.	 Ensure the terraform code is formatted and validated 

    terraform fmt
    terraform validate

#### 4.	Create an execution plan
    
    terraform plan

#### 5.	Execute terraform configuration 

    terraform apply --auto-approve

### Vault - Docker Container Deployment Steps

#### 1.  On the newly provisioned AWS Host - Clone the repo

    git clone https://github.com/BJWRD/vault-terraform-aws

#### 2.  Running Vault Container
Enter the following Docker-Compose command to start the Vault container in detatched mode.

    docker-compose up -d
    docker ps
    
ENTER RUNNING CONTAINER IMAGE HERE

Note: In the instance that the container has failed to run due to the Dockerfile Entrypoint config, then comment out the Entrypoint line within the Dockerfile and enter the commands below -

    docker-compose up -d
    docker ps 
    docker exec -it <container ID> bash
    vault server -config=/home/vault/config/config.hcl
    
### Vault Setup

#### 1.  Vault Initialisation 

Now that we have a running instance, we now need to initialise Vault.

First access the Container running Vault -

    docker ps 
    docker exec -it <container ID> bash   
     
Enter photo 2
     
Then enter the following two commands (you will need to set the VAULT_ADDR envrionment variable accordingly to your VM IP Address) -

    export VAULT_ADDR='http://<VM IP Address>:8080'
    vault operator init

Enter photo 3

The initialisation outputs two incredibly important pieces of information: the *unseal keys* and the initial *root token*. This is the only time ever that all of this data is known by Vault, and also the only time that the unseal keys should ever be so close together.

Save all of these keys somewhere secure, and continue.

#### 2.  Vault Seal/Unseal

Every initialized Vault server starts in the sealed state. Unsealing has to happen every time Vault starts and it can be done via the command line. 

To unseal the Vault, you must use three of the outputted unseal keys generated at initialisation. 

    vault operator unseal
     
Once the three unseal keys have been entered, you will see a screen similar to the one below -

Enter Photo 4 

When the value for Sealed changes to false, the Vault is unsealed. As a root user, you can reseal the Vault with *vault operator seal*.

#### 3.  Vault Login

Finally, authenticate as the initial root token

    vault login
     
ENTER photo 5

### Accessing the Vault Web UI

#### 1.  Access via the Web Browser

Launch a web browser, and enter http://<VM IP Address>:8080/ui in the address bar.

Then login with the root token (generated at initialisation) -

Enter photo 6

#### 2.  Vault Authentication Methods

Now that we have a running Vault system, you may want to use different authentication methods other than *root token* authentication. 

This can be achieved via the *Access* screen within the Vault User Interface -

Enter photo 8

More on this can be found within the following site - 

https://developer.hashicorp.com/vault/docs/auth

#### 3.  Creating Secrets

We are also now in the positon whereby we are able to enter our secrets securely within the Vault -

Enter photo 9

Once again, more information can be found at the following site - 

https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-first-secret

### Teardown steps

#### 1.  Stop the Docker Container which is running Vault

    docker-compose down

#### 2.	Destroy the deployed AWS Infrastructure

    terraform destroy --auto-approve


# Requirements
| Name          | Version       |
| ------------- |:-------------:|
| terraform     | ~>1.3.0     |
| aws           | ~>4.30.0      |

# Providers
| Name          | Version       |
| ------------- |:-------------:|
| aws           | ~>4.30.0      |


# List of tools/services used
* [Terraform](https://www.terraform.io/)
* [AWS](https://aws.amazon.com/)
* [Docker](https://www.docker.com/)
* [Dockerfile](https://docs.docker.com/engine/reference/builder/)
* [Docker-Compose](https://docs.docker.com/compose/install/)
* [Hashicorp Vault](https://developer.hashicorp.com/vault)
