#!/bin/bash
set -e

echo "=== Полный деплой TamiGoods ==="
echo ""
echo "Этот скрипт выполнит:"
echo "1. Push кода в GitHub репозиторий"
echo "2. Подключение к серверу и выполнение деплоя"
echo ""

# Сначала запушим код в GitHub
echo "=== Шаг 1: Push кода в GitHub ==="
chmod +x push-to-github.sh
./push-to-github.sh

echo ""
echo "=== Шаг 2: Подключение к серверу для деплоя ==="
echo "Для завершения деплоя нужно:"
echo "1. Подключиться к серверу: ssh root@193.233.244.249"
echo "2. Выполнить команду:"
echo "   wget https://raw.githubusercontent.com/EdvardVolkov/Estony/main/server-deploy.sh && chmod +x server-deploy.sh && ./server-deploy.sh"
echo ""
echo "Или скопировать server-deploy.sh на сервер и выполнить его"
echo ""

read -p "Хотите выполнить автоматический деплой через SSH? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SERVER_IP="193.233.244.249"
    SERVER_USER="root"
    
    echo "Загружаем скрипт деплоя на сервер..."
    scp server-deploy.sh ${SERVER_USER}@${SERVER_IP}:/root/
    
    echo "Выполняем деплой на сервере..."
    ssh ${SERVER_USER}@${SERVER_IP} "chmod +x /root/server-deploy.sh && /root/server-deploy.sh"
else
    echo "Ручной деплой. Следуйте инструкциям выше."
fi
