resource "civo_network" "network" {
    label = "${var.environment}-clickhouse"
}
