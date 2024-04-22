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

sudo sed 's/\(^bind-address\s*=\).*$/\1 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf -i
sudo sed 's/\(^mysqlx-bind-address\s*=\).*$/\1 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf -i
sed -i '7d' ./initDB.sql
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql
sudo mysql -v -e "UNLOCK TABLES;"

sudo service mysql restart

echo "Finished database setup"