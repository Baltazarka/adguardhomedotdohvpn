# AdGuard Home with Extra Privacy (DoH/DoT/Unbound)

A lightweight, security-focused Docker image for [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome), pre-packaged with **Unbound**, **Stubby**, and **Cloudflared**. 

This all-in-one image enables you to run a powerful, privacy-respecting DNS server with support for recursive resolving (Unbound), DNS-over-TLS (Stubby), and DNS-over-HTTPS (Cloudflared) right out of the box.

## 🐳 Image Tags

Choose the base image that fits your requirements:

| Tag | Base OS | Description |
| :--- | :--- | :--- |
| `latest` | **Alpine Linux** | **Standard Choice.** Ultra-lightweight and stable. Perfect for general use. |
| `latest-wolfi` | **Wolfi OS** | **Security Focused.** Built on Wolfi for a secure, underspecified supply chain environment (Chainguard-compatible). |

## 🚀 Quick Start with Docker Compose

Copy the following into a `compose.yaml` file to deploy immediately.

### Directory Setup
Ensure you have folders for persistence on your host:
```bash
mkdir -p /opt/adguardhome/conf /opt/adguardhome/work /opt/adguardhome/certs
```

### compose.yaml

```yaml
services:
  adguardhome:
    # Option 1: Alpine-based (Standard)
    image: andrianey/adguardhomedotdoh:latest
    # Option 2: Wolfi-based (Security)
    # image: andrianey/adguardhomedotdoh:latest-wolfi
    
    container_name: adguardhome
    hostname: adguardhome
    restart: unless-stopped
    
    # Optional: Network Configuration
    # networks:
    #   adguard_net:
    #     ipv4_address: 172.172.0.2

    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Jakarta  # Change to your timezone
    
    ports:
      # DNS (Standard)
      - "53:53/tcp"
      - "53:53/udp"
      
      # Web Interface
      - "80:80/tcp"
      - "443:443/tcp"
      - "443:443/udp" # HTTP/3 (QUIC)
      
      # DNS-over-TLS / DNS-over-QUIC
      - "853:853/tcp"
      - "784:784/tcp"
      
      # Initial Setup / API
      - "3000:3000/tcp"
    
    volumes:
      - /opt/adguardhome/conf:/opt/adguardhome/conf
      - /opt/adguardhome/work:/opt/adguardhome/work
      - /opt/adguardhome/certs:/opt/certs
      
      # Optional: Override internal configs
      # - /path/to/stubby.yml:/etc/stubby/stubby.yml:ro
      # - /path/to/unbound.conf:/etc/unbound/unbound.conf:ro

# networks:
#   adguard_net:
#     driver: bridge
#     ipam:
#       config:
#         - subnet: 172.172.0.0/24
```

## ⚙️ Configuration & Upstreams

This image runs helper DNS services internally on `localhost` (127.0.0.1). When configuring **Upstream DNS servers** in the AdGuard Home Web UI (`Settings` -> `DNS settings`), use these addresses:

| Service | Address | Description |
| :--- | :--- | :--- |
| **Unbound** | `127.0.0.1:53` | Recursive resolver. Uses root hints to resolve domains directly. |
| **Stubby** | `127.0.0.1:8053` | DNS-over-TLS provider. |
| **Cloudflared** | `127.0.0.1:5053` | DNS-over-HTTPS provider. |

### Why use this?
*   **Unbound**: Adds privacy by acting as your own recursive DNS server, contacting root servers directly instead of a central upstream.
*   **Stubby/Cloudflared**: Encrypts your DNS traffic to external resolvers preventing ISP snooping.
