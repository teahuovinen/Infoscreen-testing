output "public_ip" {
  description = "Public IP attached to Linux Virtual Machine"
  value       = azurerm_public_ip.pip.ip_address
}

output "app_client_secret" {
  value     = azuread_service_principal_password.client-secret-password.value
  sensitive = true
}

output "app_id" {
  value     = azuread_application.webapp.application_id
  sensitive = true
}
