resource "random_password" "wpadmin_random_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_key_vault_secret" "wp_admin_password" {
  name         = local.wpadmin_password_kv_secret_name
  value        = resource.random_password.wpadmin_random_password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  expiration_date = local.secret_expiration_date
}
