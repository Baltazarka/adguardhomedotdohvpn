# AdGuard Home with DoH, DoT, DoQ and DNSCrypt upstream resolver

### ℹ️ Since [cloudflared](https://developers.cloudflare.com/changelog/2025-11-11-cloudflared-proxy-dns/) `proxy-dns`  command is deprecated, Stubby & cloudflared are now replaced with dnsproxy ℹ️

This project provides a custom Docker image for [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) pre-configured with **Unbound** (as a recursive DNS resolver) with Valkey in-memory cache (Redis replacement), and **dnsproxy** (for unified DoH/DoT upstream handling).

[GitHub](https://github.com/andrianey/adguardhomedotdoh)

![Check My DNS](https://raw.githubusercontent.com/andrianey/adguardhomedotdoh/refs/heads/latest/cmdns.jpg)
![Cloudflare-Test](https://raw.githubusercontent.com/andrianey/adguardhomedotdoh/7141b52e7e17ed0264a5a639a610ecd97dccc54e/cloudflare-dns.jpg)

---

## 🚦 Build Status

| Branch | Pipeline | Image Tag |
| :--- | :--- | :--- |
| `latest` | [![latest](https://gitlab.com/andrianey/adguardhomedotdoh/badges/latest/pipeline.svg)](https://gitlab.com/andrianey/adguardhomedotdoh/-/pipelines?ref=latest) | [![Docker Image Version (latest)](https://img.shields.io/docker/v/andrianey/adguardhomedotdoh/latest?logo=docker&label=latest&color=blue)](https://hub.docker.com/r/andrianey/adguardhomedotdoh/tags) |
| `latest-wolfi` | [![latest-wolfi](https://gitlab.com/andrianey/adguardhomedotdoh/badges/latest-wolfi/pipeline.svg)](https://gitlab.com/andrianey/adguardhomedotdoh/-/pipelines?ref=latest-wolfi) | [![Docker Image Version (latest-wolfi)](https://img.shields.io/docker/v/andrianey/adguardhomedotdoh/latest-wolfi?logo=docker&label=latest-wolfi&color=blue)](https://hub.docker.com/r/andrianey/adguardhomedotdoh/tags) |
| `hardened` | [![hardened](https://gitlab.com/andrianey/adguardhomedotdoh/badges/hardened/pipeline.svg)](https://gitlab.com/andrianey/adguardhomedotdoh/-/pipelines?ref=hardened) | [![Docker Image Version (hardened)](https://img.shields.io/docker/v/andrianey/adguardhomedotdoh/hardened?logo=docker&label=hardened&color=orange)](https://hub.docker.com/r/andrianey/adguardhomedotdoh/tags) |
| `hardened-wolfi` | [![hardened-wolfi](https://gitlab.com/andrianey/adguardhomedotdoh/badges/hardened-wolfi/pipeline.svg)](https://gitlab.com/andrianey/adguardhomedotdoh/-/pipelines?ref=hardened-wolfi) | [![Docker Image Version (hardened-wolfi)](https://img.shields.io/docker/v/andrianey/adguardhomedotdoh/hardened-wolfi?logo=docker&label=hardened-wolfi&color=red)](https://hub.docker.com/r/andrianey/adguardhomedotdoh/tags) |

---

## 📦 Upstream Component Versions

All components are built from **latest upstream source** at the time of each CI pipeline run. The badges below reflect the latest available upstream release:

| Component | Latest Upstream Version | Source |
| :--- | :--- | :--- |
| **AdGuard Home** | [![GitHub Release](https://img.shields.io/github/v/release/AdguardTeam/AdGuardHome?logo=adguard&label=AdGuardHome&color=67b346)](https://github.com/AdguardTeam/AdGuardHome/releases/latest) | [AdguardTeam/AdGuardHome](https://github.com/AdguardTeam/AdGuardHome) |
| **dnsproxy** | [![GitHub Release](https://img.shields.io/github/v/release/AdguardTeam/dnsproxy?logo=adguard&label=dnsproxy&color=67b346)](https://github.com/AdguardTeam/dnsproxy/releases/latest) | [AdguardTeam/dnsproxy](https://github.com/AdguardTeam/dnsproxy) |
| **Unbound** | [![GitHub Release](https://img.shields.io/github/v/release/NLnetLabs/unbound?logo=git&label=Unbound&color=0077cc)](https://github.com/NLnetLabs/unbound/releases/latest) | [NLnetLabs/unbound](https://github.com/NLnetLabs/unbound) |

## Available Image Tags

| Tag | Base Image | Security Level | Description |
| :--- | :--- | :--- | :--- |
| `latest` | Alpine Linux | Standard | Standard image running as root. Uses `dnsproxy` binary release. |
| `latest-wolfi` | Wolfi OS | Enhanced | Built with [Wolfi](https://github.com/wolfi-dev). Uses `dnsproxy` binary release. |
| `hardened` | Alpine Edge | **High** | **Non-Root execution** + **Zero CVE**. Built from source. |
| `hardened-wolfi` | Wolfi OS | **Maximum** | Wolfi base + Non-Root + **Zero CVE**. Maximum security hardening. |

---

## Quick Start (Hardened Images)

The `hardened` and `hardened-wolfi` images use a **Hybrid Setup Mode** unless you bind an existing AdGuardHome configuration.

1.  **First Run**: The container starts as **Root** to allow you to complete the AdGuard Home "Get Started" wizard (which requires root).
2.  **Setup**: Access `http://localhost:3000` and finish the setup.
3.  **Restart**: **You MUST restart the container** after setup.
4.  **Runtime**: On the second boot, it automatically drops privileges and runs as the **non-root `adguard` user**.
---
### Docker Compose

```yaml
services:
  adguardhome:
    # Choose your preferred tag: 'latest', 'latest-wolfi', 'hardened', or 'hardened-wolfi'
    image: andrianey/adguardhomedotdoh:latest
    container_name: adguardhome
    hostname: adguardhome
    restart: unless-stopped
    
    networks:
      adguard_net:
        ipv4_address: 172.172.0.2
    
    environment:
      - TZ=Asia/Jakarta # Set your timezone
      - PUID=1000       # User ID for file ownership
      - PGID=1000       # Group ID for file ownership
      # Optional: Custom DNS Proxy Settings
      # - DNSPROXY_UPSTREAM=tls://1.1.1.1 tls://1.0.0.1 https://1.1.1.1/dns-query https://1.0.0.1/dns-query tls://[2606:4700:4700::1111] tls://[2606:4700:4700::1001] https://[2606:4700:4700::1111]/dns-query https://[2606:4700:4700::1001]/dns-query tls://9.9.9.9 tls://149.112.112.112 tls://[2620:fe::fe] tls://[2620:fe::9] https://dns9.quad9.net/dns-query
      # - DNSPROXY_FLAGS=--upstream-mode=parallel --cache --cache-optimistic --cache-size=4194304 --cache-min-ttl=600
      
    ports:
      # DNS
      - "53:53/tcp"
      - "53:53/udp"
      - "853:853/tcp"
      - "853:853/udp"
      # Web & DoH
      - "80:80/tcp"
      - "443:443/tcp"
      - "443:443/udp"
      - "3000:3000/tcp"
      # DHCP
      - "67:67/udp"
      - "68:68/udp"
    
    volumes:
      # Core AdGuard Home Data for persistent configuration
      - /opt/adguardhome/conf:/opt/adguardhome/conf
      - /opt/adguardhome/work:/opt/adguardhome/work

      # Mount custom SSL certificates to enable encryption
      # - /opt/adguardhome/certs:/opt/certs
      
      # Optional: Custom Config Overrides
      # - /opt/adguardhome/unbound/unbound.conf:/etc/unbound/unbound.conf

networks:
  adguard_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.172.0.0/24
```

---

## Environment Variables

You can customize the `dnsproxy` configuration using environment variables in your `docker-compose.yml`:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `DNSPROXY_UPSTREAM` | Cloudflare DoT/DoH | Space-separated list of upstream servers (e.g., `tls://1.1.1.1 https://1.1.1.1/dns-query`). |
| `DNSPROXY_FLAGS` | `--verbose` | Additional flags for dnsproxy (e.g., `--cache-optimistic`). |

---

## Internal Components
The image comes pre-configured with the following services running internally:

| Component | Internal Port | Description |
| :--- | :--- | :--- |
| **Unbound** | `127.0.0.1:5335` | Recursive resolver with DNSSEC validation + Valkey Cache. |
| **dnsproxy** | `127.0.0.1:8053` | Upstream DoH/DoT proxy (replaces Stubby/Cloudflared). |

## Configuration

### AdGuard Home Upstream DNS
The architecture is designed to chain requests:
`Client -> AdGuard Home -> Unbound -> Valkey Cache -> dnsproxy -> Configured upstreams (DoH, DoT, DoQ and DNSCrypt support)`

Configure **Settings -> DNS settings** with:

1.  **Upstream DNS servers**:
    ```
    127.0.0.1:5335
    ```

2.  **Verify**:
    *   Click "Test upstreams" to ensure connectivity.
    *   **Cache size**: You may set this to `0` in AdGuard Home to rely on Unbound's efficient caching paired with Valkey.

---

## Hardening features
The `hardened` tags implement best practices for container security:
*   **Non-Root User**: Runs as a dedicated `adguard` user (UID 1000).
*   **Capabilities**: Uses `libcap` to bind to privileged ports (53, 80) without full root access.
*   **Minimal Base**: Wolfi edition offers a software supply chain secure base image.
*   **Permission Fixer**: The entrypoint automatically corrects permissions on mounted volumes.

**Note**: Since the process runs as UID 1000, ensure your host volumes are writable by this user or let Docker automatically handle the ownership (which the entrypoint facilitates).
