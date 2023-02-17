# Use Event Hub to send notifications for when Blobs are created in a Blob Storage Container.  The events will be forwarded to a queue for processing

# Scenario
#   Often times you have a need to listen for storage events like a file arriving in a Blob container so you can process that file.  Event Hubs gives
#   you the ability to notify based on such events and call a web hook.  In this scenario though, I am not calling a webhook, but instead putting the 
#   messages into an Azure Storage Queue.  This way they could be picked up and processed later by another process and you don't have to worry about
#   the webhook target being down

# Azure Services Used
#   - Azure Event Hubs
#   - Azure Blob Storage
#   - Azure Storage Queues

# Environment Variables

LOCATION=eastus
RESOURCE_GROUP_NAME=az204-event-grid-demo
STORAGE_ACCOUNT_NAME=az204eventgriddemodcb
STORAGE_CONTAINER_NAME=datafiles
STORAGE_QUEUE_NAME=az204-event-grid-queue
EVENT_HUB_SUBSCRIPTION_NAME=az204-event-grid-queue-subscription
INCLUDED_EVENT_TYPES="Microsoft.Storage.BlobCreated"


# Event Grid needs to be enabled at a subscription level
az provider register --namespace Microsoft.EventGrid

az provider show --namespace Microsoft.EventGrid --query "registrationState"


# Create the resource group
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

# Create the storage account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

# We need an account key or storage connection string to create the container and queue, otherwise the CLI commands complain
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --output tsv)


# Create the container where files (images) will be uploaded to
az storage container create \
    --name $STORAGE_CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --connection-string $STORAGE_CONNECTION_STRING


# Create the storage queue - This is where we are going to forward our events to
az storage queue create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --name $STORAGE_QUEUE_NAME \
    --connection-string $STORAGE_CONNECTION_STRING


az storage queue list \
    --account-name $STORAGE_ACCOUNT_NAME \
    --connection-string $STORAGE_CONNECTION_STRING

# Clear the connecttion string environment variable since we don't need it anymore
STORAGE_CONNECTION_STRING=''

# The CLI doesn't give us a way to get the get the Queue Resource ID, but knowing the form, we can construct it ourselves using the storage resource id
STORAGE_RESOURCE_ID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv)
QUEUE_ENDPOINT_ID="$STORAGE_RESOURCE_ID/queueservices/default/queues/$STORAGE_QUEUE_NAME"

# Create the event grid subscription.  This sends the event to a Storage Queue rather than a webhook
az eventgrid event-subscription create \
    --name $EVENT_HUB_SUBSCRIPTION_NAME \
    --source-resource-id $STORAGE_RESOURCE_ID \
    --included-event-types $INCLUDED_EVENT_TYPES \
    --endpoint-type storagequeue \
    --endpoint $QUEUE_ENDPOINT_ID \
    --storage-queue-msg-ttl 300





# To remove the rsource group, run the following command
# az group delete --name $RESOURCE_GROUP_NAME --no-wait


