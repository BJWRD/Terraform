################################################################################
# Storage-Controller Module
################################################################################
resource "helm_release" "aws-ebs-csi-driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  values = [
    <<-EOT
    controller:
      serviceAccount:
        create: true
        name: ebs-csi-controller-sa
        annotations:
          eks.amazonaws.com/role-arn: ${module.cluster_ebs_csi_irsa.iam_role_arn}
    storageClasses:
    - name: generalpurpose
      parameters:
        encrypted: "true"
        type: gp3
    - name: iops
      parameters:
        encrypted: "true"
        type: io2
    - name: throughput
      parameters:
        encrypted: "true"
        type: st1
    EOT
  ]
}

module "cluster_ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix = "ebs-csi-access-policy"
  role_description = "IRSA role for EBS CSI"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}