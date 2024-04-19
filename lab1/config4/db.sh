#!/bin/bash

cd ~

sudo apt-get update
sudo apt-get install -y mysql-server
sudo apt-get install -y wget

INIT_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DB_PATH="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"
wget $INIT_DB_PATH
wget $POPULATE_DB_PATH

configure_mysql() {
    PORT=$1
    DATABASE=$2
    DATADIR=$3

    sudo cp /etc/mysql/my.cnf /etc/mysql/my$PORT.cnf
    sudo bash -c "echo '[mysqld]' >> /etc/mysql/my$PORT.cnf"
    sudo bash -c "echo 'port = $PORT' >> /etc/mysql/my$PORT.cnf"
    sudo bash -c "echo 'socket = /var/run/mysqld/mysqld$PORT.sock' >> /etc/mysql/my$PORT.cnf"
    sudo bash -c "echo 'datadir = $DATADIR' >> /etc/mysql/my$PORT.cnf"
    sudo mkdir -p $DATADIR

    # JEST OK -----------------------

    # sudo mysqld --initialize --user=mysql --basedir=/usr --datadir=$DATADIR
    
    # poszukać komend mysqlowych do stawiania servera
    sudo systemctl start mysql@$PORT

    sudo mysql --port=$PORT -e "CREATE DATABASE $DATABASE;"
    sudo mysql --port=$PORT -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'petclinic';"
    sudo mysql --port=$PORT -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO 'pc'@'%';"
    sudo mysql --port=$PORT -e "FLUSH PRIVILEGES;"
    
    sed -i '7d' initDB.sql
    cat populateDB.sql >> initDB.sql
    sudo mysql --port=$PORT $DATABASE < initDB.sql

    sudo systemctl restart mysql@$PORT

    sudo mysql --port=$PORT -e "UNLOCK TABLES;"

    echo "Finished setting up the database $DATABASE on port $PORT"
}

configure_mysql 3306 petclinic_post /var/lib/mysql_3306
configure_mysql 3307 petclinic_get /var/lib/mysql_3307
