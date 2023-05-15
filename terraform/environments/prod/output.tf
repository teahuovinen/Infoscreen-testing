output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.storage_account.storage_account_name
}

output "blob_storage_credential" {
  description = "Storage Account primary_access_key"
  value       = module.storage_account.storage_account_primary_access_key
  sensitive   = true
}

output "vm_public_ip" {
  description = "Public IP attached to Linux Virtual Machine"
  value       = module.webapp.public_ip
}

output "acr_url" {
  description = "URL to ACR"
  value       = "${data.terraform_remote_state.common.outputs.acr_name}.azurecr.io"
}

output "app_client_secret" {
  description = "App Client Secret"
  value       = module.webapp.app_client_secret
  sensitive   = true
}

output "app_id" {
  description = "App ID"
  value       = module.webapp.app_id
  sensitive   = true
}

output "tenant_id" {
  description = "Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
  sensitive   = true
}
