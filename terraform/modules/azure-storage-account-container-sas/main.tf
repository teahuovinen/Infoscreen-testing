
# Create Azure Storage Account
resource "azurerm_storage_account" "sa" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"

  tags = var.tags
}

# Create Azure Storage Container
resource "azurerm_storage_container" "ct" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "blob"

}

# Create SAS token (Disabled)
# data "azurerm_storage_account_sas" "sas" {
#   connection_string = azurerm_storage_account.sa.primary_connection_string
#   https_only        = true

#   resource_types {
#     service   = true
#     container = true
#     object    = true
#   }

#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }

#   # start  = timestamp()
#   # expiry = timeadd(timestamp(), "17520h")
#   start  = var.sas_token_start
#   expiry = var.sas_token_end


#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     filter  = false
#     tag     = false
#     update  = false
#     process = false
#   }
# }