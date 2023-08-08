###########################################################################################################
# Keycloak Deployment Module 
###########################################################################################################

# Creates a randomly generated password for initial boot
resource "random_password" "keycloak_password" {
  length  = 32
  special = false
}

# Creates a randomly generated password for post-boot
resource "random_password" "postgres_password" {
  length  = 32
  special = false
}

# Creates a Keycloak resource on the EKS Cluster itself as an instance
resource "helm_release" "keycloak" {
  name             = "keycloak"
  version          = "15.1.2"
  create_namespace = "true"
  namespace        = "keycloak"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"

  values = [<<-EOT
    auth:
        adminUser: admin
        adminPassword: ${random_password.keycloak_password.result}
    hostname: keycloak.kubestack.com
    ingress:
      enabled: true
      serviceport: 80
      rules:
        - host: keycloak.kubestack.com
          paths:
            - path: /auth/
              pathType: ImplementationSpecific
      annotations:
          nginx.ingress.kubernetes.io/proxy-buffer-size: 16k
    service:
        type: ClusterIP
    postgresql:
        auth:
            password: ${random_password.postgres_password.result}
    proxyAddressForwarding: true
    extraEnvVars:
        - name: KEYCLOAK_FRONTEND_URL
          value: "https://keycloak.kubestack.com"
    EOT
  ]
}

# Creates a resource of Keycloak configs to be used as a data source for later bolting on, and for outputting values
resource "kubernetes_config_map" "keycloak-info" {
  metadata {
    name      = "keycloak-info"
    namespace = "default"
  }
  data = {

    #    "keycloak_realm" = "${keycloak_realm.realm.realm}"
    #   "keycloak_user_username" = "${keycloak_user.realm-user.username}"
  }
}

# Creates a secret resource of Keycloak configs to be used as a data source for later bolting on, and for outputting values
resource "kubernetes_secret" "keycloak-secrets" {
  metadata {
    name      = "keycloak-secrets"
    namespace = "default"
  }

  data = {
    #  "keycloak_user_password" = "${random_password.user_password.result}"
    "keycloak_admin_username" = "admin"
    "keycloak_admin_password" = "${random_password.keycloak_password.result}"
  }
}
