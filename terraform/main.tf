terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Allows secrets to be recovered if accidentally deleted
      recover_soft_deleted_key_vaults   = true
      purge_soft_delete_on_destroy      = false
    }
  }
}

# ── Data Sources ───────────────────────────────────────────────────────────────

# Get current Azure client details (used for Key Vault access policy)
data "azurerm_client_config" "current" {}

# ── Resource Group ─────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}