#!/bin/bash

RESOURCE_GROUP="lab1Config1"
LOCATION="polandcentral"
FRONTEND_VM_NAME="angular"
BACKEND_VM_NAME="spring"
DB_VM_NAME="db"
FRONTEND_VM_SIZE="Standard_B2s"
BACKEND_VM_SIZE="Standard_B2s"
DB_VM_SIZE="Standard_DS1_v2"
USERNAME=$AZURE_VM_USERNAME
PASSWORD=$AZURE_VM_PASSWORD

if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Grupa zasobów: '$RESOURCE_GROUP' już istnieje"
else
    echo "Tworzenie nowej grupy zasobów..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

create_vm() {
    VM_NAME=$1
    VM_SIZE=$2
    echo "Tworzenie VM: $VM_NAME o rozmiarze $VM_SIZE..."
    az vm create \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --size $VM_SIZE \
        --image "Canonical:UbuntuServer:18_04-lts-gen2:latest" \
        --admin-username $USERNAME \
        --admin-password $PASSWORD \
        --authentication-type password \
        --public-ip-address-dns-name "${VM_NAME}-$RANDOM" \
        --nsg-rule SSH
}

create_vm $FRONTEND_VM_NAME $FRONTEND_VM_SIZE
create_vm $BACKEND_VM_NAME $BACKEND_VM_SIZE
create_vm $DB_VM_NAME $DB_VM_SIZE

echo "Adresy IP stworzonych maszyn wirtualnych:"
az vm list-ip-addresses --resource-group $RESOURCE_GROUP --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" -o tsv
