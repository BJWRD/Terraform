################################################################################
# Artifactory Module
################################################################################

resource "helm_release" "artifactory-oss" {
  name             = "artifactory-oss"
  version          = "107.55.9"
  create_namespace = "true"
  namespace        = "artifactory-oss"

  repository = "https://charts.jfrog.io"
  chart      = "artifactory-oss"

  values = [
    "${file("modules/artifactory/values.yaml")}"
  ]
}

