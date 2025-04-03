data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

data "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_resource_group_name
}

data "azurerm_mysql_flexible_server" "mysql" {
  name                = var.mysql_name
  resource_group_name = var.mysql_resource_group_name
}

data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

data "azurerm_subnet" "app_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}
