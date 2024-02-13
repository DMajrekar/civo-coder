variable "civo_token" {
    type = string
    description = "Civo API token"
}

variable "region" {
  type        = string
  description = "The region to provision the cluster against"
}

variable "environment" {
  default = "dev"
  description = "The environment to deploy to"
  type = string
}

variable "kubernetes_api_access" {
  description = "List of Subnets allowed to access the Kube API"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "lb_access" {
  description = "List of Subnets allowed to access via the Load Balancer (websecure)"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "database_access" {
  description = "List of Subnets allowed to access via the Load Balancer"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}
variable "database_size" {
  type        = string
  default     = "g3.db.small"
  description = "The size of the database to provision. Run `civo size list` for all options"
}

variable "database_nodes" {
  type        = number
  default     = "1"
  description = "Number of nodes in the database pool"
}

variable "domain" {
  type        = string
  description = "The domain to use for ingress. This is used by external-dns to create DNS records and needs to be pre-register with civo.com"
}

variable "email" {
  type        = string
  description = "The email to use for letsencrypt"
}