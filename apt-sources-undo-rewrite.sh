#!/bin/bash

# Function to undo the mirror replacement in a single file
undo_rewrite() {
  local file="$1"
  local mirror="http://deb.guy2545.com"

  # Undo Debian repos
  sed -i "s#$mirror/debian#http://deb.debian.org/debian#g" "$file"
  sed -i "s#$mirror/debian#http://ftp.us.debian.org/debian#g" "$file"
  sed -i "s#$mirror/debsec#http://security.debian.org#g" "$file"
  sed -i "s#$mirror/debsec#http://deb.debian.org/debian-security#g" "$file"

  # Undo Ubuntu repos
  sed -i "s#$mirror/ubuntu#http://us.archive.ubuntu.com/ubuntu#g" "$file"
  sed -i "s#$mirror/ubusec#http://security.ubuntu.com/ubuntu#g" "$file"

  # Undo Kali repos
  sed -i "s#$mirror/kali#http://http.kali.org/kali#g" "$file"

  # Undo Proxmox repos
  sed -i "s#$mirror/proxmox#http://download.proxmox.com/debian#g" "$file"

  # Undo Caddy server
  sed -i "s#$mirror/caddy#https://dl.cloudsmith.io/public/caddy/stable/deb/debian#g" "$file"

  # Undo NodeJS from Nodesource
  sed -i "s#$mirror/node#https://deb.nodesource.com#g" "$file"

  # Undo Authelia
  sed -i "s#$mirror/authelia#https://apt.authelia.com/stable/debian/debian#g" "$file"

  # Undo Influxdata
  sed -i "s#$mirror/influx#https://repos.influxdata.com/debian#g" "$file"
}

# Undo sources.list itself
undo_rewrite '/etc/apt/sources.list'

# Undo everything in sources.list.d
export -f undo_rewrite
find '/etc/apt/sources.list.d/' -name "*.list" -type f -exec bash -c 'undo_rewrite "$0"' {} \;

# If debian.sources exists, restore original entries
if test -f "/etc/apt/sources.list.d/debian.sources"; then
  # Remove any added lines from sources.list
  grep -v "deb $mirror" /etc/apt/sources.list > /tmp/temp_sources.list
  grep -v "deb-src $mirror" /tmp/temp_sources.list > /etc/apt/sources.list
  rm /tmp/temp_sources.list
fi

echo "Reverted mirror changes in sources.list and sources.list.d."