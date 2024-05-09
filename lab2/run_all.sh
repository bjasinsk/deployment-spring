#!/bin/bash

source config.sh

RESOURCE_GROUP="lab2Config1"
FRONTEND_VM_NAME="angular"
BACKEND_VM_NAME="spring"
DB_VM_NAME="db"

front_username=$AZURE_VM_USERNAME
front_password=$AZURE_VM_PASSWORD

backend_username=$AZURE_VM_USERNAME
backend_password=$AZURE_VM_PASSWORD

database_username=$AZURE_VM_USERNAME
database_password=$AZURE_VM_PASSWORD

pip install --deps ansible
ansible-galaxy collection install azure.azcollection


ansible-playbook vars.yml --extra-vars  "azureuser=$AZURE_VM_USERNAME azurepassword=$AZURE_VM_PASSWORD"

ansible-playbook create_all_vms.yml
