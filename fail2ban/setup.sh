  #!/usr/bin/env bash
#
# fail2ban host setup: create directories, set permissions, validate/configure host.
# Run from the fail2ban project directory or set FAIL2BAN_BASE.
#
set -e

# Base directory: env FAIL2BAN_BASE, or directory containing this script
FAIL2BAN_BASE="${FAIL2BAN_BASE:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

echo "fail2ban setup"
echo "  FAIL2BAN_BASE=${FAIL2BAN_BASE}"
echo ""

# --- Create directories ---
echo "Creating directory structure..."

mkdir -p "${FAIL2BAN_BASE}/fail2ban-config"
mkdir -p "${FAIL2BAN_BASE}/fail2ban-config/fail2ban"
mkdir -p "${FAIL2BAN_BASE}/f2b-run"
mkdir -p "${FAIL2BAN_BASE}/config"

echo "  ${FAIL2BAN_BASE}/fail2ban-config (fail2ban /config)"
echo "  ${FAIL2BAN_BASE}/fail2ban-config/fail2ban (jail.local, etc.)"
echo "  ${FAIL2BAN_BASE}/f2b-run (fail2ban runtime socket/state)"
echo "  ${FAIL2BAN_BASE}/config (fail2ban-ui config)"
echo ""

# --- Permissions ---
echo "Setting permissions..."

# f2b-run must be writable by fail2ban (often root in container)
chmod 755 "${FAIL2BAN_BASE}/f2b-run"
# Config dirs: readable by container user (lsio uses 911)
chmod -R 755 "${FAIL2BAN_BASE}/fail2ban-config"
chmod -R 755 "${FAIL2BAN_BASE}/config"

# Optional: set ownership to match Docker user (e.g. root or 911 for linuxserver)
# Uncomment and adjust if you run Docker as a specific user:
# chown -R 911:911 "${FAIL2BAN_BASE}/fail2ban-config" "${FAIL2BAN_BASE}/config"
# chown -R root:root "${FAIL2BAN_BASE}/f2b-run"

echo "  Done."
echo ""

# --- Host validation ---
echo "Validating host..."

ERR=0

if ! command -v docker &>/dev/null; then
  echo "  ERROR: Docker not found. Install Docker and ensure it is on PATH."
  ERR=1
else
  echo "  OK   Docker: $(docker --version 2>/dev/null || true)"
fi

if [[ ! -d /var/log ]]; then
  echo "  ERROR: /var/log not found. fail2ban needs read-only access to host logs."
  ERR=1
else
  echo "  OK   /var/log exists"
fi

if [[ ! -d /var/log/httpd ]]; then
  echo "  WARN /var/log/httpd not found. Create it if you use Apache and want to ban from Apache logs."
  mkdir -p /var/log/httpd 2>/dev/null || true
  if [[ -d /var/log/httpd ]]; then
    echo "       Created /var/log/httpd."
  fi
else
  echo "  OK   /var/log/httpd exists"
fi

# proxy-net is required for fail2ban-ui
if docker network inspect proxy-net &>/dev/null; then
  echo "  OK   Docker network 'proxy-net' exists"
else
  echo "  WARN Docker network 'proxy-net' not found. Create it for fail2ban-ui: docker network create proxy-net"
fi

# fail2ban with network_mode: host needs iptables or nftables on the host
if command -v iptables &>/dev/null || command -v nft &>/dev/null; then
  echo "  OK   iptables or nft available for banning"
else
  echo "  WARN iptables/nft not found. fail2ban may not be able to add firewall rules."
fi

echo ""

if [[ $ERR -ne 0 ]]; then
  echo "Fix the errors above and re-run this script."
  exit 1
fi

# --- Write .env for docker-compose ---
ENV_FILE="${FAIL2BAN_BASE}/.env"
if [[ -f "${ENV_FILE}" ]] && grep -q '^FAIL2BAN_BASE=' "${ENV_FILE}" 2>/dev/null; then
  echo "  .env already contains FAIL2BAN_BASE; leaving it unchanged."
else
  echo "FAIL2BAN_BASE=${FAIL2BAN_BASE}" >> "${ENV_FILE}"
  echo "  Wrote FAIL2BAN_BASE to ${ENV_FILE}"
fi

echo ""
echo "Setup complete. Start with: docker compose up -d"
