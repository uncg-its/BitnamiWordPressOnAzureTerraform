module "appservice" {
  source           = "Azure/avm-res-web-site/azurerm"
  version          = "~>0.15.1"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "app")
  location            = module.app_rg.resource.location
  resource_group_name = module.app_rg.name
  tags                = var.tags

  https_only                  = true
  enable_application_insights = false

  os_type                  = "Linux"
  service_plan_resource_id = data.azurerm_service_plan.asp.id

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.id.resource_id]
  }

  key_vault_reference_identity_id = module.id.resource_id

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  virtual_network_subnet_id = data.azurerm_subnet.app_subnet.id

  kind = "webapp"

  site_config = {
    http2_enabled          = true
    vnet_route_all_enabled = true

    application_stack = {
      docker = {
        docker_image_name   = "bitnami/wordpress:6.7.2" // TODO: Variable for container image
        docker_registry_url = "https://index.docker.io" // TODO: Variable or local for container registry URL
      }
    }
  }

  app_settings = {
    WORDPRESS_USERNAME             = "wpadmin"
    WORDPRESS_PASSWORD             = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.key_vault.name};SecretName=${resource.azurerm_key_vault_secret.wp_admin_password.name})"
    WORDPRESS_DATABASE_HOST        = data.azurerm_mysql_flexible_server.mysql.fqdn
    WORDPRESS_DATABASE_PORT_NUMBER = "3306"
    WORDPRESS_DATABASE_NAME        = resource.azurerm_mysql_flexible_database.database.name
    WORDPRESS_DATABASE_USER        = data.azurerm_mysql_flexible_server.mysql.administrator_login
    WORDPRESS_DATABASE_PASSWORD    = "@Microsoft.KeyVault(VaultName=${data.azurerm_key_vault.key_vault.name};SecretName=${local.dbadmin_password_kv_secret_name})"
    WORDPRESS_PLUGINS              = "all"

    # WORDPRESS_ENABLE_REVERSE_PROXY="yes" // When using Azure Front Door?

    WORDPRESS_ENABLE_HTTPS = "no" // App Service should not use end-to-end TLS between the frontend and the instance anyway
    WORDPRESS_BLOG_NAME    = "${var.environment} Site"
    WORDPRESS_EMAIL        = "sven@aelterman.cloud"
    WORDPRESS_FIRST_NAME   = "Sven"
    WORDPRESS_LAST_NAME    = "Aelterman"
  }

  // Mount storage for wordpress_data:/bitnami/wordpress
  storage_shares_to_mount = {
    wordpress_data = {
      name         = "WordPress"
      account_name = data.azurerm_storage_account.storage.name
      access_key   = data.azurerm_storage_account.storage.primary_access_key
      share_name   = resource.azurerm_storage_share.share.name
      mount_path   = "/bitnami/wordpress"
    }
  }

  // Explicit dependency on the Key Vault role assignment because there is no output of this module used here
  depends_on = [module.id_key_vault_role_assignment]
}
