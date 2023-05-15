terraform {
  # backend "azurerm" {
  # }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.4.3"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
  }
}

resource "random_integer" "suffix" {
  min = 10
  max = 99
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${local.environment}"
  location = var.location
}

resource "azurerm_storage_account" "terraform-sa" {
  name                            = "${lower(var.project_name)}${random_integer.suffix.result}tfbe"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }
  #   lifecycle {
  #     prevent_destroy = true
  #   }

  tags = local.mandatory_tags
}

resource "azurerm_storage_container" "tfstatefile" {
  name                 = "terraform-state-file"
  storage_account_name = azurerm_storage_account.terraform-sa.name

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}
