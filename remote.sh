#!/bin/bash
# Zenyt Proxy Service - Remote Control Script
# Run this locally to control the proxy remotely

set -e

# Configuration
PROXY_HOST="54.243.229.107"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/rr694.pem}"
SSH_USER="ec2-user"
REMOTE_DIR="/home/ec2-user/ZenytProxyService"

usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start   - Start the proxy service"
    echo "  stop    - Stop the proxy service"
    echo "  restart - Restart the proxy service"
    echo "  status  - Show proxy service status"
    echo "  logs    - Show recent access logs"
    echo "  ssh     - SSH into the proxy server"
    echo "  deploy  - Redeploy configuration"
    echo ""
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

COMMAND="$1"

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY environment variable to your key path"
    exit 1
fi

case "$COMMAND" in
    start)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "$REMOTE_DIR/scripts/start.sh"
        ;;
    stop)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "$REMOTE_DIR/scripts/stop.sh"
        ;;
    restart)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "sudo systemctl restart squid"
        echo "✓ Proxy service restarted"
        ;;
    status)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "$REMOTE_DIR/scripts/status.sh"
        ;;
    logs)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST" "sudo tail -50 /var/log/squid/access.log"
        ;;
    ssh)
        ssh -i "$SSH_KEY" "$SSH_USER@$PROXY_HOST"
        ;;
    deploy)
        "$(dirname "$0")/deploy.sh"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        usage
        ;;
esac

