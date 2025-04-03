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

locals {
  // Calculate the maximum length of the workload name based on other inputs
  // The restriction is the maximum length of the Key Vault name (24 characters)
  workload_name_max_length = 24 - length(var.environment) - length("-") - length("-${local.short_locations[var.location]}") - length("-00") - length("-kv")
}

variable "workload_name" {
  type        = string
  description = "The name of the workload to be deployed."
  validation {
    condition     = length(var.workload_name) <= local.workload_name_max_length
    error_message = "The maximum length is ${local.workload_name_max_length}, which is based on some other inputs. '${var.workload_name}' is ${length(var.workload_name)} characters long."
  }
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

variable "address_space" {
  type        = list(string)
  description = "The address space(s) for the virtual network."
  default     = ["10.10.10.0/24"]

  validation {
    condition     = tonumber(split("/", var.address_space[0])[1]) <= 24
    error_message = "The provided address space '${var.address_space[0]}' must be at least /24."
  }
  validation {
    condition     = can(cidrhost(var.address_space[0], 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "enable_high_availability" {
  type        = bool
  description = "Enable high availability for resources, including MySQL and Application Service."
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

variable "deploy_test_appservice" {
  type        = bool
  description = "Deploy a test App Service to the App Service Plan."
  default     = false
}

// TODO: Opt-in variable to create role assignments for the current user
