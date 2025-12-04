#!/bin/bash
# Zenyt Proxy Service - Deployment Script
# Run this locally to deploy to the EC2 instance

set -e

# Configuration
PROXY_HOST="54.243.229.107"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/rr694.pem}"
SSH_USER="ec2-user"
REMOTE_DIR="/home/ec2-user/ZenytProxyService"

echo "=== Zenyt Proxy Service Deployment ==="
echo "Deploying to: $SSH_USER@$PROXY_HOST"
echo "Using SSH key: $SSH_KEY"
echo ""

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY environment variable to your key path"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Copying files to remote server..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$PROXY_HOST" "mkdir -p $REMOTE_DIR/scripts"
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SCRIPT_DIR/squid.conf" "$SSH_USER@$PROXY_HOST:$REMOTE_DIR/"
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SCRIPT_DIR/scripts/"*.sh "$SSH_USER@$PROXY_HOST:$REMOTE_DIR/scripts/"

echo "Setting permissions..."
ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "chmod +x $REMOTE_DIR/scripts/*.sh"

echo "Running installation..."
ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "$REMOTE_DIR/scripts/install.sh"

echo ""
echo "=== Deployment Complete ==="
echo "Proxy is available at: http://$PROXY_HOST:3128"

