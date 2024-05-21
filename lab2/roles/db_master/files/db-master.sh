#!/bin/bash

DATABASE_PORT=$1
DATABASE_USER=$2
DATABASE_PASSWORD=$3

INIT_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"

cd ~/

# Instalation
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

sudo apt-get install mysql-server -y
sudo apt-get install wget -y

# Download config files


echo "CREATE USER '$DATABASE_USER'@'%' IDENTIFIED BY '$DATABASE_PASSWORD';" >> user.sql
echo "GRANT ALL PRIVILEGES ON *.* TO '$DATABASE_USER'@'%' WITH GRANT OPTION;" >> user.sql
echo "CREATE USER 'replicate'@'%' IDENTIFIED BY 'password';" >> user.sql
echo "GRANT REPLICATION SLAVE ON *.* TO 'replicate'@'%';" >> user.sql



wget $INIT_DATABASE
wget $POPULATE_DATABASE

# sudo chmod 646 $MY_SQL_CONFIG

# Update configuration
# sudo echo "[mysqld]" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo echo "port = $DATABASE_PORT" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo echo "server-id = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo echo "log_bin = /var/log/mysql/mysql-bi.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
# sudo echo "bind-address = 0.0.0.0" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "s/.*server-id.*/server-id = 1/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i "s/.*port.*/port = $DATABASE_PORT/" /etc/mysql/mysql.conf.d/mysqld.cnf

cat "/etc/mysql/mysql.conf.d/mysqld.cnf"

sudo sed -i "1s/^/USE petclinic;\n/" ./populateDB.sql

# Run sql
sudo sed -i "1s/^/USE petclinic;\n/" ./populateDB.sql
sudo mysql < ./user.sql

sudo mysql -e "ALTER USER '$DATABASE_USER'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DATABASE_PASSWORD';"
sudo mysql -e "ALTER USER 'replicate'@'localhost' IDENTIFIED WITH mysql_native_password BY 'slave_pass';"

sed -i '7d' ./initDB.sql
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql

sudo mysql -v -e "FLUSH PRIVILEGES;"
# Restart service
sudo service mysql restart

# Move Data From Master To Slave
# mysqldump -u root -p –all-databases –master-data > data.sql
# scp data.sql root@$DB_SLAVE_IP
# mysql> UNLOCK TABLES;
