module "storage" {
  source           = "Azure/avm-res-storage-storageaccount/azurerm"
  version          = "~>0.5.0"
  enable_telemetry = var.enable_telemetry

  name                = replace(replace(local.naming_structure, "{resourceType}", "st"), "-", "")
  location            = var.location
  resource_group_name = module.db_rg.name
  tags                = var.tags

  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  large_file_share_enabled          = true
  public_network_access_enabled     = true

  // Required for mounting the file share in App Service
  shared_access_key_enabled = true

  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [data.http.runner_ip.response_body]
    virtual_network_subnet_ids = [module.vnet.subnets["AppServiceSubnet"].resource_id]
  }

  role_assignments = {
    // Allow the current user to access the storage account to read the contents of the WordPress file share
    "current_user" = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Storage File Data Privileged Contributor"
      principal_type             = "User"
    }
    // There is no role assignment for the managed identity because the App Service will use the storage account key to mount the file share
  }
}
