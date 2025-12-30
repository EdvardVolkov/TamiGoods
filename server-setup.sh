#!/bin/bash

set -e

# Параметры
DOMAIN="tamigoods.eu"
GITHUB_TOKEN="SHA256:tqW0NapX6gM4ZBc6i3dAFVEbecQXNiRnuxFSQYE68Y8"
GITHUB_USER=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | grep -o '"login":"[^"]*' | cut -d'"' -f4)

# Определение имени репозитория из текущей директории или из git remote
if [ -d ".git" ]; then
    REPO_NAME=$(basename $(git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//') 2>/dev/null || echo "Estony")
else
    REPO_NAME="Estony"
fi

echo "=== Настройка сервера для TamiGoods ==="

# Установка Docker
if ! command -v docker &> /dev/null; then
    echo "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    rm get-docker.sh
fi

# Установка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Установка Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Установка Nginx
if ! command -v nginx &> /dev/null; then
    echo "Установка Nginx..."
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
fi

# Установка Certbot
if ! command -v certbot &> /dev/null; then
    echo "Установка Certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Клонирование репозитория
echo "Клонирование репозитория..."
cd /root
if [ -d "tamigoods" ]; then
    cd tamigoods
    git pull
else
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" tamigoods
    cd tamigoods
fi

# Создание nginx конфигурации
echo "Настройка Nginx..."
cat > /etc/nginx/sites-available/${DOMAIN} <<EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# Сборка и запуск Docker контейнера
echo "Сборка и запуск Docker контейнера..."
cd /root/tamigoods
docker-compose down || true
docker-compose build --no-cache
docker-compose up -d

# Настройка SSL
echo "Настройка SSL сертификата..."
certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect || echo "SSL уже настроен или требуется ручная настройка"

echo "=== Настройка завершена! ==="
echo "Приложение доступно по адресу: https://${DOMAIN}"
docker ps
systemctl status nginx --no-pager

