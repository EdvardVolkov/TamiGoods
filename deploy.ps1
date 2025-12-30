# PowerShell скрипт для деплоя (альтернатива для Windows)

$ErrorActionPreference = "Stop"

# Параметры сервера
$SERVER_IP = "193.233.244.249"
$SERVER_USER = "root"
$SERVER_PASSWORD = "VTkc1YO2BZljqGd22Z"
$DOMAIN = "tamigoods.eu"
$GITHUB_TOKEN = "SHA256:tqW0NapX6gM4ZBc6i3dAFVEbecQXNiRnuxFSQYE68Y8"

Write-Host "=== Начало деплоя TamiGoods ===" -ForegroundColor Green

# Шаг 1: Получение информации о GitHub пользователе
Write-Host "Шаг 1: Получение информации о GitHub пользователе..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "token $GITHUB_TOKEN"
}
$githubUser = (Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers).login

if (-not $githubUser) {
    Write-Host "Ошибка: Не удалось получить информацию о GitHub пользователе" -ForegroundColor Red
    exit 1
}

Write-Host "GitHub пользователь: $githubUser" -ForegroundColor Green

# Шаг 2: Настройка git remote и push
Write-Host "Шаг 2: Настройка git и push в репозиторий..." -ForegroundColor Yellow

$repoName = Split-Path -Leaf (Get-Location)
$remoteUrl = "https://${GITHUB_TOKEN}@github.com/${githubUser}/${repoName}.git"

try {
    git remote remove origin 2>$null
} catch {}

git remote add origin $remoteUrl
git add .
git commit -m "Dockerize application for deployment" 2>$null
git push -u origin main 2>$null
if ($LASTEXITCODE -ne 0) {
    git push -u origin master 2>$null
}

# Шаг 3: Подключение к серверу через SSH
Write-Host "Шаг 3: Подключение к серверу..." -ForegroundColor Yellow

# Установка необходимых компонентов на сервере
$installScript = @"
#!/bin/bash
set -e

# Установка Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    rm get-docker.sh
fi

# Установка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Установка Nginx
if ! command -v nginx &> /dev/null; then
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
fi

# Установка Certbot
if ! command -v certbot &> /dev/null; then
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi
"@

# Используем plink (PuTTY) или ssh для подключения
Write-Host "Выполнение установки на сервере..." -ForegroundColor Yellow
$installScript | ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "bash"

# Клонирование репозитория
Write-Host "Шаг 4: Клонирование репозитория на сервере..." -ForegroundColor Yellow
$cloneScript = @"
cd /root
if [ -d "tamigoods" ]; then
    cd tamigoods
    git pull
else
    git clone https://${GITHUB_TOKEN}@github.com/${githubUser}/${repoName}.git tamigoods
    cd tamigoods
fi
"@

$cloneScript | ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "bash"

# Настройка Nginx
Write-Host "Шаг 5: Настройка Nginx..." -ForegroundColor Yellow
$nginxConfig = @"
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};

    location / {
        proxy_pass http://localhost:3000;
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

$nginxConfig | ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "bash -c 'cat > /etc/nginx/sites-available/${DOMAIN}'"
ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/ && rm -f /etc/nginx/sites-enabled/default && nginx -t && systemctl reload nginx"

# Запуск Docker контейнера
Write-Host "Шаг 6: Запуск Docker контейнера..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "cd /root/tamigoods && docker-compose down || true && docker-compose build --no-cache && docker-compose up -d"

# Настройка SSL
Write-Host "Шаг 7: Настройка SSL..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect" 2>$null

Write-Host "=== Деплой завершен! ===" -ForegroundColor Green
Write-Host "Приложение доступно по адресу: https://${DOMAIN}" -ForegroundColor Green

