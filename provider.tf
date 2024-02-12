# Specify required provider as maintained by civo
terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.21.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }

    # Used to output the kubeconfig to the local dir for local cluster access
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    # Used to provision helm charts into the k8s cluster
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

# Configure the Civo Provider
provider "civo" {
  token  = var.civo_token
  region = var.region
}

provider "postgresql" {
  host            = civo_database.coder_database.endpoint
  port            = 5432
  username        = civo_database.coder_database.username
  password        = civo_database.coder_database.password
  sslmode         = "require"
  connect_timeout = 15
  superuser = false
}

provider "kubernetes" {
  host                   = civo_kubernetes_cluster.cluster.api_endpoint
  client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
}

provider "helm" {
  kubernetes {
    host                   = civo_kubernetes_cluster.cluster.api_endpoint
    client_certificate     = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(civo_kubernetes_cluster.cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
  }
}