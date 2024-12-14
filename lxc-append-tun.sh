#!/bin/bash

# Iterate through each LXC container configuration file
for file in /etc/pve/lxc/*.conf; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Read the contents of the file
    content=$(cat "$file")

    # Check if the lines already exist in the file
    if ! grep -q 'lxc.cgroup2.devices.allow: c 10:200 rwm' <<< "$content" && 
       ! grep -q 'lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file' <<< "$content"; then

      # Append the lines to the file
      echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> "$file"
      echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> "$file"
      echo "Appended lines to: $file"
    else
      echo "Lines already exist in: $file"
    fi
  fi
done