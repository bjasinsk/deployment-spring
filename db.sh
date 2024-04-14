#!/bin/bash

sudo apt-get update
sudo apt-get install mysql-server -y
sudo apt-get install wget -y

INIT_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"
wget $INIT_DB_PATH
wget $POPULATE_DB_PATH

sudo mysql -v -e "CREATE DATABASE petclinic;"
sudo mysql -v -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'petclinic';"
sudo mysql -v -e "GRANT ALL PRIVILEGES ON petclinic.* TO 'pc'@'%';"
sudo mysql -v -e "FLUSH PRIVILEGES;"


sed -i '7d' ./initDB.sql
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql


sudo service mysql restart

sudo mysql -v -e "UNLOCK TABLES;"

echo "Finished database setup"