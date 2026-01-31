#!/bin/sh
set -e

# 1. Fix Permissions (Agar warning 0700 di log hilang)
mkdir -p /opt/adguardhome/work
chmod 700 /opt/adguardhome/work

# 2. Run crontab service.
/usr/sbin/crond -L /var/log/cron.log

# 3. Run Unbound
# Pastikan di unbound.conf kamu port-nya BUKAN 53 (misal 5335)
/usr/sbin/unbound -p -v -d &
/usr/sbin/unbound-anchor -4 -r /var/lib/unbound/root.hints -a /var/lib/unbound/root.key

# 4. Run Cloudflare DNS (Cloudflared)
/usr/local/bin/cloudflared proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query --upstream https://2606:4700:4700::1111/dns-query --upstream https://2606:4700:4700::1001/dns-query &

# 5. Run Stubby (Lokasi binary diperbaiki ke /usr/bin/)
/usr/bin/stubby -C /etc/stubby/stubby.yml -l &

# 6. Run AdGuardHome
# Menghapus flag -h 0.0.0.0 karena AdGuard biasanya baca binding dari yaml.
# Jika tetap ingin dipaksa, pastikan port 53 tidak bentrok dengan Unbound.
/opt/adguardhome/AdGuardHome --no-check-update -c /opt/adguardhome/conf/AdGuardHome.yaml -w /opt/adguardhome/work

exec "$@"