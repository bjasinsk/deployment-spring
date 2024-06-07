#!/bin/bash

RESOURCE_GROUP="lab3config"
az group delete --name $RESOURCE_GROUP --yes --no-wait
az group delete --name NetworkWatcherRG --yes --no-wait
