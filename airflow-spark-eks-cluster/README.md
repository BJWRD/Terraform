# airflow-spark-eks-cluster
An EKS Cluster using Airflow/Spark to perform DAG runs on an S3 Bucket - provisioned via IAC (Terraform).

# 📋 Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Environment Variables for AWS CLI - [steps](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
* S3 Buckets x3 - (tfstate file hosting, Airflow DAG logging, CSV file updates)
* AWS CodeCommit Repository
* Elastic Container Registery to host your Docker Image for the Airflow Chart to then use for Airflow Deployment.

# How to Apply/Destroy
This section details the deployment and teardown of the kubeStack EKS Cluster. **Warning: this will create AWS resources that costs money**

## 💻 Deployment Steps

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
    dags:
     gitSync:
      enabled: true
      repo: ssh://SSHKEYID@git-codecommit_repo_url
      branch: main
      sshKeySecret: airflow-ssh-secret
 
    config:
     core:
      dags_folder: /opt/airflow/dags/repo/ #Required for the scheduler to detect changes within the git-sync repository
      test_connection: enabled

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

## ✅  Terraform Verification Steps

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


# 💻 Apache Airflow
The following steps will detail and describe additional information in relation to the configuration of the Apache Airflow application.

## DAG GitSync
Additional configuration is necessary to ensure the adherence to the preferred deployment process for Directed Acyclic Graphs (DAGs) within Airflow, i.e., the GitSync deployment.

### 📋 Pre-Requisites:

* AWS CodeCommit Repository – ‘airflow-spark-deployment’
* IAM User – ‘airflow-user’
* Assigned IAM Permissions to airflow-user which allow all AWS CodeCommit actions i.e. GitPull/GitPush.
* AWS Security Credentials created for the airflow-usere. AWS AccessKey & AWS Secret Key
* Kubernetes Secret Key which contains the secret values (base64 encoded) –

        apiVersion: v1
        kind: Secret
        metadata:
          name: aws-credentials-secret
          namespace: airflow
        type: Opaque
        data:
          AWS_ACCESS_KEY_ID: base64_encoded
          AWS_SECRET_ACCESS_KEY: base64_encoded

      dags:
          gitSync:
          enabled: true
          repo: ssh://SSHKEYID@git-codecommit_repo_url
          branch: main
          sshKeySecret: airflow-ssh-secret
 
      config:
         core:
          dags_folder: /opt/airflow/dags/repo/ #Required for the scheduler to detect changes within the git-sync repository
          test_connection: enabled

**Note**: The ‘SSHKEYID’ string at the start of the git CodeCommit repo represents the AWS Access Key credentials associated with the created IAM user i.e. airflow-user

Once initiated, this process ensures that all files placed within the AWSCodeCommit repository 'airflow' are synchronised to the 'airflow-scheduler' Kubernetes pod. This pod contains a running git-sync init container, which actively places all DAG files within the Airflow UI (as shown below) -

![image](https://github.com/BJWRD/Terraform/assets/83971386/9e0cd4bc-6e17-4859-a1e5-bf67f8bc514b)


## Airflow AWS Connection
Airflow Connections can be configured within the Airflow Helm values, however, to save time I configured the AWS connection directly within the Airflow UI, which in turn establishes connectivity from Airflow to the AWS platform. The connectivity can be tested from either the UI or the Kubernetes Pod Airflow CLI -
![image](https://github.com/BJWRD/Terraform/assets/83971386/d51100bd-f8c2-4247-b578-186021ad1700)

![image](https://github.com/BJWRD/Terraform/assets/83971386/a8a22b1e-2e59-447d-8fc4-9714e357ac38)

## S3/Bash/Python Operators
The `spark_test.py` script uses the embedded DataFrame to create a CSV file within a targeted S3 bucket, which then exports all 'London' data to a newly-named CSV file within the same S3 bucket.

**Note**: This script is idempotent

## apache-airflow-providers-apache-spark
By default the Airflow deployment does not have any Spark integration embedded within to allow Airflow to connect to Spark, which in essence prevents Airflow from utilising Spark jobs to process data.

therefore the Apache Airflow Image requires tailoring to ensure that the `apache-airflow-providers-apache-spark` plugin is integrated. Steps below -

* Create an ECR (Elastic Container Repository) in the same AWS account which the EKS cluster is deployed within.
* Create a Dockerfile which fits the requirements of incorporating the apache-airflow-providers-apache-spark provider within so that the required spark functionality is built into Apache Airflow –

        FROM apache/airflow:2.8.1-python3.11
 
        USER root
 
        # Install OpenJDK 17 & Remove unnecessary packages
        RUN apt-get update \
          && apt-get install -y --no-install-recommends openjdk-17-jre-headless \
          && apt-get autoremove -yqq --purge \
          && apt-get clean \
          && rm -rf /var/lib/apt/lists/*
 
        USER airflow
 
        # Install Provider - apache-airflow-providers-apache-spark
        ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" apache-airflow-providers-apache-spark==4.7.1 pyspark==3.5.0

**Note**: Python version 3.11 is required to align with the python version used within Apache Spark.

* Docker build the file into an image and then finally push to the ECR repository.
* Finally, copy the repository URL and append it to the Helm Chart values so that the customised image is used upon Airflow deployment –

        images:
         airflow:
          repository: REPO_URL/airflow-spark
          tag: latest

# 💻 Apache Spark
The following steps will detail and describe additional information in relation to the configuration of the Apache Spark application.

## Airflow Spark connection
As mentioned earlier, once the apache-airflow-providers-apache-spark provider is baked into the Airflow image, this enables the Airflow > Spark configuration. Below you can see the following Spark Connection created where the Spark Master host details have been entered (Host and Port), these can be found from within the Spark UI or via the Spark Master Kubernetes Pod.
![image](https://github.com/BJWRD/Terraform/assets/83971386/1aad993a-fcfe-4d27-b7d9-ddc244608b53)

## Spark DAG
The following Dag uses the SparkSubmitOperator which is used to submit Spark jobs as tasks within an Airflow DAG. See a breakdown of the configuration below -

**task_id**: This is the unique identifier for the task within the Airflow DAG.

**application**: This parameter specifies the path to the Spark script or application that will be executed. It can be a local file path or a path accessible from the Spark cluster.

**conn_id**: This parameter specifies the connection ID for Apache Spark. It allows Airflow to connect to the Spark cluster defined in Airflow's connection settings.

**execution_timeout**: This parameter specifies the maximum amount of time the Spark job is allowed to run before Airflow times out and marks the task as failed. In this case, it is set to 15 minutes.

**dag**: This parameter specifies the DAG to which the task belongs.

**packages**: This parameter specifies any additional packages or dependencies required by the Spark job. In this example, the operator is downloading the Hadoop-AWS package version 3.3.4, which is necessary for interacting with Amazon S3.

**conf**: This parameter specifies configuration properties to be passed to the Spark job. In the created DAG below, it sets the spark.hadoop.fs.s3a.access.key and spark.hadoop.fs.s3a.secret.key properties, which are used to authenticate access to an S3 bucket. The values are retrieved from Airflow Variables, which can store sensitive information securely.

    from datetime import datetime, timedelta
    from airflow import DAG
    from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
    from airflow.models import Variable
 
    default_args = {
        'owner': 'airflow',
        'depends_on_past': False,
    }
 
    dag = DAG(
        dag_id='spark_test_dag',
        description='A simple Airflow DAG to test out Spark Operator capabilities',
        start_date=datetime(2024, 1, 18),
        schedule_interval='0 * * * *',
        default_args=default_args,
    )
 
    spark_conn_id = 'spark'
    spark_script_path= '/opt/airflow/dags/repo/spark_test.py'
 
    # Define SparkSubmitOperator task
    spark_task = SparkSubmitOperator(
        task_id='spark_task',
        application=spark_script_path,  # Spark script path
        conn_id=spark_conn_id,  # Connection ID for Apache Spark
        name='spark_test_job',
        execution_timeout=timedelta(minutes=15),  # Spark job runtime
        dag=dag,
        packages='org.apache.hadoop:hadoop-aws:3.3.4', # Hadoop-AWS download
        conf={
            'spark.hadoop.fs.s3a.access.key': Variable.get("AWS_ACCESS_KEY_ID"),
            'spark.hadoop.fs.s3a.secret.key': Variable.get("AWS_SECRET_ACCESS_KEY"),
        },
    )
 
    # Task dependencies
    spark_task

## Spark Variables 
The AWS Access Key and Secret Key referenced above have been added as variables within Apache Airflow (via the Airflow UI), this was required to ensure that they weren’t applied to the DAG in plaintext.

![image](https://github.com/BJWRD/Terraform/assets/83971386/9364512e-0d58-48c8-a9a4-a0bbadd50970)

## Spark Script

The Spark DAG script (`spark_dag.py`) uses PySpark to interact with S3, including writing data to S3 and reading data from S3. Below is a breakdown which covers some of the main tasks of what’s performed by the script following execution -

**IP Lookup Function**: Defines a function get_ip() to obtain the IP address of the Spark driver. This is used to ensure that workers/executors know which IP address to connect back to when they start.

**Initializs Spark Session**: Creates a SparkSession named "S3Spark" with the necessary configurations, including setting the S3A filesystem implementation and specifying the Spark driver's host IP address obtained from the get_ip() function.

**S3 Configuration**: Specifies the S3 bucket (s3_bucket) and key (s3_key) where data will be written to and read from.

**DataFrame Creation**: Creates a DataFrame (df) from sample data.

**Write DataFrame to S3**: Writes the DataFrame (df) to S3 in CSV format, with the specified bucket and key.

**Read DataFrame from S3**: Reads the contents of the CSV file written to S3 back into a new DataFrame (s3_file_contents).

Useful links which helped throughout the script configuration process –

* [What is spark.local.ip ,spark.driver.host,spark.driver.bindAddress and spark.driver.hostname?](https://stackoverflow.com/questions/43692453/what-is-spark-local-ip-spark-driver-host-spark-driver-bindaddress-and-spark-dri)

* [Configuration - Spark 3.5.0 Documentation](https://spark.apache.org/docs/latest/configuration.html)

* [networking - Finding local IP addresses using Python's stdlib](https://stackoverflow.com/questions/166506/finding-local-ip-addresses-using-pythons-stdlib/28950776#28950776)


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



