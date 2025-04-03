module "mysql_private_dns_zone" {
  source           = "Azure/avm-res-network-privatednszone/azurerm"
  version          = "~>0.3.3"
  enable_telemetry = var.enable_telemetry

  domain_name         = "privatelink.mysql.database.azure.com"
  resource_group_name = module.network_rg.name
  tags                = var.tags

  virtual_network_links = {
    "vnet" = {
      vnetid       = module.vnet.resource_id
      vnetlinkname = "link"
      tags         = var.tags
    }
  }
}
