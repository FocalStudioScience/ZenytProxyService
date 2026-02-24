#!/bin/bash
# Zenyt Proxy Service - Hardening Script
# Sets up: swap, systemd auto-restart, CloudWatch agent
# Run on the EC2 instance after initial install

set -e

REMOTE_DIR="/home/ec2-user/ZenytProxyService"

echo "=== Zenyt Proxy Service Hardening ==="

# --- 1. Swap (512MB safety net for t2.micro) ---
if [ -f /swapfile ]; then
    echo "Swap already configured, skipping"
else
    echo "Creating 512MB swap file..."
    sudo dd if=/dev/zero of=/swapfile bs=1M count=512
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
    echo "✓ Swap enabled"
fi

# --- 2. Systemd override: auto-restart on OOM or crash ---
echo "Configuring systemd auto-restart for Squid..."
sudo mkdir -p /etc/systemd/system/squid.service.d
sudo tee /etc/systemd/system/squid.service.d/restart.conf > /dev/null <<'EOF'
[Service]
Restart=always
RestartSec=5
OOMPolicy=continue
EOF
sudo systemctl daemon-reload
echo "✓ Squid will auto-restart on failure/OOM"

# --- 3. CloudWatch Agent ---
echo "Installing CloudWatch agent..."
if command -v amazon-cloudwatch-agent-ctl &> /dev/null; then
    echo "CloudWatch agent already installed"
else
    sudo dnf install -y amazon-cloudwatch-agent
fi

echo "Configuring CloudWatch agent..."
sudo cp "$REMOTE_DIR/cloudwatch-agent-config.json" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo systemctl enable amazon-cloudwatch-agent
echo "✓ CloudWatch agent running"

# --- 4. Apply updated Squid config and restart ---
echo "Applying updated Squid config..."
sudo cp "$REMOTE_DIR/squid.conf" /etc/squid/squid.conf
sudo chown root:squid /etc/squid/squid.conf
sudo chmod 640 /etc/squid/squid.conf
sudo systemctl restart squid

sleep 2
if sudo systemctl is-active --quiet squid; then
    echo "✓ Squid restarted with new config"
else
    echo "✗ Squid failed to start"
    sudo journalctl -u squid -n 20
    exit 1
fi

echo ""
echo "=== Hardening Complete ==="
echo "  - Swap: 512MB"
echo "  - Squid: auto-restart on OOM/crash"
echo "  - CloudWatch: streaming squid-access, squid-cache, system logs"
echo "  - CloudWatch: mem/disk/swap metrics every 60s"
echo ""
echo "View logs at: CloudWatch > Log groups > /zenyt/proxy-service/*"
