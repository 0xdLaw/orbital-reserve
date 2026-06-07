#!/usr/bin/env bash
set -euo pipefail

# Installs the latest Clarinet binary from the stx-labs GitHub releases
# Usage: sudo ./scripts/install-clarinet.sh

TMPFILE=$(mktemp /tmp/clarinet-XXXXXXX.tar.gz)
URL="https://github.com/stx-labs/clarinet/releases/latest/download/clarinet-linux-x64-glibc.tar.gz"

echo "Downloading Clarinet from: $URL"
if command -v wget >/dev/null 2>&1; then
  wget -nv "$URL" -O "$TMPFILE"
elif command -v curl >/dev/null 2>&1; then
  curl -sL "$URL" -o "$TMPFILE"
else
  echo "Please install wget or curl and re-run this script." >&2
  exit 1
fi

tar -xf "$TMPFILE" -C /tmp
chmod +x /tmp/clarinet
sudo mv /tmp/clarinet /usr/local/bin/clarinet
rm -f "$TMPFILE"

echo "Clarinet installed to /usr/local/bin/clarinet"
