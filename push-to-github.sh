#!/bin/bash
set -e

# Токен должен быть установлен через переменную окружения
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Ошибка: GITHUB_TOKEN не установлен!"
    echo "Установите переменную окружения перед запуском скрипта:"
    echo "  export GITHUB_TOKEN=\"your_token_here\""
    echo "  ./push-to-github.sh"
    exit 1
fi

echo "=== Получение информации о GitHub пользователе ==="
USER_INFO=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user)
GITHUB_USER=$(echo $USER_INFO | grep -o '"login":"[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "Ошибка: Не удалось получить информацию о пользователе GitHub"
    exit 1
fi

echo "GitHub пользователь: $GITHUB_USER"

REPO_NAME="Estony"
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "=== Настройка Git ==="
git config user.name "${GITHUB_USER}"
git config user.email "${GITHUB_USER}@users.noreply.github.com"

echo "=== Добавление удаленного репозитория ==="
if git remote get-url origin &> /dev/null; then
    git remote set-url origin "${REMOTE_URL}"
else
    git remote add origin "${REMOTE_URL}"
fi

echo "=== Проверка статуса Git ==="
git status

echo "=== Добавление всех изменений ==="
git add .

echo "=== Создание коммита ==="
git commit -m "Deploy: Docker setup with nginx and SSL" || echo "Нет изменений для коммита"

echo "=== Push в GitHub ==="
git push -u origin main || git push -u origin master || echo "Возможно, ветка уже запушена"

echo "=== Готово! Репозиторий обновлен на GitHub ==="

