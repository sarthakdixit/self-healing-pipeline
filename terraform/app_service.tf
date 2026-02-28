resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # F1 = Free tier — no cost at all
  os_type  = "Linux"
  sku_name = "F1"

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ── App Service (the FastAPI app runs here) ────────────────────────────────────

resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  # Use system-assigned managed identity
  # This allows the app to access Key Vault without any credentials
  identity {
    type = "SystemAssigned"
  }

  site_config {
    # Python 3.11 runtime
    application_stack {
      python_version = "3.11"
    }

    # Always On is not available on Free tier — this is expected
    always_on = false

    # Startup command for FastAPI with uvicorn
    app_command_line = "uvicorn app.main:app --host 0.0.0.0 --port 8000"
  }

  app_settings = {
    # Tell Azure which port our app listens on
    "WEBSITES_PORT" = "8000"

    # Python path settings
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"

    # Key Vault URI — app reads secrets from here at runtime
    "KEY_VAULT_URI" = "https://kv-${var.project_name}-${var.environment}.vault.azure.net/"

    # GitHub repo info — used by healing engine
    "GITHUB_REPO"  = var.github_repo
    "GITHUB_OWNER" = var.github_owner
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}