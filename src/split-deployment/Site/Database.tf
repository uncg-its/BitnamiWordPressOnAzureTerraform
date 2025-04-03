resource "azurerm_mysql_flexible_database" "database" {
  name                = local.wp_database_name
  resource_group_name = data.azurerm_mysql_flexible_server.mysql.resource_group_name
  server_name         = data.azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}
