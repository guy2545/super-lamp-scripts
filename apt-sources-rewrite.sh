#!/bin/bash

# My mirror location
export mirror=http://deb.guy2545.com

# Load OS release info into variables
. /etc/os-release

#Function to rewrite a single file
rewrite() {
    echo Rewriting $1
    #Debian repos
    sed -i s#http://deb.debian.org/debian#$mirror/debian#g $1
    sed -i s#http://ftp.us.debian.org/debian#$mirror/debian#g $1
    sed -i s#http://security.debian.org#$mirror/debsec#g $1
    sed -i s#http://deb.debian.org/debian-security#$mirror/debsec#g $1
    #Ubuntu repos
    sed -i s#http://us.archive.ubuntu.com/ubuntu#$mirror/ubuntu#g $1
    sed -i s#http://security.ubuntu.com/ubuntu#$mirror/ubusec#g $1
    #Kali repos
    sed -i s#http://http.kali.org/kali#$mirror/kali#g $1
    #Proxmox repos (this catches all of them)
    sed -i s#http://download.proxmox.com/debian#$mirror/proxmox#g $1
    #Caddy server
    sed -i s#https://dl.cloudsmith.io/public/caddy/stable/deb/debian#$mirror/caddy#g $1
    #NodeJS from Nodesource
    sed -i s#https://deb.nodesource.com#$mirror/node#g $1
    #Authelia
    sed -i s#https://apt.authelia.com/stable/debian/debian#$mirror/authelia#g $1
    #Influxdata
    sed -i s#https://repos.influxdata.com/debian#$mirror/influx#g $1
}

#Rewrite sources.list itself
rewrite '/etc/apt/sources.list'

#Rewrite everything in sources.list.d
export -f rewrite
find '/etc/apt/sources.list.d/' -name "*.list" -type f -exec bash -c 'rewrite "$0"' {} \;

# If this system is using the 'new style' deb mirrors file (/etc/apt/sources.list.d/debian.sources)
# Replace it with equivalent sources.list entries
if test -f "/etc/apt/sources.list.d/debian.sources"; then
    echo "Rewriting /etc/apt/sources.list.d/debian.sources to sources.list format"
    echo "deb $mirror/debian $VERSION_CODENAME main contrib" >> /etc/apt/sources.list
    echo "deb-src $mirror/debian $VERSION_CODENAME main contrib" >> /etc/apt/sources.list
    echo "deb $mirror/debian $VERSION_CODENAME-updates main contrib" >> /etc/apt/sources.list
    echo "deb-src $mirror/debian $VERSION_CODENAME-updates main contrib" >> /etc/apt/sources.list
    echo "deb $mirror/debsec $VERSION_CODENAME-security main contrib" >> /etc/apt/sources.list
    echo "deb-src $mirror/debsec $VERSION_CODENAME-security main contrib" >> /etc/apt/sources.list
    rm /etc/apt/sources.list.d/debian.sources
fi
