locals {
  subscription_id = var.subscription_id

  instance_formatted = format("%02d", var.instance)

  naming_structure = replace(replace(replace(replace(var.naming_convention, "{workloadName}", var.workload_name), "{environment}", var.environment), "{region}", local.short_locations[var.location]), "{instance}", local.instance_formatted)

  vnet_address_cidr = tonumber(split("/", var.address_space[0])[1])

  dbadmin_password_kv_secret_name = "dbadmin-password"

  // Add 1 year based on calendar dates, not days in the year, etc.
  start_year  = tonumber(formatdate("YYYY", var.secret_expiration_date_seed))
  start_month = formatdate("MM", var.secret_expiration_date_seed)
  start_day   = formatdate("DD", var.secret_expiration_date_seed)
  next_year   = local.start_year + 1
  next_date   = "${local.next_year}-${local.start_month}-${local.start_day}"

  secret_expiration_date = "${local.next_date}T00:00:00Z"
}

locals {
  short_locations = {
    "canadacentral" = "cnc"
    "centralus"     = "cus"
    "eastus"        = "eus"
    "eastus2"       = "eus2"
  }
}
