output "storage_account_name" {
  description = "Name of the created Storage Account"
  value       = azurerm_storage_account.terraform-sa.name
}
