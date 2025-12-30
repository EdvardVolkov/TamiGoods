#!/bin/bash
set -e

DOMAIN="tamigoods.eu"
REPO_NAME="Estony"

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set!"
    echo "Set the environment variable before running the script:"
    echo "  export GITHUB_TOKEN=\"your_token_here\""
    echo "  ./server-deploy.sh"
    exit 1
fi

echo "=== Setting up server for TamiGoods ==="

# Get GitHub user via API
echo "Getting GitHub user information..."
GITHUB_USER=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | grep -o '"login":"[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "Error: Failed to get GitHub user information"
    echo "Using default value: EdvardVolkov"
    GITHUB_USER="EdvardVolkov"
else
    echo "GitHub user: $GITHUB_USER"
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    rm get-docker.sh
else
    echo "Docker is already installed"
fi

# Install Docker Compose (check both variants: docker-compose and docker compose)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Installing Docker Compose..."
    # Try to use Docker Compose v2 (plugin)
    if docker compose version &> /dev/null; then
        echo "Docker Compose v2 is already available"
    else
        # Install Docker Compose v1
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
else
    echo "Docker Compose is already installed"
fi

# Install Nginx
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
fi

# Install Certbot
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Clone repository
echo "Cloning repository..."
cd /root
if [ -d "${REPO_NAME}" ]; then
    cd ${REPO_NAME}
    git pull || echo "Failed to update repository, continuing..."
else
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" ${REPO_NAME}
    cd ${REPO_NAME}
fi

# Create nginx configuration
echo "Configuring Nginx..."
cat > /etc/nginx/sites-available/${DOMAIN} <<'NGINX_EOF'
server {
    listen 80;
    server_name tamigoods.eu www.tamigoods.eu;

    location / {
        proxy_pass http://localhost:3000;
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
NGINX_EOF

ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# Build and run Docker container
echo "Building and starting Docker container..."
cd /root/${REPO_NAME}

# Use docker compose (v2) if available, otherwise docker-compose (v1)
if docker compose version &> /dev/null; then
    echo "Using Docker Compose v2"
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "Using Docker Compose v1"
    DOCKER_COMPOSE_CMD="docker-compose"
fi

$DOCKER_COMPOSE_CMD down || true
$DOCKER_COMPOSE_CMD build --no-cache
$DOCKER_COMPOSE_CMD up -d

# Wait for container to start
echo "Waiting for container to start..."
sleep 10

# Configure SSL
echo "Configuring SSL certificate..."
# Check if SSL is already configured
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect
else
    echo "SSL certificate already exists, updating configuration..."
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --redirect
fi

echo "=== Setup completed! ==="
echo "Application is available at: https://${DOMAIN}"
docker ps
systemctl status nginx --no-pager
