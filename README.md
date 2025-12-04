# Zenyt Proxy Service

A simple HTTP/HTTPS proxy service running on AWS EC2 with a fixed elastic IP address. This allows other AWS services to make outbound web requests from a consistent IP address.

## Overview

- **Proxy IP**: `54.243.229.107`
- **Proxy Port**: `3128`
- **Protocol**: HTTP (handles HTTP and HTTPS CONNECT)
- **Instance Type**: t2.micro
- **Region**: us-east-1

## Security

The proxy is secured using AWS Security Groups:

- **Only accessible from AWS VPC private IP ranges**:
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`
- **No authentication required** (network-level security via Security Groups)
- Public internet cannot access the proxy directly

This means only services running within the same AWS account (or VPC-peered accounts) can use the proxy.

---

## Consumer Usage Guide

### Python (requests)

```python
import requests

# Configure proxy
proxies = {
    'http': 'http://54.243.229.107:3128',
    'https': 'http://54.243.229.107:3128'
}

# Make request through proxy
response = requests.get('https://httpbin.org/ip', proxies=proxies)
print(response.json())
# Output: {"origin": "54.243.229.107"}
```

### Python (aiohttp)

```python
import aiohttp
import asyncio

async def fetch():
    proxy = 'http://54.243.229.107:3128'
    async with aiohttp.ClientSession() as session:
        async with session.get('https://httpbin.org/ip', proxy=proxy) as response:
            return await response.json()

print(asyncio.run(fetch()))
```

### Python (playwright)

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(
        proxy={
            'server': 'http://54.243.229.107:3128'
        }
    )
    page = browser.new_page()
    page.goto('https://httpbin.org/ip')
    print(page.content())
    browser.close()
```

### Node.js (axios)

```javascript
const axios = require('axios');
const HttpsProxyAgent = require('https-proxy-agent');

const httpsAgent = new HttpsProxyAgent('http://54.243.229.107:3128');

axios.get('https://httpbin.org/ip', { httpsAgent })
  .then(response => console.log(response.data));
```

### Node.js (fetch with node-fetch)

```javascript
const fetch = require('node-fetch');
const HttpsProxyAgent = require('https-proxy-agent');

const agent = new HttpsProxyAgent('http://54.243.229.107:3128');

fetch('https://httpbin.org/ip', { agent })
  .then(res => res.json())
  .then(console.log);
```

### cURL

```bash
# HTTP request
curl -x http://54.243.229.107:3128 http://httpbin.org/ip

# HTTPS request  
curl -x http://54.243.229.107:3128 https://httpbin.org/ip
```

### Environment Variables

Most HTTP clients respect these environment variables:

```bash
export HTTP_PROXY=http://54.243.229.107:3128
export HTTPS_PROXY=http://54.243.229.107:3128

# Then just run your application normally
python my_script.py
```

### AWS Lambda / ECS

For AWS Lambda or ECS services that need to use this proxy:

1. Ensure the Lambda/ECS task is in a VPC
2. Ensure the VPC has network connectivity to the proxy (same VPC or VPC peering)
3. Configure the proxy in your application code (see examples above)

---

## Administration

### Prerequisites

- SSH key file: `~/.ssh/rr694.pem` (or set `SSH_KEY` env var)
- AWS CLI configured

### Initial Deployment

```bash
# Clone the repo
git clone https://github.com/FocalStudioScience/ZenytProxyService.git
cd ZenytProxyService

# Deploy to EC2 instance
chmod +x deploy.sh
./deploy.sh
```

### Remote Control

```bash
# Make the script executable
chmod +x remote.sh

# Check status
./remote.sh status

# Start/stop/restart
./remote.sh start
./remote.sh stop
./remote.sh restart

# View logs
./remote.sh logs

# SSH into the server
./remote.sh ssh

# Redeploy after config changes
./remote.sh deploy
```

### Using a different SSH key

```bash
SSH_KEY=/path/to/your/key.pem ./remote.sh status
```

---

## Configuration

The proxy configuration is in `squid.conf`. Key settings:

| Setting | Value | Description |
|---------|-------|-------------|
| Port | 3128 | Proxy listening port |
| Cache | 64MB | In-memory cache size |
| Timeout | 300s | Read/request timeout |
| Access | VPC only | Only private IP ranges allowed |

### Modifying Configuration

1. Edit `squid.conf`
2. Run `./deploy.sh` to redeploy
3. Or manually: `./remote.sh ssh` then edit and restart

---

## Infrastructure

### EC2 Instance

- **Instance ID**: `i-063962269a03d93d6`
- **Instance Type**: `t2.micro`
- **AMI**: Amazon Linux 2023
- **Key Pair**: `rr694`
- **Security Group**: `zenyt-proxy-service-sg` (sg-0eb1dbd9342e53869)

### Elastic IP

- **Allocation ID**: `eipalloc-0f57e4b1ef2502d5a`
- **Public IP**: `54.243.229.107`
- **Name**: `zenyt-proxy-service-prod`

### Security Group Rules

| Type | Port | Source | Description |
|------|------|--------|-------------|
| SSH | 22 | 0.0.0.0/0 | SSH access |
| TCP | 3128 | 10.0.0.0/8 | Proxy - AWS VPC |
| TCP | 3128 | 172.16.0.0/12 | Proxy - Private range |

---

## Troubleshooting

### Proxy not responding

```bash
# Check if instance is running
aws ec2 describe-instances --instance-ids i-063962269a03d93d6 --query 'Reservations[0].Instances[0].State.Name'

# Check Squid status
./remote.sh status
```

### Connection refused

1. Verify you're connecting from a VPC (not public internet)
2. Check Security Group allows your IP range
3. Verify Squid is running: `./remote.sh status`

### Slow performance

```bash
# Check access logs
./remote.sh logs

# SSH in and check system resources
./remote.sh ssh
top
```

---

## Cost Estimate

- **t2.micro**: ~$8.50/month (or free tier eligible)
- **Elastic IP**: Free when attached to running instance
- **Data transfer**: Standard AWS rates

---

## License

MIT

