#!/bin/bash

# Quick Post-Installation Setup Script for Debian VM
#
# !! Run this script as root !!
#
# This script will:
# 1. Ensure it's run as root.
# 2. Install the 'sudo' package.
# 3. Add the user 'guy' to the 'sudo' group (ensure 'guy' exists first!).
# 4. Update package lists (apt update).
# 5. Upgrade installed packages (apt upgrade -y).
# 6. Reboot the system.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Define the username to add to sudoers
USERNAME="guy"

echo "Starting Debian post-install setup..."

# 1. Install sudo
echo "Updating package list and installing sudo..."
# Run update first to ensure sudo package can be found
apt-get update
apt-get install -y sudo
echo "sudo installed successfully."

# 2. Add user to sudo group
echo "Adding user '$USERNAME' to the sudo group..."
# Check if user exists before attempting to add to group
if id "$USERNAME" &>/dev/null; then
    usermod -aG sudo "$USERNAME"
    echo "User '$USERNAME' added to sudo group."
else
    echo "Error: User '$USERNAME' does not exist. Cannot add to sudo group." >&2
    # Decide if this should be a fatal error. For now, we'll let the script continue.
    # You could uncomment the next line to make it stop if the user doesn't exist:
    # exit 1
fi

# 3. Update package lists again (good practice after installs/changes)
echo "Updating package lists again..."
apt-get update

# 4. Upgrade installed packages
echo "Upgrading installed packages..."
# Use DEBIAN_FRONTEND=noninteractive to avoid potential prompts during upgrade
export DEBIAN_FRONTEND=noninteractive
# The options below try to automatically handle configuration file prompts
# by keeping the currently installed version ('confold') or the package maintainer's default ('confdef')
# Adjust if you have specific needs during upgrades.
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
echo "Packages upgraded."

# Optional: Clean up downloaded package files and unused dependencies
echo "Cleaning up apt cache and unused dependencies..."
apt-get autoremove -y
apt-get clean

# 5. Reboot
echo "Setup complete. System will reboot in 5 seconds..."
sleep 5
echo "Rebooting now!"
reboot

# Exit cleanly (though reboot will likely interrupt this)
exit 0