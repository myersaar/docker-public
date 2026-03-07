#!/usr/bin/env bash

set -e

# Base directory for registry data (must match paths in docker-compose.yaml)
BASE_DIR="${BASE_DIR:-/root/docker-public/docker-registry}"

echo "Creating Docker Registry directory structure..."

mkdir -p "${BASE_DIR}/data"
mkdir -p "${BASE_DIR}/certs"
mkdir -p "${BASE_DIR}/config"

# Create minimal config.yml if it doesn't exist (required by docker-compose volume mount)
if [[ ! -f "${BASE_DIR}/config/config.yml" ]]; then
  echo "Creating default config.yml..."
  cat > "${BASE_DIR}/config/config.yml" << 'EOF'
version: 0.1
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  delete:
    enabled: true
http:
  addr: ":5000"
EOF
fi

echo "Setting ownership and permissions..."

# Set ownership to current user (or root if running as root)
chown -R "$(whoami):$(whoami)" "${BASE_DIR}"
chmod -R 750 "${BASE_DIR}"

echo "Done."
echo ""
echo "Directory structure created:"
echo "  ${BASE_DIR}/data    - registry image storage"
echo "  ${BASE_DIR}/certs   - TLS certificates (optional)"
echo "  ${BASE_DIR}/config  - config.yml"
