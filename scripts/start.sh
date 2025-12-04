#!/bin/bash
# Zenyt Proxy Service - Start Script
# Starts or restarts the Squid proxy service

set -e

echo "Starting Zenyt Proxy Service..."

# Reload config if changed
sudo squid -k reconfigure 2>/dev/null || sudo systemctl restart squid

# Check status
if sudo systemctl is-active --quiet squid; then
    echo "✓ Squid proxy is running"
    echo "Proxy address: 54.243.229.107:3128"
else
    echo "✗ Squid proxy is not running. Starting..."
    sudo systemctl start squid
fi

