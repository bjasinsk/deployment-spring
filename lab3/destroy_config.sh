#!/bin/bash

RESOURCE_GROUP="configLab3Z1"
az group delete --name $RESOURCE_GROUP --yes --no-wait
az group delete --name NetworkWatcherRG --yes --no-wait
