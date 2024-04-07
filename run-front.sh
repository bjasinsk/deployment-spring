sudo apt-get install -y sshpass
sshpass -p "$1" ssh -o StrictHostKeyChecking=no "$2@$3" << 'EOF'

sudo apt update
sudo apt install nodejs
sudo apt install npm

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 18.13
nvm use 18.13

git clone https://github.com/spring-petclinic/spring-petclinic-angular
cd spring-petclinic-angular

sed -i "s/localhost/$5/g" src/environments/environment.ts src/environments/environment.prod.ts
sed -i "s/9966/$6/g" src/environments/environment.ts src/environments/environment.prod.ts

npm uninstall -g angular-cli @angular/cli
npm install -g @angular/cli@latest

ng build
screen -dmS ng_serve_session bash -c 'ng serve --port $4'

EOF

sshpass -p "$1" ssh -t -f -L "$4":localhost:"$4" "$2@$3"