terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatesarthakdixit"
    container_name       = "tfstate"
    key                  = "self-healing-pipeline.tfstate"
  }
}