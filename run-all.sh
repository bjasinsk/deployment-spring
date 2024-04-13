#!/bin/bash

source config.sh

front_username=$AZURE_VM_USERNAME
front_password=$AZURE_VM_PASSWORD

backend_username=$AZURE_VM_USERNAME
backend_password=$AZURE_VM_PASSWORD

# database_username=$AZURE_VM_USERNAME
# database_password=$AZURE_VM_PASSWORD

./run-front.sh "$front_password" "$front_username" "$angular_IP" "$angular_PORT" "$spring_IP" "$spring_PORT"
# ./run-back.sh "$backend_password" "$backend_username" "$spring_IP" "$spring_PORT" "$db_IP" "$db_PORT"
# ./db.sh "$database_password" "$database_username" "$db_IP" "$db_PORT"
