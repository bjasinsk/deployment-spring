#!/bin/bash

RESOURCE_GROUP="lab1Config4"

echo "Usuwanie grupy zasobów $RESOURCE_GROUP oraz wszystkich maszyn w tej grupie"

az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "Usuwanie grupy $RESOURCE_GROUP zakończone"
