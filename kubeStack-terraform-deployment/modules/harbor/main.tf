###########################################################################################################
# Habor Deployment Module 
###########################################################################################################

# Creates a randomly generated password for initial boot
resource "random_password" "harbor_password" {
  length  = 32
  special = false
}

# Creates a Habor resource on the EKS Cluster itself as an instance
resource "helm_release" "harbor" {
  name             = "harbor"
  create_namespace = "true"
  namespace        = "harbor"

  repository = "https://helm.goharbor.io"
  chart      = "harbor"

  values = [<<-EOT
    expose:
      type: ingress
      ingress:
        hosts:
          core: harbor.kubestack.com
        className: nginx
        annotations:
          ingress.kubernetes.io/ssl-redirect: "true"
          ingress.kubernetes.io/proxy-body-size: "0"
          nginx.ingress.kubernetes.io/ssl-redirect: "true"
          nginx.ingress.kubernetes.io/proxy-body-size: "0"
    persistence:
      enabled: true
      resourcePolicy: "keep"
      persistentVolumeClaim:
        registry:
          size: 128Gi
    externalURL: https://harbor.kubestack.com
    harborAdminPassword: "TEST123"
    EOT
  ]
}

