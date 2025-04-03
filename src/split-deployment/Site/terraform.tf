terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.24.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}

data "azurerm_client_config" "current" {}
