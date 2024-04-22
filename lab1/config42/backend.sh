#!/bin/bash

DB_ADDRESS_MASTER=$1
DB_PORT_MASTER=$2
DB_ADDRESS_SLAVE=$3
DB_PORT_SLAVE=$4

sudo apt-get update -y
sudo apt install -y openjdk-17-jdk

mkdir -p /slave
cd /slave
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS_SLAVE:$DB_PORT_SLAVE/" src/main/resources/application-mysql.properties
sudo ./mvnw spring-boot:run &

mkdir -p /master
cd /master
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS_MASTER:$DB_PORT_MASTER/" src/main/resources/application-mysql.properties
sudo ./mvnw spring-boot:run &
#!/bin/bash

DB_ADDRESS=$1
DB_PORT=$2

sudo apt-get update -y
sudo apt install -y openjdk-17-jdk

mkdir -p /slave
cd /slave
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest

sed -i "s/hsqldb/mysql/g" ./src/main/resources/application.properties
sed -i "s/localhost:3306/$DB_ADDRESS:$DB_PORT/" src/main/resources/application-mysql.properties

sudo ./mvnw spring-boot:run &