module "app_rg" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "~>0.2.1"
  enable_telemetry = var.enable_telemetry

  name     = replace(local.naming_structure, "{resourceType}", "rg-app")
  location = var.location
  tags     = var.tags
}

module "asp" {
  source           = "Azure/avm-res-web-serverfarm/azurerm"
  version          = "~>0.4.0"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "asp")
  location            = module.app_rg.resource.location
  resource_group_name = module.app_rg.name
  tags                = var.tags

  os_type  = "Linux"
  sku_name = "P1v3"

  zone_balancing_enabled = var.enable_high_availability ? true : false
}

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
  service_plan_resource_id = module.asp.resource_id

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.id.resource_id]
  }

  key_vault_reference_identity_id = module.id.resource_id

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  virtual_network_subnet_id = module.vnet.subnets["AppServiceSubnet"].resource_id

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
    WORDPRESS_PASSWORD             = "@Microsoft.KeyVault(VaultName=${module.key_vault.name};SecretName=${local.wpadmin_password_kv_secret_name})"
    WORDPRESS_DATABASE_HOST        = module.mysql.resource.fqdn
    WORDPRESS_DATABASE_PORT_NUMBER = "3306"
    WORDPRESS_DATABASE_NAME        = local.wp_database_name
    WORDPRESS_DATABASE_USER        = module.mysql.resource.administrator_login
    WORDPRESS_DATABASE_PASSWORD    = "@Microsoft.KeyVault(VaultName=${module.key_vault.name};SecretName=${local.dbadmin_password_kv_secret_name})"
    WORDPRESS_PLUGINS              = "all"

    // TODO: Create variables for the following settings
    # WORDPRESS_ENABLE_MULTISITE       = "yes"
    # WORDPRESS_MULTISITE_NETWORK_TYPE = "subdirectory"
    # WORDPRESS_MULTISITE_HOST = ""

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
      account_name = module.storage.name
      access_key   = module.storage.resource.primary_access_key
      share_name   = local.wp_share_name
      mount_path   = "/bitnami/wordpress"
    }
  }

  // Add an explicit dependency on the MySQL module because otherwise the App Service module starts before the database is created or before secure transport is OFF
  depends_on = [module.mysql]
}

module "appservice_test" {
  count = var.deploy_test_appservice ? 1 : 0

  source           = "Azure/avm-res-web-site/azurerm"
  version          = "~>0.15.1"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "testapp")
  location            = module.app_rg.resource.location
  resource_group_name = module.app_rg.name
  tags                = var.tags

  https_only                  = true
  enable_application_insights = false

  os_type                  = "Linux"
  service_plan_resource_id = module.asp.resource_id

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.id.resource_id]
  }

  key_vault_reference_identity_id = module.id.resource_id

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  virtual_network_subnet_id = module.vnet.subnets["AppServiceSubnet"].resource_id

  kind = "webapp"

  site_config = {
    http2_enabled          = true
    vnet_route_all_enabled = true
  }

  app_settings = {
  }

  // Mount storage for wordpress_data:/bitnami/wordpress
  storage_shares_to_mount = {
    wordpress_data = {
      name         = "WordPress"
      account_name = module.storage.name
      access_key   = module.storage.resource.primary_access_key
      share_name   = local.wp_share_name
      mount_path   = "/bitnami/wordpress"
    }
  }
}
