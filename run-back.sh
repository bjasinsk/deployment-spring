#!/bin/bash

sudo apt-get update -y
sudo apt install -y openjdk-11-jdk
cd ~
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties

sudo ./mvnw spring-boot:run &