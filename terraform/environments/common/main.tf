terraform {
  # backend "azurerm" {
  # }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0, <4.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.general.result
  location = var.location
}


# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "cr${var.project_name}${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = local.mandatory_tags
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
  name        = var.project_name
  suffixes    = [var.environment, "cicdrunner", var.location]
  clean_input = true
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.rg.location
  vnet_name           = azurecaf_name.general.results["azurerm_virtual_network"]
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.0.0/24"]
  subnet_names        = ["VMs"]
  tags                = local.mandatory_tags
}

# Create GitHub Actions runner

module "cicd_runner" {
  source                               = "../../modules/azure-lvm-pip-nic-nsg"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  pip_name                             = azurecaf_name.general.results["azurerm_public_ip"]
  nic_name                             = azurecaf_name.general.results["azurerm_network_interface"]
  nic_subnet_id                        = lookup(module.vnet.vnet_subnets_name_id, "VMs")
  nsg_name                             = azurecaf_name.general.results["azurerm_network_security_group"]
  nsg_ssh_security_rule_source_address = var.nsg_ssh_security_rule_source_address
  nsg_80_security_rule_source_address  = var.nsg_80_security_rule_source_address
  environment                          = var.environment
  project_name                         = var.project_name
  lvm_name                             = azurecaf_name.general.results["azurerm_linux_virtual_machine"]
  lvm_size                             = var.lvm_size
  lvm_custom_data_path_to_file         = var.lvm_custom_data_path_to_file
  os_disk_name                         = azurecaf_name.general.results["azurerm_managed_disk"]
  app_owners                           = [data.azuread_client_config.current.object_id]
  subscription                         = data.azurerm_subscription.current.id
  acr_name                             = azurerm_container_registry.acr.name
  tags                                 = local.mandatory_tags
}


# Public IP address
resource "azurerm_public_ip" "pip" {
  name                = azurecaf_name.general.results["azurerm_public_ip"]
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  tags                = local.mandatory_tags
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = azurecaf_name.general.results["azurerm_network_interface"]
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = lookup(module.vnet.vnet_subnets_name_id, "VMs")
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = local.mandatory_tags
}

# Network security group
resource "azurerm_network_security_group" "nsg" {
  name                = azurecaf_name.general.results["azurerm_network_security_group"]
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.mandatory_tags
}

# SSH allow rule
resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSSH"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefixes     = var.nsg_ssh_security_rule_source_address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Atlatnis 4141 allow rule
resource "azurerm_network_security_rule" "atlantis" {
  name                        = "AllowAtlantis"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 4141
  source_address_prefixes     = var.nsg_atlantis_security_rule_source_address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}



# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create private key
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add public key
resource "azurerm_ssh_public_key" "ssh-public-key" {
  name                = "sshkey-${var.project_name}-${var.environment}-cicdrunner-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = tls_private_key.private-key.public_key_openssh
  tags                = local.mandatory_tags
}

# Save private key to local file
resource "local_file" "private-key" {
  filename = "${var.project_name}-${var.environment}-cicdrunner-${var.location}.pem"
  content  = tls_private_key.private-key.private_key_pem
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "lvm" {
  name                = azurecaf_name.general.results["azurerm_linux_virtual_machine"]
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.lvm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # Install GitHub Actions runner
  custom_data = filebase64(var.lvm_custom_data_path_to_file)

  admin_ssh_key {
    username   = "adminuser"
    public_key = azurerm_ssh_public_key.ssh-public-key.public_key
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = azurecaf_name.general.results["azurerm_managed_disk"]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  tags = local.mandatory_tags
}
