sshpass -p $1 scp /default $2@$3:/etc/nginx/nginx.conf
sshpass -p "$1" ssh -o StrictHostKeyChecking=no "$2@$3" << 'EOF'

sudo apt update --assume-no
echo "y" |sudo apt install nginx

sudo systemctl start nginx

EOF
