#!/bin/bash
# Zenyt Proxy Service - Status Script
# Shows the status of the Squid proxy service

echo "=== Zenyt Proxy Service Status ==="
echo ""

# Check if Squid is running
if sudo systemctl is-active --quiet squid; then
    echo "Status: ✓ RUNNING"
else
    echo "Status: ✗ STOPPED"
fi

echo ""
echo "Service Details:"
sudo systemctl status squid --no-pager -l

echo ""
echo "Listening on:"
sudo ss -tlnp | grep squid || echo "Not listening on any ports"

echo ""
PUBLIC_IP=$(TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "54.243.229.107")
echo "Public IP: $PUBLIC_IP"
echo "Proxy Port: 3128"

echo ""
echo "Recent log entries:"
sudo tail -10 /var/log/squid/access.log 2>/dev/null || echo "No access logs yet"

