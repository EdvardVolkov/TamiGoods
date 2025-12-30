$SERVER_IP = "193.233.244.249"
$SERVER_USER = "root"
$SERVER_PASSWORD = "VTkc1YO2BZljqGd22Z"
$DOMAIN = "tamigoods.eu"

Write-Host "Начинаю деплой на сервер..."

# Установка sshpass для Windows (если нужно) или использование plink
$commands = @"
apt-get update -y
apt-get upgrade -y
apt-get install -y docker.io docker-compose nginx certbot python3-certbot-nginx git sshpass
systemctl start docker
systemctl enable docker
mkdir -p /opt/tamigoods
cd /opt/tamigoods
if [ -d ".git" ]; then
    git pull
else
    git clone https://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@github.com/EdvardVolkov/TamiGoods.git .
fi
docker-compose down || true
docker-compose build --no-cache
docker-compose up -d
sleep 10
"@

$commands | sshpass -p "$SERVER_PASSWORD ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash

Write-Host "Настройка nginx..."

$nginxConfig = @"
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_cache_bypass `$http_upgrade;
    }
}
"@

$nginxCommands = @"
cat > /etc/nginx/sites-available/tamigoods << 'NGINXCONF'
$nginxConfig
NGINXCONF
ln -sf /etc/nginx/sites-available/tamigoods /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx
certbot --nginx -d tamigoods.eu -d www.tamigoods.eu --non-interactive --agree-tos --email admin@tamigoods.eu --redirect
systemctl enable certbot.timer
systemctl start certbot.timer
"@

$nginxCommands | sshpass -p "$SERVER_PASSWORD ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash

Write-Host "Деплой завершен!"

