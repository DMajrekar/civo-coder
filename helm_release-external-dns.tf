resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external-dns-secrets" {
  metadata {
    name      = "external-dns-secrets"
    namespace = kubernetes_namespace.external-dns.metadata[0].name
  }
  data = {
    token = var.civo_token
  }

  depends_on = [kubernetes_namespace.external-dns]
}

resource "helm_release" "external-dns" {
  name = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  namespace = "external-dns"

  set {
    name  = "provider"
    value = "civo"
  }

  set {
    name  = "sources[0]"
    value = "ingress"
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain
  }

  set {
    name  = "env[0].name"
    value = "CIVO_TOKEN"
  }

  set {
    name  = "env[0].valueFrom.secretKeyRef.name"
    value = "external-dns-secrets"
  }

  set {
    name  = "env[0].valueFrom.secretKeyRef.key"
    value = "token"
  }

  depends_on = [
    kubernetes_namespace.external-dns,
    kubernetes_secret.external-dns-secrets
  ]
}
