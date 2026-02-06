# 🔐 AdGuard Home Multi-Branch Security Matrix

**Build Date**: 2026-02-05  
**Repository**: andrianey/adguardhomedotdoh

## 📊 Branch Overview

| Branch | Base Image | User | Security Level | Status |
|--------|------------|------|----------------|--------|
| **`latest`** | Alpine 3.23 | Root | ⭐ Standard | ✅ **Verified** |
| **`latest-wolfi`** | Wolfi OS | Root | ⭐⭐ Enhanced | ✅ **Verified** |
| **`hardened`** | Alpine 3.23 | adguard (UID 1000) | ⭐⭐⭐ High | ✅ **Verified** |
| **`hardened-wolfi`** | Wolfi OS | adguard (UID 1000) | ⭐⭐⭐⭐ Maximum | ✅ **Verified** |

---

## 🔍 Detailed Branch Comparison

### 1. `latest` - Alpine Root (Standard Security)

**Tag**: `andrianey/adguardhomedotdoh:latest`

**Configuration**:
```yaml
Base: Alpine Linux 3.23
User: root
Stubby: Alpine package (/usr/bin/stubby)
Unbound: Custom build from source (with Valkey cachedb)
Valkey: ✅ Enabled  
Paths: /var/lib/unbound/
```

**Services**:
- ✅ Valkey (Unix Socket)
- ✅ Unbound (Port 5335, Valkey caching)
- ✅ Cloudflared (Port 5053, DoH)
- ✅ Stubby (Port 8053, DoT)
- ✅ AdGuard Home (Port 53, 3000)

**Security Features**:
- ⚠️ Runs as root
- ✅ Privacy: DoH + DoT
- ✅ DNSSEC validation
- ✅ Minimal Alpine base
- ✅ Valkey caching (100MB)

**Best For**:
- Simple deployments
- Development/testing
- When root access is acceptable

---

### 2. `latest-wolfi` - Wolfi Root (Enhanced Security)

**Tag**: `andrianey/adguardhomedotdoh:latest-wolfi`

**Configuration**:
```yaml
Base: Wolfi OS (Chainguard)
User: root
Stubby: Built from source (Debian builder)
Unbound: Built from source on Wolfi (with cachedb)
Valkey: ✅ Enabled
Paths: /var/lib/unbound/
```

**Services**:
- ✅ Valkey (Unix Socket)
- ✅ Unbound (Port 5335, Valkey caching)
- ✅ Cloudflared (Port 5053, DoH)
- ✅ Stubby (Port 8053, DoT)
- ✅ AdGuard Home (Port 53, 3000)

**Security Features**:
- ⚠️ Runs as root
- ✅ Wolfi base (fewer CVEs)
- ✅ Privacy: DoH + DoT
- ✅ DNSSEC validation
- ✅ Custom-built binaries
- ✅ Valkey caching (100MB)

**Required Dependencies**:
- yaml (for Stubby libyaml)
- libidn2 (for Stubby)
- hiredis (for Valkey)

**Best For**:
- Production with CVE concerns
- When root is acceptable but security matters
- Minimal attack surface

---

### 3. `hardened` - Alpine Non-Root (High Security)

**Tag**: `andrianey/adguardhomedotdoh:hardened`

**Configuration**:
```yaml
Base: Alpine Edge
User: adguard (UID 1000)
Stubby: Alpine package (/usr/bin/stubby)
Unbound: Built from source (Debian builder, with cachedb)
Valkey: ✅ Enabled
Privilege Drop: su-exec
Capabilities: CAP_NET_BIND_SERVICE
Paths: /var/lib/unbound/
```

**Services** (all run as `adguard` user):
- ✅ Valkey (Unix Socket, user adguard)
- ✅ Unbound (Port 5335, user adguard)
- ✅ Cloudflared (Port 5053, user adguard)
- ✅ Stubby (Port 8053, user adguard)
- ✅ AdGuard Home (Port 53, user adguard after setup)

**Security Features**:
- ✅ **Non-root execution**
- ✅ `su-exec` privilege dropping
- ✅ `setcap` for port binding
- ✅ Privacy: DoH + DoT
- ✅ DNSSEC validation
- ✅ Minimal Alpine base
- ✅ Valkey caching (100MB)

**Setup Behavior**:
- First run: Starts as ROOT for initial setup
- After config created: Automatically switches to `adguard` user
- Persistent: Always runs as `adguard` user after first setup

**Best For**:
- Production environments
- Security-conscious deployments
- When non-root is required

---

### 4. `hardened-wolfi` - Wolfi Non-Root (Maximum Security) 🏆

**Tag**: `andrianey/adguardhomedotdoh:hardened-wolfi`

**Configuration**:
```yaml
Base: Wolfi OS (Chainguard)
User: adguard (UID 1000)
Stubby: Built from source (Debian builder)
Unbound: Built from source (Debian builder, with cachedb)
Valkey: ✅ Enabled
Privilege Drop: su-exec
Capabilities: CAP_NET_BIND_SERVICE
Paths: /var/lib/unbound/
```

**Services** (all run as `adguard` user):
- ✅ Valkey (Unix Socket, user adguard)
- ✅ Unbound (Port 5335, user adguard)
- ✅ Cloudflared (Port 5053, user adguard)
- ✅ Stubby (Port 8053, user adguard)
- ✅ AdGuard Home (Port 53, user adguard after setup)

**Security Features**:
- ✅ **Non-root execution**
- ✅ **Wolfi base (minimal CVEs)**
- ✅ **Custom-built binaries**
- ✅ `su-exec` privilege dropping
- ✅ `setcap` for port binding
- ✅ Privacy: DoH + DoT
- ✅ DNSSEC validation
- ✅ Valkey caching (100MB)
- ✅ Multi-stage build isolation

**Setup Behavior**:
- First run: Starts as ROOT for initial setup
- After config created: Automatically switches to `adguard` user
- Persistent: Always runs as `adguard` user after first setup

**Best For**:
- **Maximum security production deployments** ⭐
- Compliance-heavy environments
- Zero-trust architectures
- When both non-root AND minimal CVEs are required

---

## 🎯 DNS Resolution Flow (All Branches)

```
Client Query
    ↓
AdGuard Home (Port 53)
    ↓
Unbound (Port 5335)
    ↓
Valkey Cache Check
    ↓ (if miss)
    ├─→ Stubby (Port 8053) → Cloudflare DNS-over-TLS
    └─→ Cloudflared (Port 5053) → Cloudflare DNS-over-HTTPS
```

## ⚙️ Common Configuration

### All Branches Include:
- ✅ Valkey for high-performance caching (100MB)
- ✅ Unbound on port 5335 (with DNSSEC)
- ✅ Cloudflared on port 5053 (DoH)
- ✅ Stubby on port 8053 (DoT)
- ✅ AdGuard Home on ports 53, 80, 443, 3000

### AdGuard Home Upstream DNS Setting:
For all branches, configure AdGuard Home to use:
```
127.0.0.1:5335
```

This routes through Unbound → Valkey cache → DoH/DoT proxies.

---

## 🔧 Build Commands

### Latest (Alpine Root)
```bash
git checkout latest
docker buildx build --platform linux/amd64 \
  -t andrianey/adguardhomedotdoh:latest --load .
```

### Latest-Wolfi (Wolfi Root)
```bash
git checkout latest-wolfi
docker buildx build --platform linux/amd64 \
  -t andrianey/adguardhomedotdoh:latest-wolfi --load .
```

### Hardened (Alpine Non-Root)
```bash
git checkout hardened
docker buildx build --platform linux/amd64 \
  -t andrianey/adguardhomedotdoh:hardened --load .
```

### Hardened-Wolfi (Wolfi Non-Root)
```bash
git checkout hardened-wolfi
docker buildx build --platform linux/amd64 \
  -t andrianey/adguardhomedotdoh:hardened-wolfi --load .
```

---

## 📦 Deployment Example

### Docker Run
```bash
docker run -d \
  --name adguardhome \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80/tcp \
  -p 443:443/tcp \
  -p 3000:3000/tcp \
  -v ./adguard-conf:/opt/adguardhome/conf \
  -v ./adguard-work:/opt/adguardhome/work \
  andrianey/adguardhomedotdoh:hardened-wolfi
```

### Docker Compose
```yaml
version: '3.8'
services:
  adguardhome:
    image: andrianey/adguardhomedotdoh:hardened-wolfi
    container_name: adguardhome
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80/tcp"
      - "443:443/tcp"
      - "3000:3000/tcp"
    volumes:
      - ./adguard-conf:/opt/adguardhome/conf
      - ./adguard-work:/opt/adguardhome/work
    restart: unless-stopped
```

---

## 🎓 Choosing the Right Branch

### Use `latest` if:
- ✅ You need simple, fast deployment
- ✅ Root execution is acceptable
- ✅ You're testing or in development

### Use `latest-wolfi` if:
- ✅ You want fewer CVE vulnerabilities
- ✅ Root execution is acceptable
- ✅ Security scanning is part of your CI/CD

### Use `hardened` if:
- ✅ Non-root execution is required
- ✅ You need security hardening
- ✅ Alpine's ecosystem is preferred

### Use `hardened-wolfi` if:
- ✅ **Maximum security is required** 🏆
- ✅ Non-root execution is mandatory
- ✅ Minimal CVE exposure is critical
- ✅ Compliance requirements are strict

---

## ✅ Verification Results

All 4 branches have been built and tested successfully:

| Branch | Build | Services | Stubby | Valkey | Security |
|--------|-------|----------|--------|--------|----------|
| `latest` | ✅ | ✅ All running | ✅ Working | ✅ Active | ⭐ Root |
| `latest-wolfi` | ✅ | ✅ All running | ✅ Working | ✅ Active | ⭐⭐ Wolfi+Root |
| `hardened` | ✅ | ✅ All running | ✅ Working | ✅ Active | ⭐⭐⭐ Non-Root |
| `hardened-wolfi` | ✅ | ✅ All running | ✅ Working | ✅ Active | ⭐⭐⭐⭐ Wolfi+Non-Root |

---

## 🔒 Security Hardening Summary

### Root Branches (`latest`, `latest-wolfi`)
- Container runs as root
- Simpler permission model
- Suitable for trusted environments

### Hardened Branches (`hardened`, `hardened-wolfi`)
- All services run as `adguard` user (UID 1000)
- Capabilities set via `setcap` for port binding
- Privilege dropping via `su-exec`
- **Initial setup runs as root**, then switches to non-root
- Maximum security posture

---

## 📄 License & Maintenance

- **Maintained by**: andrianey
- **Base Components**:
  - AdGuard Home (GPL-3.0)
  - Unbound (BSD)
  - Stubby (BSD)
  - Cloudflared (Apache 2.0)
  - Valkey (BSD-3-Clause)

---

**Last Updated**: 2026-02-05  
**All Branches Verified**: ✅
