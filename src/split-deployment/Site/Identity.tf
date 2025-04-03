module "id" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~>0.3.3"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "id")
  location            = module.app_rg.resource.location
  resource_group_name = module.app_rg.name
  tags                = var.tags
}

// Assign the UAMI the Key Vault Secrets User role on the shared Key Vault
module "id_key_vault_role_assignment" {
  source           = "Azure/avm-res-authorization-roleassignment/azurerm"
  version          = "~>0.2.0"
  enable_telemetry = var.enable_telemetry

  role_assignments_for_scopes = {
    key_vault = {
      scope = data.azurerm_key_vault.key_vault.id
      role_assignments = {
        kvsu = {
          role_definition                  = "kvsu"
          user_assigned_managed_identities = ["id"]
        }
      }
    }
  }

  user_assigned_managed_identities_by_principal_id = { id = module.id.resource.principal_id }
  role_definitions                                 = { kvsu = { name = "Key Vault Secrets User" } }

  depends_on = [module.id]
}
