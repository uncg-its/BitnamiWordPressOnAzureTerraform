resource "azurerm_storage_share" "share" {
  name               = local.wp_share_name
  storage_account_id = data.azurerm_storage_account.storage.id
  quota              = 1024
}
