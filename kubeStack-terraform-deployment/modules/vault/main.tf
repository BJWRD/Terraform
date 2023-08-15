################################################################################
# Vault Deployment Module
################################################################################
resource "helm_release" "vault" {
  name             = "vault"
  create_namespace = "true"
  namespace        = "vault"
  version          = "0.25.0"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [<<-EOT
    server:
        ingress:
            enabled: true
            hosts:
            - host: vault.kubestack.com
        dataStorage:
            enabled: true
            # Size of the PVC created
            size: 20Gi
            storageClass: gp2
            mountPath: "/vault/data"
    EOT
  ]
}
