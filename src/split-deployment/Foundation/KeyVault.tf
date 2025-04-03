module "key_vault" {
  source           = "Azure/avm-res-keyvault-vault/azurerm"
  version          = "~>0.10.0"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "kv")
  location            = module.shared_app_rg.resource.location
  resource_group_name = module.shared_app_rg.name
  tags                = var.tags

  tenant_id = data.azurerm_client_config.current.tenant_id

  secrets = {
    dbadmin_password = {
      name            = local.dbadmin_password_kv_secret_name
      expiration_date = local.secret_expiration_date
    }
  }

  secrets_value = {
    dbadmin_password = random_password.mysql_random_password.result
  }

  role_assignments = {
    "current_user" = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Administrator"
      principal_type             = "User"
    }
  }

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [data.http.runner_ip.response_body]
    virtual_network_subnet_ids = [module.vnet.subnets["AppServiceSubnet"].resource_id]
  }
}
