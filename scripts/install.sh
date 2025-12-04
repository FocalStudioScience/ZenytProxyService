#!/bin/bash
# Zenyt Proxy Service - Installation Script
# Run this on the EC2 instance to install and configure the proxy

set -e

echo "=== Zenyt Proxy Service Installation ==="

# Update system
echo "Updating system packages..."
sudo dnf update -y

# Install Squid
echo "Installing Squid proxy..."
sudo dnf install -y squid

# Backup original config
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.backup

# Copy our custom config
echo "Configuring Squid..."
sudo cp /home/ec2-user/ZenytProxyService/squid.conf /etc/squid/squid.conf

# Set proper permissions
sudo chown root:squid /etc/squid/squid.conf
sudo chmod 640 /etc/squid/squid.conf

# Create log directory if it doesn't exist
sudo mkdir -p /var/log/squid
sudo chown squid:squid /var/log/squid

# Initialize Squid cache directories
echo "Initializing Squid cache..."
sudo squid -z 2>/dev/null || true

# Enable and start Squid service
echo "Starting Squid service..."
sudo systemctl enable squid
sudo systemctl start squid

# Wait for Squid to start
sleep 2

# Check status
if sudo systemctl is-active --quiet squid; then
    echo "✓ Squid proxy is running successfully!"
    echo "Proxy is available on port 3128"
else
    echo "✗ Failed to start Squid. Checking logs..."
    sudo journalctl -u squid -n 20
    exit 1
fi

echo ""
echo "=== Installation Complete ==="
echo "Proxy Address: 54.243.229.107:3128"

