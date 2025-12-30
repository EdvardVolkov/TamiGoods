#!/bin/bash
set -e

echo "=== Full TamiGoods deployment ==="
echo ""
echo "This script will:"
echo "1. Push code to GitHub repository"
echo "2. Connect to server and perform deployment"
echo ""

# First, push code to GitHub
echo "=== Step 1: Pushing code to GitHub ==="
chmod +x push-to-github.sh
./push-to-github.sh

echo ""
echo "=== Step 2: Connecting to server for deployment ==="
echo "To complete deployment you need to:"
echo "1. Connect to server: ssh root@193.233.244.249"
echo "2. Run the command:"
echo "   wget https://raw.githubusercontent.com/EdvardVolkov/Estony/main/server-deploy.sh && chmod +x server-deploy.sh && ./server-deploy.sh"
echo ""
echo "Or copy server-deploy.sh to the server and run it"
echo ""

read -p "Do you want to perform automatic deployment via SSH? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SERVER_IP="193.233.244.249"
    SERVER_USER="root"
    
    echo "Uploading deployment script to server..."
    scp server-deploy.sh ${SERVER_USER}@${SERVER_IP}:/root/
    
    echo "Running deployment on server..."
    ssh ${SERVER_USER}@${SERVER_IP} "chmod +x /root/server-deploy.sh && /root/server-deploy.sh"
else
    echo "Manual deployment. Follow the instructions above."
fi
