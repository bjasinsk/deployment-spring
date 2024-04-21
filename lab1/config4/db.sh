#!/bin/bash

echo "Updating and installing MySQL server..."
sudo apt-get update -y
sudo apt-get install -y mysql-server
echo "MySQL server installed."

echo "Setting root password and applying security settings..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'kwiatki';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Downloading SQL scripts..."
wget -q https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql
wget -q https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql
echo "SQL scripts downloaded."

echo "Configuring the Master MySQL server..."
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "server-id = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "log_bin = /var/log/mysql/mysql-bin.log" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
echo "MySQL server restarted."

echo "Creating replication user..."
sudo mysql -e "CREATE USER 'replica'@'%' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replica'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Configuring the Slave MySQL server..."
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld_slave.cnf
echo "[mysqld]" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld_slave.cnf
echo "server-id = 2" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld_slave.cnf
echo "port = 3307" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld_slave.cnf
echo "replicate-same-server-id = 0" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld_slave.cnf

echo "Restarting MySQL with new configuration..."
sudo systemctl stop mysql
sudo mysqld --defaults-file=/etc/mysql/mysql.conf.d/mysqld_slave.cnf &

echo "Waiting for MySQL to restart..."
sleep 10  # Wait a bit for MySQL to be ready after restart

echo "Setting up Slave server to follow Master..."
MASTER_LOG_FILE=$(sudo mysql -e "SHOW MASTER STATUS;" | awk 'NR==2 {print $1}')
MASTER_LOG_POS=$(sudo mysql -e "SHOW MASTER STATUS;" | awk 'NR==2 {print $2}')

sudo mysql --port=3307 -e "CHANGE MASTER TO MASTER_HOST='localhost', MASTER_USER='replica', MASTER_PASSWORD='password', MASTER_LOG_FILE='${MASTER_LOG_FILE}', MASTER_LOG_POS=${MASTER_LOG_POS};"
sudo mysql --port=3307 -e "START SLAVE;"

echo "Checking replication status..."
sudo mysql --port=3307 -e "SHOW SLAVE STATUS\G"

echo "MySQL master-slave replication setup complete."
