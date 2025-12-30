#!/bin/bash

SERVER_IP="193.233.244.249"
SERVER_USER="root"
DOMAIN="tamigoods.eu"
GITHUB_REPO="https://github.com/EdvardVolkov/TamiGoods.git"

echo "Начинаю деплой на сервер..."

ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'ENDSSH'
# Обновление системы
apt-get update -y
apt-get upgrade -y

# Установка необходимых пакетов
apt-get install -y docker.io docker-compose nginx certbot python3-certbot-nginx git sshpass

# Запуск Docker
systemctl start docker
systemctl enable docker

# Создание директории для приложения
mkdir -p /opt/tamigoods
cd /opt/tamigoods

# Клонирование или обновление репозитория
if [ -d ".git" ]; then
    git pull
else
    git clone https://github.com/EdvardVolkov/TamiGoods.git .
fi

# Остановка и удаление старых контейнеров
docker-compose down || true
docker-compose build --no-cache

# Запуск контейнера
docker-compose up -d

# Ожидание запуска контейнера
sleep 10

ENDSSH

echo "Настройка nginx и SSL..."

ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << ENDSSH
# Создание конфигурации nginx
cat > /etc/nginx/sites-available/tamigoods << 'NGINXCONF'
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

    location / {
        proxy_pass http://127.0.0.1:3000;
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
NGINXCONF

# Активация конфигурации
ln -sf /etc/nginx/sites-available/tamigoods /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации nginx
nginx -t

# Перезагрузка nginx
systemctl restart nginx
systemctl enable nginx

# Получение SSL сертификата
certbot --nginx -d tamigoods.eu -d www.tamigoods.eu --non-interactive --agree-tos --email admin@tamigoods.eu --redirect

# Настройка автообновления сертификата
systemctl enable certbot.timer
systemctl start certbot.timer

ENDSSH

echo "Деплой завершен!"

