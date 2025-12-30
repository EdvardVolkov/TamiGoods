#!/bin/bash
set -e

# Token must be set via environment variable
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set!"
    echo "Set the environment variable before running the script:"
    echo "  export GITHUB_TOKEN=\"your_token_here\""
    echo "  ./push-to-github.sh"
    exit 1
fi

echo "=== Getting GitHub user information ==="
USER_INFO=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user)
GITHUB_USER=$(echo $USER_INFO | grep -o '"login":"[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "Error: Failed to get GitHub user information"
    exit 1
fi

echo "GitHub user: $GITHUB_USER"

REPO_NAME="Estony"
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "=== Configuring Git ==="
git config user.name "${GITHUB_USER}"
git config user.email "${GITHUB_USER}@users.noreply.github.com"

echo "=== Adding remote repository ==="
if git remote get-url origin &> /dev/null; then
    git remote set-url origin "${REMOTE_URL}"
else
    git remote add origin "${REMOTE_URL}"
fi

echo "=== Checking Git status ==="
git status

echo "=== Adding all changes ==="
git add .

echo "=== Creating commit ==="
git commit -m "Deploy: Docker setup with nginx and SSL" || echo "No changes to commit"

echo "=== Pushing to GitHub ==="
git push -u origin main || git push -u origin master || echo "Branch might already be pushed"

echo "=== Done! Repository updated on GitHub ==="
