resource "civo_reserved_ip" "ingress-nginx" {
    name = "coder-ingress-nginx"
}

resource "civo_firewall" "ingress-nginx" {
  name                 = "coder-ingress-nginx"
  network_id = civo_network.network.id
  create_default_rules = false

  ingress_rule {
    protocol    = "tcp"
    port_range  = "80"
    cidr        = ["0.0.0.0/0"]
    label       = "web"
    action      = "allow"
  }

  ingress_rule {
    protocol    = "tcp"
    port_range   = "443"
    cidr        = ["0.0.0.0/0"]
    label       = "websecure"
    action      = "allow"
  }
}
resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.annotations.kubernetes\\.civo\\.com/ipv4-address"
    value = civo_reserved_ip.ingress-nginx.ip
  }

  set {
    name  = "controller.service.annotations.kubernetes\\.civo\\.com/firewall-id"
    value = civo_firewall.ingress-nginx.id
  }

  depends_on = [ ]
}

