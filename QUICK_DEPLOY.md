# Быстрый деплой TamiGoods

## Автоматический деплой (рекомендуется)

Выполните один скрипт для полного деплоя:

```bash
chmod +x deploy.sh
./deploy.sh
```

Этот скрипт автоматически:
1. Получит информацию о GitHub пользователе через токен
2. Запушит код в GitHub репозиторий
3. Предложит автоматический деплой через SSH (или можно выполнить вручную)

## Ручной деплой

### Шаг 1: Push кода в GitHub

```bash
chmod +x push-to-github.sh
./push-to-github.sh
```

Или вручную:
```bash
git remote add origin https://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@github.com/USERNAME/Estony.git
git push -u origin main
```

### Шаг 2: Деплой на сервер

**Подключитесь к серверу:**
```bash
ssh root@193.233.244.249
# Пароль: VTkc1YO2BZljqGd22Z
```

**Выполните скрипт деплоя:**
```bash
cd /root
wget https://raw.githubusercontent.com/USERNAME/Estony/main/server-deploy.sh
chmod +x server-deploy.sh
./server-deploy.sh
```

Или скопируйте файл `server-deploy.sh` на сервер и выполните:
```bash
chmod +x server-deploy.sh
./server-deploy.sh
```

## Что делает server-deploy.sh:

1. Устанавливает Docker и Docker Compose (если не установлены)
2. Устанавливает Nginx (если не установлен)
3. Устанавливает Certbot для SSL сертификатов
4. Получает информацию о GitHub пользователе через API токена
5. Клонирует/обновляет репозиторий с GitHub
6. Настраивает Nginx для домена `tamigoods.eu`
7. Собирает и запускает Docker контейнер
8. Настраивает SSL сертификат через Let's Encrypt
9. Настраивает автоматическое перенаправление HTTP -> HTTPS

## Важно:

- Убедитесь, что домен `tamigoods.eu` указывает на IP `193.233.244.249` (A-запись)
- DNS записи должны быть настроены перед запуском SSL настройки
- Репозиторий должен быть создан на GitHub перед деплоем
- После выполнения скрипта приложение будет доступно по адресу: **https://tamigoods.eu**

## Проверка статуса:

После деплоя можно проверить статус:
```bash
# На сервере
docker ps
systemctl status nginx
docker logs tamigoods-app
```


