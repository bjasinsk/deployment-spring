#!/bin/bash

RESOURCE_GROUP="configLab3Z1"
CLUSTER_NAME="clusterLab3"

az group create --name $RESOURCE_GROUP --location polandcentral

az aks create --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-managed-identity \
    --node-count 2 \
    --generate-ssh-keys

az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME

kubectl get nodes

cd spring-petclinic-cloud/

kubectl apply -f k8s/init-namespace
kubectl apply -f k8s/init-services

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --version 9.4.6 --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic  --version 9.4.6 --set auth.database=service_instance_db

export REPOSITORY_PREFIX=springcommunity
./scripts/deployToKubernetes.sh

kubectl get svc -n spring-petclinic
kubectl get pods --all-namespaces
kubectl get svc -n spring-petclinic api-gateway
