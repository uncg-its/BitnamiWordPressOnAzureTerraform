resource "azurerm_traffic_manager_profile" "profile" {
  name                = replace(local.naming_structure, "{resourceType}", "traf")
  resource_group_name = module.app_rg.name
  tags                = var.tags

  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${var.site_name}-${var.environment}-${var.instance}"
    ttl           = 30
  }

  monitor_config {
    protocol                    = "HTTPS"
    port                        = 443
    path                        = "/"
    expected_status_code_ranges = ["200-202", "301-302"]
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "endpoint" {
  profile_id         = azurerm_traffic_manager_profile.profile.id
  name               = "AppServiceEndpoint"
  target_resource_id = module.appservice.resource_id
  priority           = 10
}
