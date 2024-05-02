#!/bin/bash

RESOURCE_GROUP="lab1Config9"
LOCATION="polandcentral"
FRONTEND_VM_NAME="angular"
BACKEND_VM_NAME="spring"
DB_VM_NAME="db"
FRONTEND_VM_SIZE="Standard_B2s"
BACKEND_VM_SIZE="Standard_B2s"
DB_VM_SIZE="Standard_DS1_v2"
USERNAME=$AZURE_VM_USERNAME
PASSWORD=$AZURE_VM_PASSWORD
FRONTEND_PORT=4200
FRONTEND_PRIVATE_IP="10.0.4.7"
BACKEND_PORT=9966
BACKEND_PRIVATE_IP="10.0.4.8"
DB_PORT=3306
DB_PRIVATE_IP="10.0.4.9"
SSH_PORT=22
NETWORK_ADDR_PREFIX="10.0.0.0/16"
SUBNET_PREFIX="10.0.4.0/24"
NSG_NAME="NSGLAB1"

echo "" > config.sh

if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Grupa zasobów: '$RESOURCE_GROUP' już istnieje"
else
    echo "Tworzenie nowej grupy zasobów..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

echo $USERNAME

az network vnet create\
    --name VNet \
    --resource-group $RESOURCE_GROUP \
    --address-prefix $NETWORK_ADDR_PREFIX


az network vnet subnet create \
    --name subnet_lab1 \
    --resource-group $RESOURCE_GROUP \
    --vnet-name VNet \
    --address-prefixes $SUBNET_PREFIX \


create_vm() {
    VM_NAME=$1
    VM_SIZE=$2
    VM_PORT=$3
    VM_PRIVATE_ADDR=$4
    NSG_NAME="${VM_NAME}NSG"

    az network nsg create \
        --name $NSG_NAME \
        --resource-group $RESOURCE_GROUP


    az network nsg rule create --resource-group $RESOURCE_GROUP \
        --nsg-name $NSG_NAME \
        --name "${VM_NAME}AllowSSH" \
        --protocol tcp \
        --priority 1000 \
        --destination-port-ranges $SSH_PORT \
        --access Allow \
        --direction Inbound

    az network nsg rule create --resource-group $RESOURCE_GROUP \
        --nsg-name $NSG_NAME \
        --name "${VM_NAME}AllowAllInbound" \
        --priority 900 \
        --access Allow \
        --direction Inbound \
        --protocol '*' \
        --destination-port-ranges '*' \
        --source-port-ranges '*'

    az network nsg rule create --resource-group $RESOURCE_GROUP \
        --nsg-name $NSG_NAME \
        --name "${VM_NAME}AllowAllOutbound" \
        --priority 900 \
        --access Allow \
        --direction Outbound \
        --protocol '*' \
        --destination-port-ranges '*' \
        --source-port-ranges '*'

    echo "Tworzenie VM: $VM_NAME o rozmiarze $VM_SIZE..."
    VM_RESULT=$(az vm create \
        --resource-group $RESOURCE_GROUP \
        --vnet-name VNet \
        --name $VM_NAME \
        --subnet subnet_lab1 \
        --size $VM_SIZE \
        --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
        --admin-username $USERNAME \
        --admin-password $PASSWORD \
        --authentication-type password \
        --private-ip-address $VM_PRIVATE_ADDR \
        --public-ip-address-dns-name "${VM_NAME}-$RANDOM" \
        --nsg $NSG_NAME \
        --output json)

    IP_ADDRESS=$(echo $VM_RESULT | jq -r '.publicIpAddress')
    echo "export ${VM_NAME}_IP=$IP_ADDRESS" >> config.sh
    echo "export ${VM_NAME}_PORT=$VM_PORT" >> config.sh
    echo "export ${VM_NAME}_PRIVATE_IP=$VM_PRIVATE_ADDR" >> config.sh
}


create_vm $FRONTEND_VM_NAME $FRONTEND_VM_SIZE $FRONTEND_PORT $FRONTEND_PRIVATE_IP
create_vm $BACKEND_VM_NAME $BACKEND_VM_SIZE $BACKEND_PORT $BACKEND_PRIVATE_IP
create_vm $DB_VM_NAME $DB_VM_SIZE $DB_PORT $DB_PRIVATE_IP

echo "Adresy IP stworzonych maszyn wirtualnych:"
cat config.sh
