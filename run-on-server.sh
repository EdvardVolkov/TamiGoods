#!/bin/bash
set -e

echo "=== Начало деплоя TamiGoods ==="

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
    # GITHUB_TOKEN должен быть установлен через переменную окружения
    GITHUB_TOKEN="${GITHUB_TOKEN:-your_token_here}"
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/Estony.git" tamigoods
    cd tamigoods
fi

# Создание nginx конфигурации
echo "Настройка Nginx..."
cat > /etc/nginx/sites-available/tamigoods.eu <<'NGINX_EOF'
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_EOF

ln -sf /etc/nginx/sites-available/tamigoods.eu /etc/nginx/sites-enabled/
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
certbot --nginx -d tamigoods.eu -d www.tamigoods.eu --non-interactive --agree-tos --email admin@tamigoods.eu --redirect || echo "SSL уже настроен или требуется ручная настройка"

echo "=== Деплой завершен! ==="
echo "Приложение доступно по адресу: https://tamigoods.eu"
docker ps
systemctl status nginx --no-pager

