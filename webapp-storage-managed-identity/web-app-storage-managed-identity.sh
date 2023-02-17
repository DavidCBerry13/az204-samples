# Creates a web app using Azure App Services that will access Blob Storage using Managed Identity

# Scenario
#   User has a web app that they use to upload and download files to Blob Storage from

# Azure Services Used
#   - Azure App Service
#   - Azure Blob Storage
#   - Azure Managed Identity


# App Service Plan SKUs
#    B1, B2, B3, D1, F1, FREE, I1, I1v2, I2, I2v2, I3, I3v2, I4v2, I5v2, I6v2, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, S1, S2, S3, SHARED, WS1, WS2, WS3

# List App Service Runtimes
#    az webapp list-runtimes --os {linux, windows}




LOCATION=eastus
RESOURCE_GROUP_NAME=az204-storage-app-demo
APP_PLAN_NAME=az204-storage-app-demo
APP_PLAN_SKU=FREE      
WEB_APP_NAME=az204-storage-app-demo-dcb
RUNTIME="dotnet:6"
STORAGE_ACCOUNT_NAME=az204storageappdemodcb
STORAGE_CONTAINER_NAME=files

# Create the resource group
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION


# Create the App Service Plan - Free is fine for us
az appservice plan create \
    --name $APP_PLAN_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --sku $APP_PLAN_SKU


# Create the Web App
#     The --assign-identity flag will turn on a system assigned managed identity for this web app
az webapp create \
    --name $WEB_APP_NAME \
    --plan $APP_PLAN_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --runtime $RUNTIME \
    --assign-identity '[system]'


# Create the Storage Account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

# We need an account key or storage connection string to create the container otherwise the CLI commands complain
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --output tsv)


# Create the container where files (images) will be uploaded to
az storage container create \
    --name $STORAGE_CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --connection-string $STORAGE_CONNECTION_STRING


# This is the id of the managed identity for the web app
WEB_APP_PRINCIPAL_ID=$(az webapp show --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --query identity.principalId --output tsv)

# This is the resource id of the storage account
STORAGE_RESOURCE_ID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --query id --output tsv)

# The Azure CLI does not give us a way to get the Container Resource ID directly.  But the form is of the following
#     /subscriptions/<subscription>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account>/blobServices/default/containers/<container-name>
# If we take the storage account resource id and append on the container info, then we have it.
CONTAINER_RESOURCE_ID="$STORAGE_RESOURCE_ID/blobServices/default/containers/$STORAGE_CONTAINER_NAME"


# For the managed identity of the web app, give it contributor access to Blob Storage
az role assignment create \
    --assignee $WEB_APP_PRINCIPAL_ID \
    --scope $CONTAINER_RESOURCE_ID \
    --role "Storage Blob Data Contributor"

# Blank out the storage connction string varaible so it is not still set
STORAGE_CONNECTION_STRING=''

