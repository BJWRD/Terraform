################################################################################
# Cluster Ingress Module
################################################################################
resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  version    = "4.0.17"
  create_namespace = "true"
  namespace = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [<<-EOT
    controller:
      watchIngressWithoutClass: true
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: "${join(",", [for key, value in var.tags : "${key}=${value}"])}"
          service.beta.kubernetes.io/aws-load-balancer-type: nlb
    EOT
  ]
}

data "kubernetes_service" "nginx_lb" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.ingress-nginx]
}