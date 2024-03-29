
# mysql installation
sudo apt update
sudo apt install mysql-server

# Create a new database and user
sudo mysql <<EOF
CREATE DATABASE petclinic;
CREATE USER 'azureUser3'@'localhost' IDENTIFIED BY 'haslo3haslo3@';
GRANT ALL PRIVILEGES ON petclinic.* TO 'azureUser3'@'localhost';
FLUSH PRIVILEGES;
EOF