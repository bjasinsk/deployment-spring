#!/bin/bash

RESOURCE_GROUP="lab3config"

az group create --name $RESOURCE_GROUP --location polandcentral

az aks create --resource-group $RESOURCE_GROUP \
    --name lab3cluster \
    --enable-managed-identity \
    --node-count 2 \
    --generate-ssh-keys

# az aks enable-addons --addons monitoring \
#     --resource-group $RESOURCE_GROUP \
#     --name lab3cluster

az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name lab3cluster

kubectl get nodes
