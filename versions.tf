terraform {
  required_version = ">= 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.87, < 4.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = ">= 0.2.0, < 1.0"
    }
  }
}