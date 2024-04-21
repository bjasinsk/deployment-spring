#!/bin/bash

DB_ADDRESS=$1
DB_PORT=$2

sudo apt-get update -y
sudo apt install -y openjdk-17-jdk

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS:$DB_PORT/" src/main/resources/application-mysql.properties
cat src/main/resources/application-mysql.properties

sudo ./mvnw spring-boot:run &