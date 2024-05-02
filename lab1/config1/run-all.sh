#!/bin/bash

source config.sh

RESOURCE_GROUP="lab1Config9"
FRONTEND_VM_NAME="angular"
BACKEND_VM_NAME="spring"
DB_VM_NAME="db"

front_username=$AZURE_VM_USERNAME
front_password=$AZURE_VM_PASSWORD

backend_username=$AZURE_VM_USERNAME
backend_password=$AZURE_VM_PASSWORD

database_username=$AZURE_VM_USERNAME
database_password=$AZURE_VM_PASSWORD

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $DB_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./db.sh"

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $BACKEND_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./run-back.sh" \
    --parameters "$db_PRIVATE_IP" "$db_PORT"

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $FRONTEND_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./run-front.sh" \
    --parameters "$spring_IP" "$spring_PORT" "$angular_PORT"

