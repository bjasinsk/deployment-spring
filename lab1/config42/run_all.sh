#! /bin/bash

az account show -o none

RESOURCE_GROUP="$(jq -r '.resource_group' ./config.json)"

USERNAME=$AZURE_VM_USERNAME
PASSWORD=$AZURE_VM_PASSWORD

echo $RESOURCE_GROUP

az group create --name $RESOURCE_GROUP --location westeurope

NETWORK_ADDRESS_PREFIX="$(jq -r '.network_address_prefix' ./config.json)"

az network vnet create\
    --name VNet \
    --resource-group $RESOURCE_GROUP \
    --address-prefix $NETWORK_ADDRESS_PREFIX

readarray -t NETWORK_SECURITY_GROUPS < <(jq -c '.network_security_group[]' "./config.json")

for NGS in ${NETWORK_SECURITY_GROUPS[@]}; do
    echo $NGS

    NGS_NAME="$(jq -r ".name" <<< $NGS)"
    echo $NGS_NAME

    az network nsg create \
        --name $NGS_NAME \
        --resource-group $RESOURCE_GROUP

    readarray -t RULES < <(jq -c '.rule[]' <<< $NGS)

    for RULE in "${RULES[@]}"; do
        echo $RULE

        RULE_NAME=$(jq -r ".name" <<< $RULE)
        RULE_PRIORITY=$(jq -r ".priority" <<< $RULE)
        RULE_SOURCE_ADDRESS_PREFIX=$(jq -r ".source_address_prefix" <<< $RULE)
        RULE_SOURCE_PORT_RANGE=$(jq -r ".source_port_range" <<< $RULE)
        RULE_DESTINATION_ADDRESS_PREFIX=$(jq -r ".destination_address_prefix" <<< $RULE)
        RULE_DESTINATION_PORT_RANGE=$(jq -r ".destination_port_range" <<< $RULE)


        az network nsg rule create \
            --name "$RULE_NAME"IN \
            --nsg-name $NGS_NAME \
            --priority $RULE_PRIORITY \
            --resource-group $RESOURCE_GROUP \
            --access Allow \
            --destination-address-prefixes "$RULE_DESTINATION_ADDRESS_PREFIX" \
            --destination-port-ranges "$RULE_DESTINATION_PORT_RANGE" \
            --protocol "*" \
            --source-address-prefixes "$RULE_SOURCE_ADDRESS_PREFIX" \
            --source-port-ranges "$RULE_SOURCE_PORT_RANGE" \
            --direction Inbound

        az network nsg rule create \
            --name "$RULE_NAME"OUT \
            --nsg-name $NGS_NAME \
            --priority $RULE_PRIORITY \
            --resource-group $RESOURCE_GROUP \
            --access Allow \
            --destination-address-prefixes "$RULE_DESTINATION_ADDRESS_PREFIX" \
            --destination-port-ranges "$RULE_DESTINATION_PORT_RANGE" \
            --protocol "*" \
            --source-address-prefixes "$RULE_SOURCE_ADDRESS_PREFIX" \
            --source-port-ranges "$RULE_SOURCE_PORT_RANGE" \
            --direction Outbound
    done

done

readarray -t SUBNETS < <(jq -c '.subnet[]' "./config.json")
for SUBNET in ${SUBNETS[@]}; do
    echo $SUBNET

    SUBNET_NAME=$(jq -r ".name" <<< $SUBNET)
    SUBNET_ADDRESS_PREFIX=$(jq -r ".address_prefix" <<< $SUBNET)
    SUBNET_NSG=$(jq -r ".network_security_group" <<< $SUBNET)

    az network vnet subnet create \
        --name $SUBNET_NAME\
        --resource-group $RESOURCE_GROUP \
        --vnet-name VNet \
        --address-prefixes $SUBNET_ADDRESS_PREFIX \
        --network-security-group "$SUBNET_NSG"
done

readarray -t PUBLIC_IPS < <(jq -c '.public_ip[]' "./config.json")

for PUBLIC_IP in "${PUBLIC_IPS[@]}"; do
    echo $PUBLIC_IP

    PUBLIC_IP_NAME=$(jq -r '.name' <<< $PUBLIC_IP)

    az network public-ip create \
        --resource-group $RESOURCE_GROUP \
        --name $PUBLIC_IP_NAME
done

readarray -t VIRTUAL_MACHINES < <(jq -c '.virtual_machine[]' "./config.json")

for VM in "${VIRTUAL_MACHINES[@]}"; do
    echo $VM

    VM_NAME=$(jq -r '.name' <<< $VM)
    VM_SUBNET=$(jq -r '.subnet' <<< $VM)
    VM_PRIVATE_IP_ADDRESS=$(jq -r '.private_ip_address' <<< $VM)
    VM_PUBLIC_IP_ADDRESS=$(jq -r '.public_ip_address' <<< $VM)

    az vm create \
        --resource-group $RESOURCE_GROUP \
        --vnet-name VNet \
        --name $VM_NAME \
        --subnet $VM_SUBNET \
        --nsg "" \
        --private-ip-address "$VM_PRIVATE_IP_ADDRESS" \
        --public-ip-address "$VM_PUBLIC_IP_ADDRESS" \
        --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
        --admin-username $USERNAME \
        --admin-password $PASSWORD \
        --authentication-type password

    readarray -t DEPLOY < <(jq -c '.deploy[]' <<< $VM)

    for SERVICE in "${DEPLOY[@]}"; do
        echo $SERVICE

        SERVICE_TYPE=$(jq -r '.type' <<< $SERVICE)
        SERVICE_PORT=$(jq -r '.port' <<< $SERVICE)

        case $SERVICE_TYPE in
            frontend)
                echo Setting up frontend

                NGINX_ADDR=$(jq -r '.nginx_address' <<< $SERVICE)
                NGINX_PORT=$(jq -r '.nginx_port' <<< $SERVICE)

                az vm run-command invoke \
                    --resource-group $RESOURCE_GROUP \
                    --name $VM_NAME \
                    --command-id RunShellScript \
                    --scripts "@./frontend.sh" \
                    --parameters "$NGINX_ADDR" "$NGINX_PORT"
            ;;

            backend)
                echo Setting up backend
                DATABASE_ADDR_M=$(jq -r '.database_ip_master' <<< $SERVICE)
                DATABASE_ADDR_S=$(jq -r '.database_ip_slave' <<< $SERVICE)                
                DATABASE_PORT_M=$(jq -r '.database_port_master' <<< $SERVICE)
                DATABASE_PORT_S=$(jq -r '.database_port_slave' <<< $SERVICE)
                BACKEND_MASTER_PORT=$(jq -r '.backend_master_port' <<< $SERVICE)
                BACKEND_SLAVE_PORT=$(jq -r '.backend_slave_port' <<< $SERVICE)

                az vm run-command invoke \
                    --resource-group $RESOURCE_GROUP \
                    --name $VM_NAME \
                    --command-id RunShellScript \
                    --scripts "@./backend.sh" \
                    --parameters "$DATABASE_ADDR_M" "$DATABASE_PORT_M" "$BACKEND_MASTER_PORT" "$DATABASE_ADDR_S" "$DATABASE_PORT_S" "$BACKEND_SLAVE_PORT"
            ;;
            database)
                echo Setting up database

                DATABASE_USER=$(jq -r '.user' <<< $SERVICE)
                DATABASE_PASSWORD=$(jq -r '.password' <<< $SERVICE)

                az vm run-command invoke \
                    --resource-group $RESOURCE_GROUP \
                    --name $VM_NAME \
                    --command-id RunShellScript \
                    --scripts "@./db_master.sh" \
                    --parameters "$SERVICE_PORT" "$DATABASE_USER" "$DATABASE_PASSWORD"
            ;;

            database-slave)
                echo Setting up database slave

                DATABASE_USER=$(jq -r '.user' <<< $SERVICE)
                DATABASE_PASSWORD=$(jq -r '.password' <<< $SERVICE)
                MASTER_DATABASE_ADDRESS=$(jq -r '.master_address' <<< $SERVICE)
                MASTER_DATABASE_PORT=$(jq -r '.master_port' <<< $SERVICE)

                az vm run-command invoke \
                    --resource-group $RESOURCE_GROUP \
                    --name $VM_NAME \
                    --command-id RunShellScript \
                    --scripts "@./db_slave.sh" \
                    --parameters "$SERVICE_PORT" "$DATABASE_USER" "$DATABASE_PASSWORD" "$MASTER_DATABASE_ADDRESS" "$MASTER_DATABASE_PORT"
            ;;

            nginx-balancer)
                echo Setting up nginx
                SERVER_NAME=$(jq -r '.server_name' <<< $SERVICE)
                SERVER_IP=$(az network public-ip show --resource-group "$RESOURCE_GROUP"  --name "$SERVER_NAME"  --query "ipAddress" --output tsv)
                BACKEND_WRITE_PORT=$(jq -r '.backend_port_master' <<< $SERVICE)
                BACKEND_READ_PORT=$(jq -r '.backend_port_slave' <<< $SERVICE)
                PORT=$(jq -r '.port' <<< $SERVICE)

                az vm run-command invoke \
                    --resource-group $RESOURCE_GROUP \
                    --name $VM_NAME \
                    --command-id RunShellScript \
                    --scripts "@./balancer.sh" \
                    --parameters "$PORT" "$SERVER_IP" "$BACKEND_WRITE_PORT" "$SERVER_IP" "$BACKEND_READ_PORT"
            ;;



        esac
    done
done
