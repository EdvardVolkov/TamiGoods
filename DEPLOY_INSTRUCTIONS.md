# Инструкции по деплою TamiGoods

## Шаг 1: Создание репозитория на GitHub

Репозиторий нужно создать вручную на GitHub или использовать существующий.

## Шаг 2: Push кода в GitHub

```bash
git remote add origin https://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@github.com/EdvardVolkov/Estony.git
git branch -M main
git push -u origin main
```

## Шаг 3: Подключение к серверу и выполнение настройки

Подключитесь к серверу:
```bash
ssh root@193.233.244.249
# Пароль: VTkc1YO2BZljqGd22Z
```

Затем выполните команды на сервере (или загрузите server-setup.sh и запустите его):

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker
rm get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Установка Nginx
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# Установка Certbot
apt-get install -y certbot python3-certbot-nginx

# Клонирование репозитория
cd /root
git clone https://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@github.com/EdvardVolkov/Estony.git tamigoods
cd tamigoods

# Настройка Nginx
cat > /etc/nginx/sites-available/tamigoods.eu <<EOF
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

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

ln -sf /etc/nginx/sites-available/tamigoods.eu /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# Сборка и запуск Docker контейнера
docker-compose build --no-cache
docker-compose up -d

# Настройка SSL
certbot --nginx -d tamigoods.eu -d www.tamigoods.eu --non-interactive --agree-tos --email admin@tamigoods.eu --redirect
```

## Альтернатива: Использование server-setup.sh

Если вы загрузили server-setup.sh на сервер:
```bash
chmod +x server-setup.sh
./server-setup.sh
```


