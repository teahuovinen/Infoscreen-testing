terraform {
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0, <4.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

# FIX: update from statefile in the Azure backend
# data "terraform_remote_state" "common" {
#   backend = "local"

#   config = {
#     path = "../common/terraform.tfstate"
#   }
# }

provider "azurerm" {
  skip_provider_registration = true
  features {}
  # client_id       = "needed_value_use_env_variables"
  # client_secret   = "needed_value_use_env_variables"
  # tenant_id       = "needed_value_use_env_variables"
  # subscription_id = "needed_value_use_env_variables"
}

provider "azuread" {
  # client_id       = "needed_value_use_env_variables"
  # client_secret   = "needed_value_use_env_variables"
  # tenant_id       = "needed_value_use_env_variables"

}

data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.general.result
  location = var.location
  tags     = local.mandatory_tags
}

resource "azurecaf_name" "general" {
  resource_type = "azurerm_resource_group"
  resource_types = [
    "azurerm_virtual_network",
    "azurerm_public_ip",
    "azurerm_network_interface",
    "azurerm_network_security_group",
    "azurerm_linux_virtual_machine",
    "azurerm_managed_disk"
  ]
  name        = var.project.name
  suffixes    = [var.environment, var.location]
  clean_input = true
}

resource "azurecaf_name" "sa_name" {
  resource_type = "azurerm_storage_account"
  name          = var.project_name
  suffixes      = [var.environment, var.location]
  random_length = 5
  clean_input   = true
}


module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.rg.location
  vnet_name           = azurecaf_name.general.results["azurerm_virtual_network"]
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.0.0/24", "10.1.1.0/24"]
  subnet_names        = ["VMs", "AppGateway"]
  tags                = local.mandatory_tags
}



module "storage_account" {
  source               = "../../modules/azure-storage-account-container-sas"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  storage_account_name = azurecaf_name.sa_name.result
  container_name       = "infoscreen"
  tags                 = local.mandatory_tags
}



# module "webapp" {
#   source                               = "../../modules/azure-lvm-pip-nic-nsg"
#   resource_group_name                  = azurerm_resource_group.rg.name
#   location                             = azurerm_resource_group.rg.location
#   pip_name                             = azurecaf_name.general.results["azurerm_public_ip"]
#   nic_name                             = azurecaf_name.general.results["azurerm_network_interface"]
#   nic_subnet_id                        = lookup(module.vnet.vnet_subnets_name_id, "VMs")
#   nsg_name                             = azurecaf_name.general.results["azurerm_network_security_group"]
#   nsg_ssh_security_rule_source_address = var.nsg_ssh_security_rule_source_address
#   nsg_80_security_rule_source_address  = var.nsg_80_security_rule_source_address
#   environment                          = var.environment
#   project_name                         = var.project_name
#   lvm_name                             = azurecaf_name.general.results["azurerm_linux_virtual_machine"]
#   lvm_size                             = var.lvm_size
#   lvm_custom_data_path_to_file         = var.lvm_custom_data_path_to_file
#   os_disk_name                         = azurecaf_name.general.results["azurerm_managed_disk"]
#   app_owners                           = [data.azuread_client_config.current.object_id]
#   subscription                         = data.azurerm_subscription.current.id
#   acr_name                             = data.terraform_remote_state.common.outputs.acr_name
#   tags                                 = local.mandatory_tags
# }