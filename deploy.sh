#!/bin/bash

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Параметры сервера
SERVER_IP="193.233.244.249"
SERVER_USER="root"
SERVER_PASSWORD="VTkc1YO2BZljqGd22Z"
DOMAIN="tamigoods.eu"
GITHUB_TOKEN="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"

echo -e "${GREEN}=== Начало деплоя TamiGoods ===${NC}"

# Получаем имя репозитория из текущей директории
REPO_NAME=$(basename $(pwd))

# Шаг 1: Получение информации о GitHub пользователе
echo -e "${YELLOW}Шаг 1: Получение информации о GitHub пользователе...${NC}"
GITHUB_USER=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | grep -o '"login":"[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}Ошибка: Не удалось получить информацию о GitHub пользователе${NC}"
    exit 1
fi

echo -e "${GREEN}GitHub пользователь: ${GITHUB_USER}${NC}"

# Шаг 2: Настройка git remote и push
echo -e "${YELLOW}Шаг 2: Настройка git и push в репозиторий...${NC}"

# Проверяем, есть ли уже remote
if git remote get-url origin > /dev/null 2>&1; then
    echo "Remote origin уже настроен"
    # Обновляем URL remote на случай, если он изменился
    git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" || true
else
    git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" || true
fi

# Добавляем все файлы и коммитим
git add .
git commit -m "Dockerize application for deployment" || echo "Нет изменений для коммита"

# Пушим в репозиторий
echo -e "${YELLOW}Пушим изменения в GitHub...${NC}"
git push -u origin main || git push -u origin master || echo "Push выполнен или не требуется"

# Шаг 3: Подключение к серверу и установка необходимых компонентов
echo -e "${YELLOW}Шаг 3: Подключение к серверу и установка компонентов...${NC}"

# Установка sshpass для автоматического подключения
if ! command -v sshpass &> /dev/null; then
    echo "Установка sshpass..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y sshpass
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install hudochenkov/sshpass/sshpass
    else
        echo -e "${YELLOW}Пожалуйста, установите sshpass вручную${NC}"
    fi
fi

# Функция для выполнения команд на сервере
ssh_exec() {
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${SERVER_USER}@${SERVER_IP}" "$1"
}

# Функция для копирования файлов на сервер
scp_copy() {
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$1" "${SERVER_USER}@${SERVER_IP}:$2"
}

# Установка Docker и Docker Compose на сервере
echo -e "${YELLOW}Установка Docker и Docker Compose...${NC}"
ssh_exec "bash -c '
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl start docker
        systemctl enable docker
        rm get-docker.sh
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
'"

# Установка Nginx
echo -e "${YELLOW}Установка Nginx...${NC}"
ssh_exec "bash -c '
    if ! command -v nginx &> /dev/null; then
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
        systemctl enable nginx
    fi
'"

# Установка Certbot для SSL
echo -e "${YELLOW}Установка Certbot...${NC}"
ssh_exec "bash -c '
    if ! command -v certbot &> /dev/null; then
        apt-get update
        apt-get install -y certbot python3-certbot-nginx
    fi
'"

# Шаг 4: Клонирование репозитория на сервере
echo -e "${YELLOW}Шаг 4: Клонирование репозитория на сервере...${NC}"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
ssh_exec "bash -c '
    cd /root
    if [ -d \"tamigoods\" ]; then
        cd tamigoods
        git pull
    else
        git clone ${REPO_URL} tamigoods
        cd tamigoods
    fi
'"

# Шаг 5: Создание nginx конфигурации
echo -e "${YELLOW}Шаг 5: Создание nginx конфигурации...${NC}"
NGINX_CONFIG=$(cat <<EOF
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
)

ssh_exec "bash -c 'echo \"${NGINX_CONFIG}\" > /etc/nginx/sites-available/${DOMAIN}'"
ssh_exec "ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/"
ssh_exec "rm -f /etc/nginx/sites-enabled/default"
ssh_exec "nginx -t && systemctl reload nginx"

# Шаг 6: Сборка и запуск Docker контейнера
echo -e "${YELLOW}Шаг 6: Сборка и запуск Docker контейнера...${NC}"
ssh_exec "bash -c '
    cd /root/tamigoods
    docker-compose down || true
    docker-compose build --no-cache
    docker-compose up -d
'"

# Шаг 7: Настройка SSL
echo -e "${YELLOW}Шаг 7: Настройка SSL сертификата...${NC}"
ssh_exec "certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect" || echo -e "${YELLOW}SSL сертификат уже настроен или требуется ручная настройка${NC}"

# Шаг 8: Проверка статуса
echo -e "${YELLOW}Шаг 8: Проверка статуса...${NC}"
ssh_exec "docker ps"
ssh_exec "systemctl status nginx --no-pager"

echo -e "${GREEN}=== Деплой завершен! ===${NC}"
echo -e "${GREEN}Приложение доступно по адресу: https://${DOMAIN}${NC}"

