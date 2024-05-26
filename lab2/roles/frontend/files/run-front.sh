# BACK_ADDRESS=$1
# BACK_PORT=$2
# FRONT_PORT=$3

# sudo apt update --assume-no
# sudo apt install nodejs -y
# sudo apt install npm -y

# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm install 18.13
# nvm use 18.13

# cd /
# git clone https://github.com/spring-petclinic/spring-petclinic-angular
# cd spring-petclinic-angular

# sed -i "s/localhost/$BACK_ADDRESS/g" src/environments/environment.ts src/environments/environment.prod.ts
# sed -i "s/9966/$BACK_PORT/g" src/environments/environment.ts src/environments/environment.prod.ts

# cat src/environments/environment.ts

# echo N|npm install -g @angular/cli@latest
# echo N| npm install
# echo N | ng analytics off

# npm install angular-http-server
# echo N | npm run build


#!/bin/bash

backendIp=$1
backendPort=$2
frontendPort=$3


sudo su
cd ~
sudo apt update -y
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
sudo apt install nginx -y
sudo apt install nodejs -y
sudo apt install npm -y --force

cd $HOME

sudo npm uninstall -g angular-cli @angular/cli
npm cache clean

git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular/

sed -i "s/localhost/$backendIp/g" src/environments/environment.ts src/environments/environment.prod.ts
sed -i "s/9966/$backendPort/g" src/environments/environment.ts src/environments/environment.prod.ts

sudo npm install -g @angular/cli@11.2.11
npm install
npm install --save-dev @angular-devkit/build-angular
npm run build --prod --base-href=/petclinic/ --deploy-url=/petclinic/
