module "shared_app_rg" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "~>0.2.1"
  enable_telemetry = var.enable_telemetry

  name     = replace(local.naming_structure, "{resourceType}", "rg-shared_app")
  location = var.location
  tags     = var.tags
}

module "asp" {
  source           = "Azure/avm-res-web-serverfarm/azurerm"
  version          = "~>0.4.0"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "asp")
  location            = module.shared_app_rg.resource.location
  resource_group_name = module.shared_app_rg.name
  tags                = var.tags

  os_type      = "Linux"
  sku_name     = "P1v3" // TODO: Variable for SKU
  worker_count = 1

  zone_balancing_enabled = var.enable_high_availability ? true : false
}
