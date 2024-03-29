
#sudo apt install sshpass
#mkdir "front"
#sshpass -p "$1" ssh "$2"@"$3"


sudo apt-get install -y sshpass
sshpass -p "$1" ssh -o StrictHostKeyChecking=no "$2@$3" << 'EOF'

sudo apt update
sudo apt install nodejs
sudo apt install npm

mkdir -p ~/frontend
cd ~/frontend
git clone https://github.com/spring-petclinic/spring-petclinic-angular
cd ~/frontend/spring-petclinic-angular

npm uninstall -g angular-cli @angular/cli
npm install -g npm

nvm install 18.17.0
nvm use 18.17.0
node -v
npm -v
npm install -g npm@latest

npm uninstall -g angular-cli @angular/cli
npm install -g @angular/cli@latest
npm install --save-dev @angular/cli@latest

VERSION=\$(npm -v)
if [ "$(echo "${npm_version}" | cut -d. -f1)" -gt 5 ]; then
    rm -f package-lock.json
    echo "Deleted package-lock.json file due to npm version > 5.0"
else
    echo "No action required. npm version <= 5.0"
fi

npm install --legacy-peer-deps
npm build
ng serve

EOF

#słownie jak my to mamy zrobić--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#OK stówrz katalog frontend jeżeli go nie ma
#sklonuj repo do niego
#w katalogu frontend odpal te komendy:
#sudo apt install npm
#npm uninstall -g angular-cli @angular/cli
#npm cache clean
#npm install -g @angular/cli@latest
#npm install --save-dev @angular/cli@latest
#if npm version > 5.0 delete package-lock.json file  ( bug in npm 5.0 - this file prevent correct packages install)
#npm install
#npm build

#zaintaliuj nodejs, i wszystko abym mógł uruchomić komendę "ng serve"
#następnie uruchom projekt
#ng serve


#tak poszło --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#npm uninstall -g angular-cli @angular/cli
#npm install -g npm
#npm cache clean (NIE POSZŁO)
#npm uninstall -g angular-cli @angular/cli (NIE POSZŁO)
#npm install -g npm@latest (NIE POSZŁO)
#sudo apt update
#sudo apt install nodejs
#npm install -g npm@latest(NIE POSZŁO)
#nvm install 18.17.0
#nvm use 18.17.0
#node -v
#npm -v
#npm install -g npm@latest
#npm fun (NIE WIADOMO CO ROBI)
#npm cache clean (NIE POSZŁO)
#npm uninstall -g angular-cli @angular/cli
#npm cache clean(NIE POSZŁO)
#npm install -g @angular/cli@latest
#npm install --save-dev @angular/cli@latest
#if npm version > 5.0 delete package-lock.json file  ( bug in npm 5.0 - this file prevent correct packages install)
#npm install (NIE POSZŁO)
 #sudo apt npm install (NIE POSZŁO)
 #npm install --legacy-peer-deps
 #ng build
 #ng build
 #ng serve