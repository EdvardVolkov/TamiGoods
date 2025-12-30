# Разрешение проблемы с push в GitHub

GitHub блокирует push из-за обнаруженных токенов в истории коммитов.

## Быстрое решение (рекомендуется для первого раза):

1. Откройте этот URL в браузере для разрешения push:
   https://github.com/EdvardVolkov/Estony/security/secret-scanning/unblock-secret/37a4bB0FKtL3z6KCcCHNDudq1W3

2. После разрешения выполните push:
   ```bash
   git push -u origin main
   ```

## Полное решение (удаление токенов из истории):

Если вы хотите полностью удалить токены из истории Git, используйте один из методов ниже.

### Вариант 1: Использование git filter-repo (рекомендуется)

```bash
# Установите git-filter-repo если не установлен
pip install git-filter-repo

# Удалите токен из истории
git filter-repo --replace-text <(echo "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==>REMOVED_TOKEN") --force

# Force push (ОСТОРОЖНО: это перезапишет историю)
git push origin --force --all
```

### Вариант 2: Использование BFG Repo-Cleaner

```bash
# Скачайте BFG Repo-Cleaner
# https://rtyley.github.io/bfg-repo-cleaner/

# Создайте файл с токеном для замены
echo "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==>REMOVED_TOKEN" > tokens.txt

# Очистите историю
java -jar bfg.jar --replace-text tokens.txt

# Force push
git push origin --force --all
```

## Важно:

- После переписывания истории все участники проекта должны переклонировать репозиторий
- Токены уже были в истории, поэтому рекомендуется их отозвать и создать новые
- В будущем используйте переменные окружения вместо хардкода токенов

