#!/bin/bash

# This script will run an ARM template deployment to deploy all the
# required resources into Azure. All the keys, tokens and endpoints
# will be automatically retreived and set as required environment
# variables.
# Requirements:
# Azure CLI (log in)

# This script is setting environment variables needed by the processor.
# There for you must run this script using the source command.
# source setup.sh
# If you just run the command using ./setup.sh the resources in Azure will be
# created but the environment variables will not be set.

### VARIABLES ####
export APIM_SERVICE_NAME="apiserviceu6a6xbzfqp3ks"
export AZ_SUBSCRIPTION_ID="b05c9d81-b1b3-44f3-988e-1cc935f55075" ##TODO: Change hardcoded value
export AZ_RESOURCE_GROUP="apim_dapr"

function getOutput {
   echo $(az deployment sub show --name $rgName --query "properties.outputs.$1.value" --output tsv)
}

# The name of the resource group to be created. All resources will be place in
# the resource group and start with name.
rgName=$1
rgName=${rgName:-apim_dapr}

# # The location to store the meta data for the deployment.
location=$2
location=${location:-francecentral}


##############################################
################ AZURE APIM ##################
##############################################

# # Deploy the infrastructure (APIM)
az deployment sub create --name $rgName --location $location --template-file iac/main.bicep --parameters rgName=$rgName activate_aks='false' --output none

### I.1 API Configuration ###
az apim api import --path / \
                   --api-id dapr \
                   --subscription $AZ_SUBSCRIPTION_ID \
                   --resource-group $AZ_RESOURCE_GROUP \
                   --service-name $APIM_SERVICE_NAME \
                   --display-name "Demo Dapr Service API" \
                   --protocols http https \
                   --subscription-required true \
                   --specification-path apim/api.yaml \
                   --specification-format OpenApi


### I.2 Get Azure Api Token ###
export AZ_API_TOKEN=$(az account get-access-token --resource=https://management.azure.com --query accessToken --output tsv)

### I.3 Apply Global Policy ###
curl -i -X PUT \
     -d @apim/policy-all.json \
     -H "Content-Type: application/json" \
     -H "If-Match: *" \
     -H "Authorization: Bearer ${AZ_API_TOKEN}" \
     "https://management.azure.com/subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE_NAME}/apis/dapr/policies/policy?api-version=2019-12-01"

### I.4 Message Topic Policy ###
curl -i -X PUT \
     -d @apim/policy-message.json \
     -H "Content-Type: application/json" \
     -H "If-Match: *" \
     -H "Authorization: Bearer ${AZ_API_TOKEN}" \
     "https://management.azure.com/subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE_NAME}/apis/dapr/operations/message/policies/policy?api-version=2019-12-01"

### I.5 Save Binding Policy
curl -i -X PUT \
     -d @apim/policy-save.json \
     -H "Content-Type: application/json" \
     -H "If-Match: *" \
     -H "Authorization: Bearer ${AZ_API_TOKEN}" \
     "https://management.azure.com/subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE_NAME}/apis/dapr/operations/save/policies/policy?api-version=2019-12-01"

### I.6 Gateway Configuration
curl -i -X PUT -d '{"properties": {"description": "Dapr Gateway","locationData": {"name": "Virtual"}}}' \
     -H "Content-Type: application/json" \
     -H "If-Match: *" \
     -H "Authorization: Bearer ${AZ_API_TOKEN}" \
     "https://management.azure.com/subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE_NAME}/gateways/demo-apim-gateway?api-version=2019-12-01"

### I.7 Map the gateway to the created API ###
curl -i -X PUT -d '{ "properties": { "provisioningState": "created" } }' \
     -H "Content-Type: application/json" \
     -H "If-Match: *" \
     -H "Authorization: Bearer ${AZ_API_TOKEN}" \
     "https://management.azure.com/subscriptions/${AZ_SUBSCRIPTION_ID}/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ApiManagement/service/${APIM_SERVICE_NAME}/gateways/demo-apim-gateway/apis/dapr?api-version=2019-12-01"



##############################################
################ AZURE AKS ###################
##############################################
# # Deploy the infrastructure (AKS)
#az deployment sub create --name $rgName --location $location --template-file iac/main.bicep --parameters rgName=$rgName activate_apim='false' --output none

# Get all the outputs
# cognitiveServiceKey=$(getOutput 'cognitiveServiceKey')
# cognitiveServiceEndpoint=$(getOutput 'cognitiveServiceEndpoint')

# export CS_TOKEN=$cognitiveServiceKey
# export CS_ENDPOINT=$cognitiveServiceEndpoint

# printf "You can now run the processor from this terminal.\n"
