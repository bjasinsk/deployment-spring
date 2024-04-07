#!/bin/bash

sudo apt-get update
sudo apt-get install mysql-server -y
sudo apt-get install wget -y

INIT_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"

wget $INIT_DB_PATH
wget $POPULATE_DB_PATH

sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "s/localhost/0.0.0.0/" ./initDB.sql


sudo mysql <<EOF
CREATE DATABASE petclinic;
CREATE USER 'azureuser'@'localhost' IDENTIFIED BY 'Haslo1Haslo1@';
GRANT ALL PRIVILEGES ON petclinic.* TO 'azureuser'@'localhost';
FLUSH PRIVILEGES;
EOF

sed -i '7d' ./initDB.sql
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql


sudo service mysql restart

sudo mysql -v -e "UNLOCK TABLES;"

echo "Finished database setup"