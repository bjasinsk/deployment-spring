#!/bin/bash

set -x
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | sudo -E bash -

export NVM_DIR=$HOME/.nvm
source $NVM_DIR/nvm.sh
sudo chmod 777 $HOME/.nvm
nvm install 18.19
nvm use 18.19
npm install -g @angular/cli
npm install --save-dev @angular/cli@latest
npm install angular-http-server
cd spring-petclinic-angular/
npm install
echo n | ng serve --host 0.0.0.0 --port "$1" 