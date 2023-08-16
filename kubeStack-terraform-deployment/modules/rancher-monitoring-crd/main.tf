###########################################################################################################
# Rancher-Monitoring CRD Deployment Module 
###########################################################################################################
# Creates Rancher-Monitoring CRD resources on the EKS Cluster
resource "helm_release" "rancher-monitoring-crd" {
  name             = "rancher-monitoring-crd"
  create_namespace = "true"
  namespace        = "cattle-monitoring-system"

  repository = "https://raw.githubusercontent.com/rancher/charts/release-v2.7/"
  chart      = "rancher-monitoring-crd"
}
