#!/bin/bash

# Function to generate a self-signed SSL certificate
generate_self_signed_cert() {
  echo "Generating self-signed SSL certificate for domain: $1"
  
  # Create directories for storing SSL certificates
  mkdir -p /etc/ssl/$1
  cd /etc/ssl/$1
  
  # Generate a private key
  openssl genpkey -algorithm RSA -out $1.key
  
  # Generate a self-signed certificate
  openssl req -new -x509 -key $1.key -out $1.crt -days 365 -subj "/CN=$1"
  
  echo "Self-signed SSL certificate generated:"
  echo "Private Key: /etc/ssl/$1/$1.key"
  echo "Certificate: /etc/ssl/$1/$1.crt"
}

# Function to request a Let's Encrypt SSL certificate using Certbot
request_lets_encrypt_cert() {
  echo "Requesting Let's Encrypt SSL certificate for domain: $1"
  
  # Ensure certbot is installed
  if ! command -v certbot &> /dev/null
  then
    echo "Certbot could not be found. Installing..."
    apt update && apt install -y certbot
  fi
  
  # Request Let's Encrypt certificate (using standalone mode for simplicity)
  certbot certonly --standalone -d $1 --non-interactive --agree-tos --email your-email@example.com
  
  # Get the paths for the certificate and private key
  CERT_PATH="/etc/letsencrypt/live/$1/fullchain.pem"
  KEY_PATH="/etc/letsencrypt/live/$1/privkey.pem"
  
  echo "Let's Encrypt SSL certificate generated:"
  echo "Private Key: $KEY_PATH"
  echo "Certificate: $CERT_PATH"
}

# Main script logic
echo "Welcome to the SSL certificate generation script!"
echo "Please select the type of SSL certificate:"
echo "1. Self-signed certificate"
echo "2. Let's Encrypt certificate"

read -p "Enter your choice (1 or 2): " choice
read -p "Enter the domain name: " domain

if [ "$choice" -eq 1 ]; then
  generate_self_signed_cert "$domain"
elif [ "$choice" -eq 2 ]; then
  request_lets_encrypt_cert "$domain"
else
  echo "Invalid choice. Exiting."
  exit 1
fi
