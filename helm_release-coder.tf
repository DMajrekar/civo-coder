resource "kubernetes_namespace" "coder" {
  metadata {
    name = "coder"
  }
}

resource "kubernetes_secret" "coder_db" {
  metadata {
    name      = "coder-db-url"
    namespace = "coder"
  }

  data = {
    # TODO: This uses the default username / password for the db, not the one we created. We should fix this
    url = "postgres://${postgresql_role.coder.name}:${random_password.password.result}@${civo_database.coder_database.endpoint}:${civo_database.coder_database.port}/${postgresql_database.coder-database.name}?sslmode=require"
  }

  depends_on = [ kubernetes_namespace.coder ]
}

resource "helm_release" "coder" {
  name = "coder"

  repository = "https://helm.coder.com/v2"
  chart      = "coder"

  namespace        = "coder"

  values = [
    file("${path.module}/coder-values.yaml")
  ]

  set {
    name = "coder.ingress.host"
    value = "coder.${var.domain}"
  }

  set {
    name = "coder.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "coder.${var.domain}"
  }

  set {
    name = "coder.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  }

  set {
    name = "coder.ingress.tls.enable"
    value = "true"
  }

  set {
    name = "coder.ingress.tls.secretName"
    value = "coder-tls"
  }

  depends_on = [ 
    kubernetes_namespace.coder, 
    kubernetes_secret.coder_db,
    helm_release.cert-manager,
  ]
}
