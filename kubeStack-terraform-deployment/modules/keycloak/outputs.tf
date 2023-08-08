# Sensitive value outputted for the Keycloak provider to use
output "keycloak_admin_password" {
  value      = random_password.keycloak_password.result
  sensitive  = true
  depends_on = [helm_release.keycloak]
}
