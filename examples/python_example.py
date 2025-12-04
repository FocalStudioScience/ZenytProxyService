#!/usr/bin/env python3
"""
Zenyt Proxy Service - Python Usage Example

This example shows how to use the Zenyt Proxy Service in Python.
The proxy provides a fixed IP address (54.243.229.107) for outbound requests.

Requirements:
    pip install requests aiohttp

Note: This will only work from within an AWS VPC that has network access
to the proxy instance.
"""

import requests
import asyncio

# Proxy configuration
PROXY_HOST = "54.243.229.107"
PROXY_PORT = 3128
PROXY_URL = f"http://{PROXY_HOST}:{PROXY_PORT}"


def example_requests():
    """Example using the requests library."""
    print("=== requests library example ===")
    
    proxies = {
        'http': PROXY_URL,
        'https': PROXY_URL
    }
    
    # Make a request through the proxy
    response = requests.get('https://httpbin.org/ip', proxies=proxies, timeout=30)
    print(f"Your IP (via proxy): {response.json()['origin']}")
    
    # The IP should be 54.243.229.107
    assert response.json()['origin'] == PROXY_HOST, "IP mismatch!"
    print("✓ Request successful through proxy\n")


def example_requests_session():
    """Example using requests Session for connection reuse."""
    print("=== requests Session example ===")
    
    session = requests.Session()
    session.proxies = {
        'http': PROXY_URL,
        'https': PROXY_URL
    }
    
    # Make multiple requests efficiently
    urls = [
        'https://httpbin.org/ip',
        'https://httpbin.org/headers',
        'https://httpbin.org/get'
    ]
    
    for url in urls:
        response = session.get(url, timeout=30)
        print(f"GET {url}: {response.status_code}")
    
    print("✓ Session requests successful\n")


async def example_aiohttp():
    """Example using aiohttp for async requests."""
    print("=== aiohttp async example ===")
    
    import aiohttp
    
    async with aiohttp.ClientSession() as session:
        async with session.get(
            'https://httpbin.org/ip',
            proxy=PROXY_URL,
            timeout=aiohttp.ClientTimeout(total=30)
        ) as response:
            data = await response.json()
            print(f"Your IP (via proxy): {data['origin']}")
    
    print("✓ Async request successful\n")


def example_env_variable():
    """Example showing how to set proxy via environment variable."""
    print("=== Environment variable example ===")
    
    import os
    
    # Set environment variables (normally done before running script)
    os.environ['HTTP_PROXY'] = PROXY_URL
    os.environ['HTTPS_PROXY'] = PROXY_URL
    
    # requests will automatically use these
    response = requests.get('https://httpbin.org/ip', timeout=30)
    print(f"Your IP (via env proxy): {response.json()['origin']}")
    
    # Clean up
    del os.environ['HTTP_PROXY']
    del os.environ['HTTPS_PROXY']
    
    print("✓ Environment variable proxy successful\n")


if __name__ == '__main__':
    print("Zenyt Proxy Service - Python Examples")
    print(f"Proxy: {PROXY_URL}")
    print("=" * 50)
    print()
    
    try:
        example_requests()
        example_requests_session()
        asyncio.run(example_aiohttp())
        example_env_variable()
        
        print("=" * 50)
        print("All examples completed successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
        print("\nNote: This example only works from within an AWS VPC")
        print("that has network access to the proxy instance.")

