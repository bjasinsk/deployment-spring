#!/bin/bash

source config.sh

RESOURCE_GROUP="lab1Config4"
FRONTEND_VM_NAME="angular"
BALANCER_VM_NAME="balancer"
BACKEND_GET_VM_NAME="spring_get"
BACKEND_POST_VM_NAME="spring_post"
DB_GET_VM_NAME="db_get"
DB_POST_VM_NAME="db_post"

front_username=$AZURE_VM_USERNAME
front_password=$AZURE_VM_PASSWORD

backend_get_username=$AZURE_VM_USERNAME
backend_get_password=$AZURE_VM_PASSWORD

database_get_username=$AZURE_VM_USERNAME
database_get_password=$AZURE_VM_PASSWORD

backend_post_username=$AZURE_VM_USERNAME
backend_post_password=$AZURE_VM_PASSWORD

database_post_username=$AZURE_VM_USERNAME
database_post_password=$AZURE_VM_PASSWORD

database_username=$AZURE_VM_USERNAME
database_password=$AZURE_VM_PASSWORD

balancer_username=$AZURE_VM_USERNAME
balancer_password=$AZURE_VM_PASSWORD

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $DB_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./db.sh"

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $BACKEND_GET_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./run-back-get.sh" \
    --parameters "$db_IP" "$db_PORT"

az vm run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --name $BACKEND_POST_VM_NAME \
    --command-id RunShellScript \
    --scripts "@./run-back-get.sh" \
    --parameters "$db_IP" "$db_PORT"

sed -i "s/"ip_backend_get"/$backend_IP_get:$backend_port_get/g" default
sed -i "s/"ip_backend_post"/$backend_IP_post:$backend_port_post/g" default

./run-front.sh "$front_password" "$front_username" "$angular_IP" "$angular_PORT" "$spring_IP" "$spring_PORT"

