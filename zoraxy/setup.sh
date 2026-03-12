#!/usr/bin/env bash

set -e

BASE_DIR="/docker"

echo "Creating Zoraxy directory structure..."

# Public instance
mkdir -p ${BASE_DIR}/zoraxy-public/config
mkdir -p ${BASE_DIR}/zoraxy-public/plugin

# Tailnet instance
mkdir -p ${BASE_DIR}/zoraxy-tailnet/config
mkdir -p ${BASE_DIR}/zoraxy-tailnet/plugin

echo "Setting permissions..."

# Optional: set ownership to current user
chown -R $(whoami):$(whoami) ${BASE_DIR}/zoraxy-public
chown -R $(whoami):$(whoami) ${BASE_DIR}/zoraxy-tailnet

# Optional: secure permissions
chmod -R 750 ${BASE_DIR}/zoraxy-public
chmod -R 750 ${BASE_DIR}/zoraxy-tailnet

echo "Done."
echo ""
echo "Directory structure created:"
echo "  ${BASE_DIR}/zoraxy-public"
echo "  ${BASE_DIR}/zoraxy-tailnet"
