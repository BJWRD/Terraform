################################################################################
# Cluster Autoscaler Module
# Based on the official docs at
# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
################################################################################
data "aws_region" "current" {}

resource "helm_release" "autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = "kube-system"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.21.1"
  create_namespace = false

  values = [
    <<-EOF
    awsRegion: ${data.aws_region.current.id}
    rbac:
      create: true
      serviceAccount:
        name: cluster-autoscaler-aws
        annotations:
          eks.amazonaws.com/role-arn: ${module.cluster_autoscaler_irsa.iam_role_arn}
    autoDiscovery:
      clusterName: ${var.cluster_id}
      enabled: true
    extraArgs:
      skip-nodes-with-local-storage: false
    EOF
  ]
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [var.cluster_id]

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-aws"]
    }
  }

  tags = var.tags
}