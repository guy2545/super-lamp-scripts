#!/bin/bash

NFS_SERVER="storagepool"

# Check if the drive is already mounted
if mountpoint -q /mnt/media; then
  echo "/mnt/media is already mounted."
else
  # Install nfs-common
  sudo apt-get update
  sudo apt-get install -y nfs-common
  
  #Let apt finish
  sleep 30
  
  # Create media mount point
  sudo mkdir -p /mnt/media
  sudo chmod 755 /mnt/media

  # Add NFS entry to fstab
  sudo sh -c "echo '${NFS_SERVER}:/mnt/blackhole/media /mnt/media nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0' >> /etc/fstab"

  # Mount NFS share
  sudo mount -a
fi

# Ensure media group exists
if ! [[ $(getent group media) ]]; then
  sudo groupadd -g 1001 media
fi

# Ensure home_dirs group exists
if ! [[ $(getent group home_dirs) ]]; then
  sudo groupadd -g 3000 home_dirs
fi

# Ensure plex group exists (optional, commented out)
if ! [[ $(getent group plex) ]]; then
  sudo groupadd -g 4000 plex
fi

# Ensure stephen user exists
if ! [[ $(getent passwd stephen) ]]; then
  sudo useradd -m -G home_dirs,media,plex -u 1000 stephen
fi

# Ensure radarr user exists
if ! [[ $(getent passwd radarr) ]]; then
  sudo useradd -m -G media -u 1005 radarr
fi

# Ensure sonarr user exists
if ! [[ $(getent passwd sonarr) ]]; then
  sudo useradd -m -G media -u 1004 sonarr
fi

# Ensure plex user exists (optional, commented out)
if ! [[ $(getent passwd plex) ]]; then
   sudo useradd -m -G media -u 1001 plex
fi

# Ensure sabnzbd user exists
if ! [[ $(getent passwd sabnzbd) ]]; then
  sudo useradd -m -G media -u 1003 sabnzbd
fi