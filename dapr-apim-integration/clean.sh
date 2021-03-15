#!/bin/bash

# This script will run an ARM template deployment to clean all the
# created resources. All the keys, tokens and endpoints
# will be automatically retreived and set as required environment
# variables.
# Requirements:
# Azure CLI (log in)

export AZ_RESOURCE_GROUP="apim_dapr"

az group delete --name $AZ_RESOURCE_GROUP