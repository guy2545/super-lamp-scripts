#!/bin/bash

# Join Linux VM to cathairlabs.com Domain and Configure Access

echo "=== Active Directory Domain Join Script ==="

# Prompt for domain admin credentials
read -rp "Enter Domain Name [default: cathairlabs.com]: " DOMAIN_NAME
DOMAIN_NAME=${DOMAIN_NAME:-cathairlabs.com}

read -rp "Enter Domain Admin Username [default: administrator]: " DOMAIN_ADMIN_USER
DOMAIN_ADMIN_USER=${DOMAIN_ADMIN_USER:-administrator}

read -s -rp "Enter Domain Admin Password: " DOMAIN_ADMIN_PASSWORD
echo

AD_SUDO_GROUP="AD\\ SRV-SUDO"

# Install required packages
sudo apt update && sudo apt install -y \
  realmd sssd sssd-tools libnss-sss libpam-sss \
  adcli samba-common-bin oddjob oddjob-mkhomedir \
  packagekit krb5-user

# Discover the domain
sudo realm discover "$DOMAIN_NAME"

# Join the domain
echo "$DOMAIN_ADMIN_PASSWORD" | sudo realm join --user="$DOMAIN_ADMIN_USER" "$DOMAIN_NAME"

# Configure SSSD for UID/GID mapping
sudo bash -c 'cat <<EOF >> /etc/sssd/sssd.conf
ldap_id_mapping = False
ldap_user_uid_number = uidNumber
ldap_user_gid_number = gidNumber
EOF'

sudo chmod 600 /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf

# Restart SSSD service
sudo systemctl restart sssd

# Configure sudo access for AD group
echo "%$AD_SUDO_GROUP ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/ad_sudo > /dev/null
sudo chmod 0440 /etc/sudoers.d/ad_sudo

# Enable home directory creation on login
sudo pam-auth-update --enable mkhomedir

echo "=== Domain join and configuration complete! ==="
