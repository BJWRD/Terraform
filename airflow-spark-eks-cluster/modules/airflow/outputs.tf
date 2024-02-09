# Sensitive value outputted for the Airflow provider to use
output "airflow_admin_password" {
  value      = random_password.airflow_password.result
  sensitive  = true
  depends_on = [helm_release.airflow]
}