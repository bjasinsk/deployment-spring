BALANCER_ADDR=$1
BALANCER_PORT=$2

sudo apt update --assume-no
sudo apt install nodejs -y
sudo apt install npm -y

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 18.13
nvm use 18.13

git clone https://github.com/spring-petclinic/spring-petclinic-angular
cd spring-petclinic-angular

sed -i "s/localhost/$BALANCER_ADDR/g" src/environments/environment.ts src/environments/environment.prod.ts
sed -i "s/9966/$BALANCER_PORT/g" src/environments/environment.ts src/environments/environment.prod.ts
cat src/environments/environment.ts

npm uninstall -g angular-cli @angular/cli
echo "no" |npm install -g @angular/cli@latest
npm install

ng build
ng serve &
