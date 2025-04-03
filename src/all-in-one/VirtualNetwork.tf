module "network_rg" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "~>0.2.1"
  enable_telemetry = var.enable_telemetry

  name     = replace(local.naming_structure, "{resourceType}", "rg-network")
  location = var.location
  tags     = var.tags
}

module "nsg" {
  source           = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version          = "~>0.4.0"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "nsg")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags
}

module "vnet" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "~>0.8.1"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "vnet")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  address_space = var.address_space

  subnets = {
    "AppServiceSubnet" = {
      name           = "AppServiceSubnet"
      address_prefix = cidrsubnet(var.address_space[0], 27 - local.vnet_address_cidr, 0)

      network_security_group = {
        id = module.nsg.resource_id
      }

      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]

      delegation = [{
        name = "Microsoft.Web.serverFarms"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }
    "MySQLSubnet" = {
      name           = "MySQLSubnet"
      address_prefix = cidrsubnet(var.address_space[0], 27 - local.vnet_address_cidr, 1)

      network_security_group = {
        id = module.nsg.resource_id
      }

      delegation = [{
        name = "Microsoft.DBforMySQL.flexibleServers"
        service_delegation = {
          name = "Microsoft.DBforMySQL/flexibleServers"
        }
      }]
    }
  }
}
