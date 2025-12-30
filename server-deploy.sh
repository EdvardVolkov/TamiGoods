#!/bin/bash
set -e

DOMAIN="tamigoods.eu"
REPO_NAME="Estony"

# Проверка наличия GitHub токена
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Ошибка: GITHUB_TOKEN не установлен!"
    echo "Установите переменную окружения перед запуском скрипта:"
    echo "  export GITHUB_TOKEN=\"your_token_here\""
    echo "  ./server-deploy.sh"
    exit 1
fi

echo "=== Настройка сервера для TamiGoods ==="

# Получение GitHub пользователя через API
echo "Получение информации о GitHub пользователе..."
GITHUB_USER=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | grep -o '"login":"[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "Ошибка: Не удалось получить информацию о пользователе GitHub"
    echo "Используем значение по умолчанию: EdvardVolkov"
    GITHUB_USER="EdvardVolkov"
else
    echo "GitHub пользователь: $GITHUB_USER"
fi

# Установка Docker
if ! command -v docker &> /dev/null; then
    echo "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    rm get-docker.sh
else
    echo "Docker уже установлен"
fi

# Установка Docker Compose (проверяем оба варианта: docker-compose и docker compose)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Установка Docker Compose..."
    # Пытаемся установить Docker Compose v2 (плагин)
    if docker compose version &> /dev/null; then
        echo "Docker Compose v2 уже доступен"
    else
        # Устанавливаем Docker Compose v1
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
else
    echo "Docker Compose уже установлен"
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
if [ -d "${REPO_NAME}" ]; then
    cd ${REPO_NAME}
    git pull || echo "Не удалось обновить репозиторий, продолжаем..."
else
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" ${REPO_NAME}
    cd ${REPO_NAME}
fi

# Создание nginx конфигурации
echo "Настройка Nginx..."
cat > /etc/nginx/sites-available/${DOMAIN} <<'NGINX_EOF'
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

ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# Сборка и запуск Docker контейнера
echo "Сборка и запуск Docker контейнера..."
cd /root/${REPO_NAME}

# Используем docker compose (v2) если доступен, иначе docker-compose (v1)
if docker compose version &> /dev/null; then
    echo "Используется Docker Compose v2"
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "Используется Docker Compose v1"
    DOCKER_COMPOSE_CMD="docker-compose"
fi

$DOCKER_COMPOSE_CMD down || true
$DOCKER_COMPOSE_CMD build --no-cache
$DOCKER_COMPOSE_CMD up -d

# Ждем запуска контейнера
echo "Ожидание запуска контейнера..."
sleep 10

# Настройка SSL
echo "Настройка SSL сертификата..."
# Проверяем, не настроен ли уже SSL
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect
else
    echo "SSL сертификат уже существует, обновляем конфигурацию..."
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --redirect
fi

echo "=== Настройка завершена! ==="
echo "Приложение доступно по адресу: https://${DOMAIN}"
docker ps
systemctl status nginx --no-pager


