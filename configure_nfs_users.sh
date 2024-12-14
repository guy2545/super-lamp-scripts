#!/bin/bash

# Install nfs-common
sudo apt-get update
sudo apt-get install -y nfs-common

# Create media mount point
sudo mkdir -p /mnt/media
sudo chmod 755 /mnt/media

# Add NFS entry to fstab
sudo sh -c "echo 'storagepool:/mnt/blackhole/media /mnt/media nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0' >> /etc/fstab"

# Mount NFS share
sudo mount -a

# Ensure media group exists
sudo groupadd -g 1001 media

# Ensure home_dirs group exists
sudo groupadd -g 3000 home_dirs

# Ensure plex group exists
sudo groupadd -g 4000 plex

# Ensure stephen user exists
sudo useradd -m -G home_dirs,media,plex -u 1000 stephen

# Ensure radarr user exists
sudo useradd -m -G media -u 1005 radarr

# Ensure sonarr user exists
sudo useradd -m -G media -u 1004 sonarr

# Ensure plex user exists
sudo useradd -m -G media -u 1001 plex

# Ensure sabnzbd user exists
sudo useradd -m -G media -u 1003 sabnzbd