# These values are printed after terraform apply completes.
# Copy these into your GitHub Secrets.

output "app_service_url" {
  description = "URL of the deployed FastAPI app"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_name" {
  description = "Name of the App Service (needed for GitHub Actions deploy step)"
  value       = azurerm_linux_web_app.main.name
}

output "resource_group_name" {
  description = "Resource group containing all resources"
  value       = azurerm_resource_group.main.name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI for app settings"
  value       = azurerm_key_vault.main.vault_uri
}

output "app_service_principal_id" {
  description = "Managed Identity principal ID of App Service (for RBAC if needed)"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}