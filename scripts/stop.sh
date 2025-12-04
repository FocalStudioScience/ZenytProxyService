#!/bin/bash
# Zenyt Proxy Service - Stop Script
# Stops the Squid proxy service

set -e

echo "Stopping Zenyt Proxy Service..."
sudo systemctl stop squid

if ! sudo systemctl is-active --quiet squid; then
    echo "✓ Squid proxy stopped successfully"
else
    echo "✗ Failed to stop Squid proxy"
    exit 1
fi

