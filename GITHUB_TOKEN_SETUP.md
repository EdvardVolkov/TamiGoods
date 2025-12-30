# Настройка GitHub токена с правильными правами

## Проблема
Текущий токен не имеет прав на запись в репозиторий (ошибка 403).

## Решение: Создать новый токен с правильными правами

### Шаг 1: Перейдите в настройки GitHub
1. Откройте https://github.com/settings/tokens
2. Или: Ваш профиль → Settings → Developer settings → Personal access tokens → Tokens (classic)

### Шаг 2: Создайте новый токен
1. Нажмите **"Generate new token"** → **"Generate new token (classic)"**
2. Дайте токену имя (например: "TamiGoods Deployment")

### Шаг 3: Настройте права (Scopes)
**Обязательно отметьте:**
- ✅ **repo** (полный доступ к репозиториям)
  - Это включает:
    - repo:status
    - repo_deployment
    - public_repo
    - repo:invite
    - security_events

**Опционально (для деплоя):**
- ✅ **workflow** (если используете GitHub Actions)

### Шаг 4: Сгенерируйте и скопируйте токен
1. Нажмите **"Generate token"**
2. **ВАЖНО:** Скопируйте токен сразу, он показывается только один раз!
3. Формат токена: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Шаг 5: Обновите токен в скриптах
После получения нового токена обновите его в файлах:
- `deploy.sh`
- `deploy.ps1`
- `server-setup.sh`
- `server-deploy.sh`

## Проверка прав токена

Вы можете проверить права токена через API:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.github.com/user
```

Или через PowerShell:
```powershell
$headers = @{"Authorization" = "Bearer YOUR_TOKEN"}
Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
```

## Альтернатива: Использовать SSH ключ

Вместо токена можно использовать SSH ключ:
1. Создайте SSH ключ: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Добавьте публичный ключ в GitHub: Settings → SSH and GPG keys
3. Используйте SSH URL: `git@github.com:EdvardVolkov/Estony.git`

