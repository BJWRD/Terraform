###########################################################################################################
# Airflow Deployment Module
###########################################################################################################

# Creates a randomly generated password for initial boot - ensure when applied do not use the terraform --auto-approve flag
resource "random_password" "airflow_password" {
  length  = 32
  special = false
}

# Creates the Airflow instance itself on the cluster, and gives it both a default initial password and a hostname
resource "helm_release" "airflow" {
  name             = "airflow"
  version          = "1.11.0"
  create_namespace = "true"
  namespace        = "airflow"

  repository = "https://airflow.apache.org/"
  chart      = "airflow"

  values = [
    <<-EOF
    images:
     airflow:
      repository: Enter AWS ECR Repo Here
      tag: latest
    registry:
     secretName: airflow-aws-secret
    config:
     core:
      dags_folder: /opt/airflow/dags/repo/ #Required for the scheduler to detect changes within the git-sync repository
      test_connection: enabled
     logging:
      remote_logging: 'True'
      logging_level: 'INFO'
      remote_base_log_folder: 's3://airflow-spark-eks-cluster-logging/'
      remote_log_conn_id: 's3_conn'
      delete_worker_pods: 'False'
      encrypt_s3_logs: 'True'
    createUserJob:
      useHelmHooks: false
      applyCustomEnv: false
    migrateDatabaseJob:
      useHelmHooks: false
      applyCustomEnv: false
    ingress:
     web:
      enabled: true
      hosts: 
       - name: airflow.eks.com
    executor: "KubernetesExecutor"
    webserverSecretKeySecretName: airflow-webserver-secret-key
    dags:
      gitSync:
       enabled: true
       repo: ssh://SSH-KEY@CodeCommitURL
       branch: main
       sshKeySecret: airflow-ssh-secret
    webserver:
     defaultUser:
      enabled: true
      role: Admin
      username: admin
      email: admin.com
      firstName: admin
      lastName: user
      password: ${random_password.airflow_password.result}
     EOF
  ]
  timeout = "300"
} 
