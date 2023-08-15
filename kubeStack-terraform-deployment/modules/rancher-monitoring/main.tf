###########################################################################################################
# Rancher-Monitoring Deployment Module 
###########################################################################################################
# Creates Rancher-Monitoring resources on the EKS Cluster
resource "helm_release" "rancher-monitoring" {
  name             = "rancher-monitoring"
  create_namespace = "true"
  namespace        = "cattle-monitoring-system"

  repository = "https://raw.githubusercontent.com/rancher/charts/release-v2.7/"
  chart      = "rancher-monitoring"
}
