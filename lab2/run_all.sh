#!/bin/bash

sudo apt update
sudo apt install python3-pip -y
pip install ansible azure-mgmt-resource msrest msrestazure azure-common --upgrade
ansible-galaxy collection install azure.azcollection --upgrade
pip install --upgrade jinja2

# source config.sh

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

# pip install --deps ansible
# ansible-galaxy collection install azure.azcollection
pip install -r azure-requirements.txt


# pip install azure-mgmt


pip install --upgrade ansible
ansible-galaxy collection install azure.azcollection --force
ansible-galaxy collection install azure.azcollection --upgrade


# pliku vars.yml nie odpala się jako playbook chyba albo nie umiem tego odpalić tak
# ansible-playbook vars.yml --extra-vars  "azureuser=$AZURE_VM_USERNAME azurepassword=$AZURE_VM_PASSWORD"

#ansible-playbook create_all_vms.yml
ansible-playbook create_all_vms.yml --extra-vars "azureuser=$AZURE_VM_USERNAME azurepassword=$AZURE_VM_PASSWORD"
