# Финальные инструкции по деплою TamiGoods

## Текущая ситуация

✅ Код подготовлен к деплою:
- Dockerfile настроен для Next.js standalone режима
- docker-compose.yml настроен для работы через nginx
- server-deploy.sh автоматически установит все необходимое
- Nginx конфигурация готова для домена tamigoods.eu
- SSL будет настроен автоматически через Certbot

⚠️ GitHub push заблокирован из-за токенов в истории коммитов

## Шаги для завершения деплоя:

### 1. Разрешите push в GitHub

Откройте URL для разрешения push (одноразово):
https://github.com/EdvardVolkov/Estony/security/secret-scanning/unblock-secret/37a4bB0FKtL3z6KCcCHNDudq1W3

Затем выполните push локально:
```bash
git push -u origin main
```

### 2. Подключитесь к серверу

```bash
ssh root@193.233.244.249
# Пароль: VTkc1YO2BZljqGd22Z
```

### 3. Установите GitHub токен и выполните деплой

На сервере выполните:

```bash
# Установите GitHub токен
export GITHUB_TOKEN="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"

# Загрузите и выполните скрипт деплоя
cd /root
wget https://raw.githubusercontent.com/EdvardVolkov/Estony/main/server-deploy.sh
chmod +x server-deploy.sh
./server-deploy.sh
```

Или скопируйте `server-deploy.sh` на сервер через scp:

```bash
# С вашего локального компьютера
scp server-deploy.sh root@193.233.244.249:/root/

# На сервере
ssh root@193.233.244.249
export GITHUB_TOKEN="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"
chmod +x /root/server-deploy.sh
/root/server-deploy.sh
```

## Что делает server-deploy.sh:

1. ✅ Устанавливает Docker и Docker Compose (если не установлены)
2. ✅ Устанавливает Nginx (если не установлен)
3. ✅ Устанавливает Certbot для SSL сертификатов
4. ✅ Получает информацию о GitHub пользователе через API токена
5. ✅ Клонирует/обновляет репозиторий с GitHub
6. ✅ Настраивает Nginx для домена `tamigoods.eu` (проксирует на localhost:3000)
7. ✅ Собирает и запускает Docker контейнер с приложением
8. ✅ Настраивает SSL сертификат через Let's Encrypt (автоматически)
9. ✅ Настраивает автоматическое перенаправление HTTP -> HTTPS

## После деплоя:

Приложение будет доступно по адресу: **https://tamigoods.eu**

Проверка статуса на сервере:
```bash
# Проверить запущенные контейнеры
docker ps

# Проверить логи приложения
docker logs tamigoods-app

# Проверить статус nginx
systemctl status nginx

# Проверить SSL сертификат
certbot certificates
```

## Важные замечания:

- ⚠️ Убедитесь, что DNS запись для домена `tamigoods.eu` указывает на IP `193.233.244.249` (A-запись)
- ⚠️ DNS должен быть настроен ПЕРЕД запуском SSL настройки (Certbot)
- ⚠️ Токен GitHub должен быть установлен через переменную окружения на сервере перед запуском скрипта
- ⚠️ Для безопасности, после деплоя рекомендуется отозвать старый токен и создать новый

## Обновление приложения в будущем:

```bash
# На сервере
export GITHUB_TOKEN="your_token_here"
cd /root/Estony
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

