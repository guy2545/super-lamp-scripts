#!/bin/bash

set -e

echo "[INFO] Updating APT sources..."
cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib
deb http://security.debian.org/debian-security bookworm-security main contrib
EOF

echo "[INFO] Running apt-get update..."
apt-get update

echo "[INFO] Performing dist-upgrade..."
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -y

echo "[INFO] Disabling network services..."
systemctl disable --now systemd-networkd-wait-online.service || true
systemctl disable --now systemd-networkd.service || true
systemctl disable --now ifupdown-wait-online || true

echo "[INFO] Installing ifupdown2..."
apt-get install ifupdown2 -y

echo "[INFO] Cleaning up unused packages..."
apt-get autoremove --purge -y

echo "[INFO] Rebooting system..."
reboot
