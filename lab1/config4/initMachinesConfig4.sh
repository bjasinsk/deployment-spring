#!/bin/bash

RESOURCE_GROUP="lab1Config4"
FRONTEND_LOCATION="germanywestcentral"
OTHERS_LOCATION="eastus"

FRONTEND_VM_NAME="angular"
BACKEND_VM_NAME="spring"
DB_VM_NAME="db"
LOADER_VM_NAME="loader"


FRONTEND_VM_SIZE="Standard_B2s"
BACKEND_VM_SIZE="Standard_B2s"
DB_VM_SIZE="Standard_DS1_v2"
LOADER_VM_SIZE="Standard_B1s"


USERNAME=$AZURE_VM_USERNAME
PASSWORD=$AZURE_VM_PASSWORD

FRONTEND_PORT=4200
BACKEND_PORT=9966
DB_PORT_POST=3306
LOADER_PORT=8080
SPRING2_PORT=4100
DB_PORT_GET=3307
SSH_PORT=22 

echo "" > config.sh

if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Grupa zasobów: '$RESOURCE_GROUP' już istnieje"
else
    echo "Tworzenie nowej grupy zasobów..."
    az group create --name $RESOURCE_GROUP --location $FRONTEND_LOCATION
fi

echo $USERNAME

create_vm() {
    VM_NAME=$1
    VM_SIZE=$2
    VM_PORT=$3
    VM_LOCATION=$4
    NSG_NAME="${VM_NAME}NSG"

    az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME --location $VM_LOCATION

    echo "Tworzenie VM: $VM_NAME o rozmiarze $VM_SIZE..."
    VM_RESULT=$(az vm create \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --size $VM_SIZE \
        --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
        --admin-username $USERNAME \
        --admin-password $PASSWORD \
        --authentication-type password \
        --public-ip-address-dns-name "${VM_NAME}-$RANDOM" \
        --nsg $NSG_NAME \
        --location $VM_LOCATION \
        --output json)

    IP_ADDRESS=$(echo $VM_RESULT | jq -r '.publicIpAddress')
    echo "export ${VM_NAME}_IP=$IP_ADDRESS" >> config.sh
    echo "export ${VM_NAME}_PORT=$VM_PORT" >> config.sh

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
        --name "${VM_NAME}Allow$VM_PORT" \
        --protocol tcp \
        --priority 1010 \
        --destination-port-ranges $VM_PORT \
        --access Allow \
        --direction Inbound

    az network nsg rule create --resource-group $RESOURCE_GROUP \
        --nsg-name $NSG_NAME \
        --name "${VM_NAME}AllowOutbound$VM_PORT" \
        --protocol tcp \
        --priority 1100 \
        --destination-port-ranges $VM_PORT \
        --access Allow \
        --direction Outbound
}

create_db() {
    VM_NAME=$1
    VM_SIZE=$2
    VM_PORT_POST=$3
    VM_LOCATION=$4
    VM_PORT_GET=$5
    NSG_NAME="${VM_NAME}NSG"

    az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME --location $VM_LOCATION

    echo "Tworzenie VM: $VM_NAME o rozmiarze $VM_SIZE..."
    VM_RESULT=$(az vm create \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --size $VM_SIZE \
        --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
        --admin-username $USERNAME \
        --admin-password $PASSWORD \
        --authentication-type password \
        --public-ip-address-dns-name "${VM_NAME}-$RANDOM" \
        --nsg $NSG_NAME \
        --location $VM_LOCATION \
        --output json)

    IP_ADDRESS=$(echo $VM_RESULT | jq -r '.publicIpAddress')
    echo "export ${VM_NAME}_IP=$IP_ADDRESS" >> config.sh
    echo "export ${VM_NAME}_PORT_POST=$VM_PORT_POST" >> config.sh
    echo "export ${VM_NAME}_PORT_GET=$VM_PORT_GET" >> config.sh


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
        --name "${VM_NAME}Allow$VM_PORT_POST" \
        --protocol tcp \
        --priority 1010 \
        --destination-port-ranges $VM_PORT_POST \
        --access Allow \
        --direction Inbound

    az network nsg rule create --resource-group $RESOURCE_GROUP \
        --nsg-name $NSG_NAME \
        --name "${VM_NAME}AllowOutbound$VM_PORT_GET" \
        --protocol tcp \
        --priority 1100 \
        --destination-port-ranges $VM_PORT_GET \
        --access Allow \
        --direction Outbound
}




create_vm $FRONTEND_VM_NAME $FRONTEND_VM_SIZE $FRONTEND_PORT $FRONTEND_LOCATION
create_vm $BACKEND_VM_NAME $BACKEND_VM_SIZE $BACKEND_PORT $OTHERS_LOCATION
create_vm $LOADER_VM_NAME $LOADER_VM_SIZE $LOADER_PORT $OTHERS_LOCATION
create_db $DB_VM_NAME $DB_VM_SIZE $DB_PORT_POST $OTHERS_LOCATION $DB_PORT_GET


echo "Adresy IP stworzonych maszyn wirtualnych:"
cat config.sh
