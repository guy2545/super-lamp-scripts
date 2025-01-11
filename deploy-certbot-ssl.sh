#!/bin/bash

# Variables
ACME_PROVIDER="https://orangepi.guy2545.com/acme/acme/directory"
HOSTNAMES=("$(hostname -s)") # Automatically set to the short hostname
DOMAINS=("internal.cathairlabs.com") # Add your domains here
CERTBOT_BIN="/usr/bin/certbot"
CERT_PATH="/etc/letsencrypt/live"
CERTS_DIR="/certs"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Check if PFX_PASSWORD is set
if [[ -z "$PFX_PASSWORD" ]]; then
    echo "Error: PFX_PASSWORD environment variable is not set."
    exit 1
fi

# Install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    apt update && apt install -y certbot python3-certbot python3-certbot-dns-standalone curl openssl

    echo "Installing and trusting root certificate..."
    wget --no-check-certificate https://orangepi.guy2545.com/roots.pem -O /usr/local/share/ca-certificates/orangepi.crt
    update-ca-certificates
}

# Obtain certificates
obtain_certificates() {
    echo "Obtaining certificates..."
    for HOSTNAME in "${HOSTNAMES[@]}"; do
        for DOMAIN in "${DOMAINS[@]}"; do
            FULL_DOMAIN="$HOSTNAME.$DOMAIN"
            echo "Requesting certificate for $FULL_DOMAIN"
            $CERTBOT_BIN certonly \
                --non-interactive \
                --agree-tos \
                --standalone \
                --email "admin@cathairlabs.com" \
                --server "$ACME_PROVIDER" \
                -d "$FULL_DOMAIN"

            if [[ $? -eq 0 ]]; then
                echo "Certificate obtained for $FULL_DOMAIN."
            else
                echo "Failed to obtain certificate for $FULL_DOMAIN."
            fi
        done
    done
}

# Deploy certificates to /certs and generate PFX
deploy_certificates() {
    echo "Deploying certificates to $CERTS_DIR..."
    mkdir -p "$CERTS_DIR"

    for HOSTNAME in "${HOSTNAMES[@]}"; do
        for DOMAIN in "${DOMAINS[@]}"; do
            FULL_DOMAIN="$HOSTNAME.$DOMAIN"
            DOMAIN_PATH="$CERT_PATH/$FULL_DOMAIN"
            if [[ -d "$DOMAIN_PATH" ]]; then
                echo "Copying certificates for $FULL_DOMAIN to $CERTS_DIR..."
                cp "$DOMAIN_PATH/fullchain.pem" "$CERTS_DIR/$FULL_DOMAIN-fullchain.pem"
                cp "$DOMAIN_PATH/privkey.pem" "$CERTS_DIR/$FULL_DOMAIN-privkey.pem"
                chmod 600 "$CERTS_DIR/$FULL_DOMAIN-privkey.pem"
                echo "Certificates for $FULL_DOMAIN saved to $CERTS_DIR."

                # Generate PFX file
                echo "Generating PFX file for $FULL_DOMAIN..."
                openssl pkcs12 -export \
                    -out "$CERTS_DIR/$FULL_DOMAIN.pfx" \
                    -inkey "$CERTS_DIR/$FULL_DOMAIN-privkey.pem" \
                    -in "$CERTS_DIR/$FULL_DOMAIN-fullchain.pem" \
                    -password pass:"$PFX_PASSWORD"
                echo "PFX file generated for $FULL_DOMAIN."
            else
                echo "Certificate path $DOMAIN_PATH does not exist."
            fi
        done
    done
}

# Main
echo "Starting ACME certificate deployment..."
install_dependencies
obtain_certificates
deploy_certificates
echo "Deployment complete."
