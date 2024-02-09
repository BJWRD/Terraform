###########################################################################################################
# Spark Deployment Module
###########################################################################################################

# Creates a randomly generated password for initial boot
resource "random_password" "spark_password" {
  length  = 32
  special = false
}

# Creates the Spark instance itself on the cluster, and gives it both a default initial password and a hostname
resource "helm_release" "spark" {
  name             = "spark"
  version          = "8.1.7"
  create_namespace = "true"
  namespace        = "airflow"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "spark"

  values = [
    <<-EOF
    ingress:
      enabled: true
      hostname: spark.eks.com
    worker:
     autoscaling:
       enabled: true
       minReplicas: 2
       maxReplicas: 2
       targetCPU: 50
       targetMemory: ""
    EOF
  ]
  timeout = "300"
}