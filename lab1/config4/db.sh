#!/bin/bash

sudo apt-get update
sudo apt-get install mysql-server -y
sudo apt-get install wget -y

INIT_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"
wget $INIT_DB_PATH
wget $POPULATE_DB_PATH

sudo mysql -v -e "CREATE DATABASE petclinic_master;"

sudo mysql -v -e "CREATE USER 'pc_master'@'%' IDENTIFIED BY 'pc_master';"
sudo mysql -v -e "GRANT ALL PRIVILEGES ON petclinic_master.* TO 'pc_master'@'%';"
sudo mysql -v -e "FLUSH PRIVILEGES;"

sed -i '7d' ./initDB.sql
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql
sudo service mysql restart
sudo sed -i 's/port\t\t\t= 3306/port\t\t\t= 3307/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

sudo mysql -v -e "CREATE DATABASE petclinic_slave;"
sudo mysql -v -e "CREATE USER 'pc_slave'@'%' IDENTIFIED BY 'pc_slave';"
sudo mysql -v -e "GRANT ALL PRIVILEGES ON petclinic_slave.* TO 'pc_slave'@'%';"
sudo mysql -v -e "FLUSH PRIVILEGES;"

echo "Finished database setup"



