
LOCATION="eastus"
RESOURCE_GROUP_NAME="az204-functions"
FUNCTIONS_STORAGE_ACCOUNT="az204azfuncstorage"
FUNCTIONS_APP_NAME="az204-functions-todo-list-app"
COSMOS_ACCOUNT_NAME="az204-functions-cosmos-account"
COSMOS_DATABASE_NAME="todo-database"
COSMOS_COLLECTION_NAME="tasks"



# Create the resource group
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

# This is the Storage account used by the functions app
az storage account create \
    --name $FUNCTIONS_STORAGE_ACCOUNT \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP_NAME \
    --sku Standard_LRS

# This creates the function app
az functionapp create \
    --resource-group $RESOURCE_GROUP_NAME \
    --consumption-plan-location $LOCATION \
    --runtime dotnet \
    --functions-version 4 \
    --name $FUNCTIONS_APP_NAME \
    --storage-account $FUNCTIONS_STORAGE_ACCOUNT

# Creates the CosmosDB Account
az cosmosdb create \
    --name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME

# Creates the database where data will be stored in Cosmos
az cosmosdb sql database create \
    --name $COSMOS_DATABASE_NAME \
    --account-name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME 

# Creates the Collection (Table) that the app will use
az cosmosdb sql container create \
    --name $COSMOS_COLLECTION_NAME \
    --partition-key-path "/id" \
    --database-name $COSMOS_DATABASE_NAME \
    --account-name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME

# Grabs the CosmosDB Connection string and puts it in an environment variable
COSMOS_CONNECTION_STRING=`az cosmosdb keys list \
    --name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --type "connection-strings" \
    --query "connectionStrings[?description== 'Primary SQL Connection String'].connectionString" \
    --output tsv`

# Sets the Connection string for the functions app to use
az functionapp config appsettings set \
    --name $FUNCTIONS_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --settings "CosmosDBConnectionString=$COSMOS_CONNECTION_STRING"


# Command to delete resource group and all resources
# az group delete \
#    --name $RESOURCE_GROUP_NAME \
#    --no-wait
