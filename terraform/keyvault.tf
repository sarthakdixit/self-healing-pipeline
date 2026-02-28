resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Standard tier is free for portfolio usage volumes
  sku_name = "standard"

  # Soft delete protects against accidental deletion (7 days minimum)
  soft_delete_retention_days = 7
  purge_protection_enabled   = false  # false so terraform destroy works cleanly

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ── Key Vault Access Policy: YOUR account (to manage secrets) ─────────────────

resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover",
  ]
}

# ── Key Vault Access Policy: App Service Managed Identity ─────────────────────
# The App Service can READ secrets but cannot modify them

resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  # The managed identity object ID of our App Service
  object_id = azurerm_linux_web_app.main.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

# ── Secrets stored in Key Vault ───────────────────────────────────────────────

# GitHub PAT — used by healing engine to call GitHub API
resource "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  value        = var.github_token
  key_vault_id = azurerm_key_vault.main.id

  # Access policy must exist before we can write secrets
  depends_on = [azurerm_key_vault_access_policy.admin]

  tags = {
    managed_by = "terraform"
  }
}