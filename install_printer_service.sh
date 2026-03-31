#!/usr/bin/env bash
set -euo pipefail

JAR_URL="${1:-}"

if [ -z "$JAR_URL" ]; then
  echo "Usage: $0 <jar_download_url>"
  exit 1
fi

SERVICE_NAME="printer.service"
INSTALL_DIR="/opt/pos/bin"
NEW_JAR="$INSTALL_DIR/Printer.jar"
OLD_JAR="$INSTALL_DIR/Printer_old.jar"
TMP_JAR="/tmp/Printer.jar.$$"

echo "Downloading new JAR..."
wget -O "$TMP_JAR" "$JAR_URL"

if [ ! -s "$TMP_JAR" ]; then
  echo "Download failed or file is empty."
  exit 1
fi

echo "Stopping and disabling $SERVICE_NAME..."
sudo systemctl stop "$SERVICE_NAME" || true
sudo systemctl disable "$SERVICE_NAME" || true

echo "Ensuring install directory exists..."
sudo mkdir -p "$INSTALL_DIR"

if [ -f "$NEW_JAR" ]; then
  echo "Backing up existing Printer.jar to Printer_old.jar..."
  sudo mv -f "$NEW_JAR" "$OLD_JAR"
fi

echo "Installing new JAR..."
sudo mv -f "$TMP_JAR" "$NEW_JAR"
sudo chmod 644 "$NEW_JAR"

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting $SERVICE_NAME..."
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager

echo "Done."
