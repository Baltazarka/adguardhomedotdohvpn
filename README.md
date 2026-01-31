# AdGuard Home with DoH/DoT Support

This project provides a custom Docker image for [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome), pre-configured with **Unbound** (as a recursive DNS resolver), **Stubby** (for DNS-over-TLS), and **Cloudflared** (for DNS-over-HTTPS).

It is designed to be lightweight, secure, and ready for privacy-focused DNS deployment.

## 🐳 Available Image Tags

We provide two variations of the image based on the underlying OS. Choose the one that best fits your needs:

| Tag | Base Image | Description |
| :--- | :--- | :--- |
| `latest` | **Alpine Linux** | **Recommended.** Extremely lightweight and stable. Ideal for most users. |
| `latest-wolfi` | **Wolfi OS** | Built with [Wolfi](https://github.com/wolfi-dev), offering a secure, chainguard-compatible environment with a focus on supply chain security. |

---

## 🚀 Deployment with Docker Compose

Below is a reference `compose.yaml` file to get you started.

### 1. Directory Structure
Ensure your host machine has the necessary directories created for persistence:

```bash
mkdir -p /opt/adguardhome/conf
mkdir -p /opt/adguardhome/work
mkdir -p /opt/adguardhome/certs
mkdir -p /opt/adguardhome/stubby
mkdir -p /opt/adguardhome/unbound
```

### 2. Docker Compose File

Create a file named `compose.yaml` (or `docker-compose.yml`) and paste the following configuration. Modify `YOUR_SERVER_IP` if you want to bind to a specific interface, or remove it to listen on all interfaces.

```yaml
services:
  adguardhome:
    # Choose your preferred image tag: 'latest' (Alpine) or 'latest-wolfi' (Wolfi)
    image: andrianey/adguardhomedotdoh:latest
    container_name: adguardhome
    hostname: adguardhome
    restart: unless-stopped
    
    networks:
      adguard_net:
        ipv4_address: 172.172.0.2
    
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Jakarta # Set your timezone
    
    ports:
      # DNS
      - "53:53/tcp"
      - "53:53/udp"
      # Web Interface
      - "80:80/tcp"
      - "443:443/tcp"
      - "443:443/udp" # QUIC
      # DNS-over-TLS / DNS-over-QUIC
      - "853:853/tcp"
      - "784:784/tcp"
      # AdGuard Home Initial Setup / API
      - "3000:3000/tcp"
    
    volumes:
      # Core AdGuard Home Data
      - /opt/adguardhome/conf:/opt/adguardhome/conf
      - /opt/adguardhome/work:/opt/adguardhome/work
      - /opt/adguardhome/certs:/opt/certs
      
      # Optional: Custom Config Overrides
      # Only mount these if you have custom config files you want to inject
      # - /opt/adguardhome/stubby/stubby.yml:/etc/stubby/stubby.yml:ro
      # - /opt/adguardhome/unbound/unbound.conf:/etc/unbound/unbound.conf:ro

networks:
  adguard_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.172.0.0/24
```

### 3. Start the Service

Run the container using the following command:

```bash
docker compose up -d
```

---

## 🔧 Configuration Details

### Default Components
The image comes pre-configured with sensible defaults:
- **Unbound**: Listens on local port `5335`. 
- **Stubby**: Listens on local port `8053`.
- **Cloudflared**: Configured for DNS-over-HTTPS.

### Upstreams inside AdGuard Home
When configuring AdGuard Home via the web UI (http://localhost:3000), you can use these local upstreams:

- **Unbound**: `127.0.0.1:53`
- **Stubby**: `127.0.0.1:8053`
- **Cloudflared**: `127.0.0.1:5053`

### Customizing Unbound or Stubby
If you wish to override the default configurations, place your custom config files on your host (e.g., in `/opt/adguardhome/unbound/`) and uncomment the volume mappings in the Docker Compose file.

---

## �️ Security Note
This setup exposes port `53` (DNS) and `80/443` (Web). 
- Ensure your firewall allows traffic on these ports if you plan to use it externally.
- If running on a public VPS, it is highly recommended to **restrict port 53** to your trusted IP addresses or VPN tunnel to prevent your server from being used in DNS amplification attacks.