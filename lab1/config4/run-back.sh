#!/bin/bash

DB_ADDRESS=$1
DB_PORT_MASTER=$2
DB_PORT_SLAVE=$2

sudo apt-get update -y
sudo apt install -y openjdk-17-jdk

mkdir post_backend
cd post_backend
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS:$DB_PORT_MASTER/" src/main/resources/application-mysql.properties
sed -i "s/petclinic?/petclinic_master?/" src/main/resources/application-mysql.properties
sed -i "s/username=pc/usename=pc_master/" src/main/resources/application-mysql.properties
sed -i "s/password=petclinic/password=pc_master/" src/main/resources/application-mysql.properties
sudo ./mvnw spring-boot:run &

cd ..
cd ..

mkdir get_backend
cd get_backend
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS:$DB_PORT_SLAVE/" src/main/resources/application-mysql.properties
sed -i "s/petclinic?/petclinic_slave?/" src/main/resources/application-mysql.properties
sed -i "s/username=pc/usename=pc_slave/" src/main/resources/application-mysql.properties
sed -i "s/password=petclinic/password=pc_slave/" src/main/resources/application-mysql.properties
sudo ./mvnw spring-boot:run &