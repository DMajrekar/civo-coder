
resource "civo_firewall" "database_firewall" {
  name                 = "coder-firewall"
  network_id           = civo_network.network.id
  create_default_rules = false

  ingress_rule {
    label      = "db access"
    protocol   = "tcp"
    port_range = "5432"
    action     = "allow"
    cidr       = var.database_access
  }
}

resource "civo_database" "coder_database" {
  name        = "coder-db"
  size        = var.database_size
  nodes       = var.database_nodes
  engine      = "PostgreSQL"
  version     = "14"
  network_id  = civo_network.network.id
  firewall_id = civo_firewall.database_firewall.id
}

resource "postgresql_database" "coder-database" {
  name              = "coder"
  template          = "template1"
  lc_collate        = "en_US.utf-8"
  connection_limit  = -1
  allow_connections = true
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "postgresql_role" "coder" {
  name     = "coder"
  login    = true
  password = random_password.password.result
  connection_limit = -1
}

resource "postgresql_grant" "coder" {
    database = postgresql_database.coder-database.name
    role     = "coder"
    object_type = "database"
    schema = "public"
    privileges = [ "CONNECT", "CREATE", "TEMPORARY" ]
    with_grant_option = false
}
