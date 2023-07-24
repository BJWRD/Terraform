###########################################################################################################
# Rancher Deployment Module [Missing Certificate]
###########################################################################################################

# Generates a random password to be used for setting up a login
resource "random_password" "rancher_bootstrap" {
  length  = 32
  special = false
}

# Creates the Rancher instance itself on the cluster, and gives it both a default initial password and a hostname
resource "helm_release" "rancher" {
  name             = "rancher"
  version          = "2.7.5"
  create_namespace = "true"
  namespace        = "cattle-system"

  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"

  values = [
    <<-EOF
    hostname: rancher.terraform-eks-cluster.com
    ingress:
      enabled: true
      hostname: ${var.hostname}
      servicePort: 80
      rules:
        - host: rancher.terraform-eks-cluster.com
          paths:
            - path: /rancher
      tls:
        - hosts:
          - rancher.terraform-eks-cluster.com
          secretName: tls-rancher-ingress
    EOF
  ]
  timeout = "300"
}

# Used to delay the creation of a Rancher Admin password change so as to wait for deployment to properly finish
resource "time_sleep" "wait_60_seconds" {
  depends_on = [helm_release.rancher]

  create_duration = "60s"
}

# Create a new rancher2_bootstrap using bootstrap provider config
resource "rancher2_bootstrap" "admin" {
  initial_password = random_password.rancher_bootstrap.result
  telemetry        = false
  depends_on = [
    helm_release.rancher, time_sleep.wait_60_seconds
  ]
}

# Creates a resource for storing some Rancher values to be used in other bolt-on modules, and to parrot to the user
resource "kubernetes_secret" "rancher-secrets" {
  metadata {
    name      = "rancher-secrets"
    namespace = "default"
  }

  data = {
    "rancher_username" = "admin"
    "rancher_password" = "${rancher2_bootstrap.admin.password}"
    "rancher_hostname" = "rancher.terraform-eks-cluster.com"
  }
}
