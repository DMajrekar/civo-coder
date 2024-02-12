# Create a firewall
resource "civo_firewall" "kube-firewall" {
  name                 = "clickhouse-kube-firewall"
  network_id           = civo_network.network.id
  create_default_rules = false

  ingress_rule {
    protocol   = "tcp"
    port_range = "6443"
    cidr       = var.kubernetes_api_access
    label      = "kubernetes-api-server"
    action     = "allow"
  }
}

resource "civo_kubernetes_cluster" "cluster" {
  name         = "${var.environment}-coder"
  firewall_id  = civo_firewall.kube-firewall.id
  network_id   = civo_network.network.id
  cluster_type = "talos"
  pools {
    node_count = 3
    size       = "g4s.kube.medium"
  }

  timeouts {
    create     = "5m"
  }
}

resource "local_file" "kubeconfig" {
  content              = civo_kubernetes_cluster.cluster.kubeconfig
  filename             = "${path.module}/kubeconfig"
  file_permission      = "0600"
  directory_permission = "0755"
}