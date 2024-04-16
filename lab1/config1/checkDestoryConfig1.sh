#!/bin/bash

RESOURCE_GROUP="lab1Config1"

GROUP_EXISTS=$(az group exists --name $RESOURCE_GROUP)
echo "Status istnienia grupy zasobów '$RESOURCE_GROUP': $GROUP_EXISTS"

if [ "$GROUP_EXISTS" = "true" ]; then
    echo "Grupa zasobów '$RESOURCE_GROUP' nadal istnieje"
else
    echo "Grupa zasobów '$RESOURCE_GROUP' została pomyślnie usunięta"
fi
