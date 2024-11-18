terraform {
  required_version = ">= 1.2"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.98, < 4.0"
    }
  }
}
