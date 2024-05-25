#!/bin/bash

DB_ADDRESS=$1
DB_PORT=$2
BACKEND_PORT=$3
FOLDER=$4

sudo apt-get update -y
sudo apt install -y openjdk-17-jdk

cd /
mkdir $FOLDER
cd $FOLDER
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS:$DB_PORT/" src/main/resources/application-mysql.properties
sed -i "s/9966/$BACKEND_PORT/g" src/main/resources/application.properties
