# Инструкция по ручному деплою TamiGoods

## Параметры сервера
- IP: 193.233.244.249
- Пользователь: root
- Пароль: VTkc1YO2BZljqGd22Z
- Домен: tamigoods.eu

## Шаг 1: Подключение к серверу
```bash
ssh root@193.233.244.249
```
Введите пароль: `VTkc1YO2BZljqGd22Z`

## Шаг 2: Обновление системы
```bash
apt-get update -y
apt-get upgrade -y
```

## Шаг 3: Установка необходимых пакетов
```bash
apt-get install -y docker.io docker-compose nginx certbot python3-certbot-nginx git
```

## Шаг 4: Запуск и включение Docker
```bash
systemctl start docker
systemctl enable docker
```

## Шаг 5: Создание директории для приложения
```bash
mkdir -p /opt/tamigoods
cd /opt/tamigoods
```

## Шаг 6: Клонирование репозитория
```bash
git clone https://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@github.com/EdvardVolkov/TamiGoods.git .
```

## Шаг 7: Сборка и запуск Docker контейнера
```bash
docker-compose down || true
docker-compose build --no-cache
docker-compose up -d
```

## Шаг 8: Проверка работы контейнера
```bash
docker ps
docker logs tamigoods-app
```
Убедитесь, что контейнер запущен и работает на порту 3000.

## Шаг 9: Создание конфигурации nginx
```bash
cat > /etc/nginx/sites-available/tamigoods << 'EOF'
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

    location / {
        proxy_pass http://127.0.0.1:3000;
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
EOF
```

## Шаг 10: Активация конфигурации nginx
```bash
ln -sf /etc/nginx/sites-available/tamigoods /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
```

## Шаг 11: Проверка конфигурации nginx
```bash
nginx -t
```

## Шаг 12: Перезагрузка nginx
```bash
systemctl restart nginx
systemctl enable nginx
```

## Шаг 13: Получение SSL сертификата
```bash
certbot --nginx -d tamigoods.eu -d www.tamigoods.eu --non-interactive --agree-tos --email admin@tamigoods.eu --redirect
```

## Шаг 14: Настройка автообновления SSL сертификата
```bash
systemctl enable certbot.timer
systemctl start certbot.timer
```

## Шаг 15: Проверка работы сайта
Откройте в браузере:
- http://tamigoods.eu
- https://tamigoods.eu

## Полезные команды для управления

### Просмотр логов контейнера
```bash
docker logs tamigoods-app
docker logs -f tamigoods-app  # с отслеживанием в реальном времени
```

### Перезапуск контейнера
```bash
cd /opt/tamigoods
docker-compose restart
```

### Обновление приложения
```bash
cd /opt/tamigoods
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Проверка статуса сервисов
```bash
systemctl status nginx
systemctl status docker
docker ps
```

### Проверка портов
```bash
netstat -tlnp | grep 3000
netstat -tlnp | grep 80
netstat -tlnp | grep 443
```

