module "id" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~>0.3.3"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "id")
  location            = module.app_rg.resource.location
  resource_group_name = module.app_rg.name
  tags                = var.tags
}
