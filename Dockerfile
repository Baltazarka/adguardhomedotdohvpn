# ============================================
# Stage 1: Extract AdGuard Home from official image
# ============================================
FROM adguard/adguardhome:latest AS adguard-source

# ============================================
# Stage 2: Final image with Alpine 3.23
# ============================================
FROM alpine:3.23

# Set labels for the image
LABEL maintainer="andrianey"
LABEL description="AdGuard Home with DoH/DoT support (Stubby, Unbound, Cloudflared)"

# 1. Install dependencies
# - Removed: dpkg (replaced with uname), bash (entrypoint uses sh), gettext (unused), explicit libs (apk handles deps)
# - Added: ca-certificates (for HTTPS), stubby, unbound, tzdata
RUN apk update && apk add --no-cache \
    stubby \
    unbound \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# 2. Copy AdGuard Home binary from the official image
COPY --from=adguard-source /opt/adguardhome/AdGuardHome /opt/adguardhome/AdGuardHome

# 3. Setup AdGuard Home directories and permissions
RUN mkdir -p /opt/adguardhome/conf /opt/adguardhome/work && \
    chmod 700 /opt/adguardhome/work

# 4. Setup Unbound
RUN mkdir -p /var/lib/unbound/ && \
    wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root

COPY unbound/unbound.conf /etc/unbound/unbound.conf

# 5. Setup Stubby
RUN mkdir -p /etc/stubby/
COPY stubby/stubby.yml /etc/stubby/stubby.yml

# 6. Install Cloudflared (Architecture detection without dpkg)
RUN set -eux; \
    # Detect architecture using uname
    arch="$(uname -m)"; \
    case "$arch" in \
    aarch64) CL_ARCH="arm64" ;; \
    x86_64)  CL_ARCH="amd64" ;; \
    armv7l)  CL_ARCH="arm" ;; \
    armhf)   CL_ARCH="arm" ;; \
    *) echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac; \
    echo "Downloading Cloudflared for $CL_ARCH..."; \
    wget -qO /usr/local/bin/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CL_ARCH}" && \
    chmod +x /usr/local/bin/cloudflared && \
    addgroup -S cloudflared && \
    adduser -S cloudflared -G cloudflared -s /bin/false -D -H && \
    chown cloudflared:cloudflared /usr/local/bin/cloudflared

# 7. Setup Cron & Permissions
COPY crontab/root /tmp/crontab_root
RUN cat /tmp/crontab_root >> /var/spool/cron/crontabs/root && rm -f /tmp/crontab_root

# 8. Entrypoint script (Ensure it uses /bin/sh)
COPY distribution/entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Expose ports
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp 853/tcp 853/udp 3000/tcp 5443/tcp 5443/udp

# Volumes
VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]

ENTRYPOINT ["/opt/entrypoint.sh"]