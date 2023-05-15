output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.sa.name
}

output "storage_account_primary_access_key" {
  description = "Primary Access Key for Storage account"
  value       = azurerm_storage_account.sa.primary_access_key
  sensitive   = true
}

# output "sas_token" {
#   description = "SAS token for Storage Account"
#   value       = data.azurerm_storage_account_sas.state.sas
#   sensitive   = true
# }