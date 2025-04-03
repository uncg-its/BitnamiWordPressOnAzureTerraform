variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "naming_convention" {
  type        = string
  description = "The naming convention to be used for all resources in this deployment."
  default     = "{workloadName}-{environment}-{resourceType}-{region}-{instance}"
}

variable "environment" {
  type        = string
  description = "The environment name for the resources."
  default     = "demo"
}

variable "instance" {
  type        = number
  description = "The instance number for the deployment."
  default     = 1
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry for the Azure Verified Modules."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "secret_expiration_date_seed" {
  type        = string
  description = "The seed value for the secret expiration date. Set it to today's YYYY-MM-DDT00:00:00Z."
}

// TODO: Opt-in variable to create role assignments for the current user

variable "site_name" {
  type        = string
  description = "The name of the WordPress site, which is also used for creating Azure resource names."
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault to create for storing secrets."
}

variable "key_vault_resource_group_name" {
  type        = string
  description = "The name of the resource group where the Key Vault was created."
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service Plan to use for the WordPress site."
}

variable "app_service_plan_resource_group_name" {
  type        = string
  description = "The name of the resource group where the App Service Plan was created."
}

variable "mysql_name" {
  type        = string
  description = "The name of the MySQL Flexible Server to use for the WordPress site."
}

variable "mysql_resource_group_name" {
  type        = string
  description = "The name of the resource group where the MySQL Flexible Server was created."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account to use for the WordPress site."
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "The name of the resource group where the Storage Account was created."
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the Virtual Network"
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The name of the resource group containing the Virtual Network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the Subnet"
}

variable "custom_domain_name" {
  type        = string
  description = "The custom domain name to use for the WordPress site."
  default     = ""
}
