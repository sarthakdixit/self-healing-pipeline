#!/bin/bash

# ==============================
# Azure Terraform State Setup
# ==============================

# Exit immediately if a command fails
set -e

# ====== CONFIGURATION ======
LOCATION="southindia"
RESOURCE_GROUP="tfstate-rg"

# Change this to something globally unique
STORAGE_ACCOUNT="tfstatesarthakdixit"

CONTAINER_NAME="tfstate"

echo "Using storage account name: $STORAGE_ACCOUNT"

# ==============================
# 1. Create Resource Group
# ==============================
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# ==============================
# 2. Create Storage Account
# ==============================
echo "Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS \
  --allow-blob-public-access false

# ==============================
# 3. Create Blob Container
# ==============================
echo "Creating storage container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT

# ==============================
# 4. Verify Container
# ==============================
echo "Verifying container..."
az storage container list \
  --account-name $STORAGE_ACCOUNT \
  --output table

echo "=================================="
echo "Terraform remote backend ready!"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $CONTAINER_NAME"
echo "=================================="