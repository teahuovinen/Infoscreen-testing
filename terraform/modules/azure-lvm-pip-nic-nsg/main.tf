# Azurerm resources

# Public IP address
resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.nic_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = var.tags
}

# Network security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
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
  source_address_prefixes     = concat(var.nsg_ssh_security_rule_source_address) #, local.github_action_ips)
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# HTTP allow rule
resource "azurerm_network_security_rule" "http" {
  name                        = "AllowPort80"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefixes     = var.nsg_80_security_rule_source_address
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
  name                = "sshkey-${var.project_name}-${var.environment}-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = tls_private_key.private-key.public_key_openssh
  tags                = var.tags
}

# Save private key to local file
resource "local_file" "public-key" {
  filename = "${var.project_name}-${var.environment}-${var.location}.pem"
  content  = tls_private_key.private-key.private_key_pem
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "lvm" {
  name                = var.lvm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.lvm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # Install updates & Docker
  custom_data = filebase64(var.lvm_custom_data_path_to_file)

  admin_ssh_key {
    username   = "adminuser"
    public_key = azurerm_ssh_public_key.ssh-public-key.public_key
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = var.os_disk_name
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202302090"
  }
  tags = var.tags
}


# App registration
resource "azuread_application" "webapp" {
  display_name = "${var.project_name}-${var.environment}-${var.location}"
  owners       = var.app_owners
  web {
    redirect_uris = ["http://localhost/microsoft/auth-callback/"]
  }
}

# Create client secret
resource "azuread_service_principal" "client-secret" {
  application_id               = azuread_application.webapp.application_id
  app_role_assignment_required = false
  owners                       = var.app_owners
}

resource "azuread_service_principal_password" "client-secret-password" {
  service_principal_id = azuread_service_principal.client-secret.object_id
}

resource "azurerm_role_assignment" "acr-pull" {
  scope                = "${var.subscription}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${var.acr_name}"
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.client-secret.object_id
}