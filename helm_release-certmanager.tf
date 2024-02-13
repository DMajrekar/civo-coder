resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"
  version          = "v1.14.1"

  set {
    type  = "string"
    name  = "installCRDs"
    value = true
  }
}


resource "kubernetes_manifest" "letsencrypt-prod" {
  manifest = {
    apiVersion : "cert-manager.io/v1",
    kind : "ClusterIssuer",
    metadata : {
      name : "letsencrypt-prod"
    },
    spec : {
      acme : {
        server : "https://acme-v02.api.letsencrypt.org/directory",
        email : var.email,
        privateKeySecretRef : {
          name : "letsencrypt-prod"
        },
        solvers : [
          {
            http01 : {
              ingress : {
                ingressClassName : "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert-manager]
}
