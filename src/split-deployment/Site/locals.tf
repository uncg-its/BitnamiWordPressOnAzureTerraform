locals {
  subscription_id = var.subscription_id

  instance_formatted = format("%02d", var.instance)

  naming_structure = replace(replace(replace(replace(var.naming_convention, "{workloadName}", var.site_name), "{environment}", var.environment), "{region}", local.short_locations[var.location]), "{instance}", local.instance_formatted)

  // This is in the Foundation deployment
  dbadmin_password_kv_secret_name = "dbadmin-password"

  wpadmin_password_kv_secret_name = "${var.site_name}-wpadmin-password"

  wp_database_name = "${var.site_name}_wordpress_db"

  // Add 1 year based on calendar dates, not days in the year, etc.
  start_year  = tonumber(formatdate("YYYY", var.secret_expiration_date_seed))
  start_month = formatdate("MM", var.secret_expiration_date_seed)
  start_day   = formatdate("DD", var.secret_expiration_date_seed)
  next_year   = local.start_year + 1
  next_date   = "${local.next_year}-${local.start_month}-${local.start_day}"

  secret_expiration_date = "${local.next_date}T00:00:00Z"

  wp_share_name = "${var.site_name}-wordpress"
}

locals {
  short_locations = {
    "canadacentral" = "cnc"
    "centralus"     = "cus"
    "eastus"        = "eus"
    "eastus2"       = "eus2"
  }
}
