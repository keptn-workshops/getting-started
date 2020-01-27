#!/usr/bin/env bash

set -euo pipefail

echo "SHELLINABOX - Start Installation"

echo "SHELLINABOX - Readying entropy..."
touch ~/.rnd
systemctl enable --now haveged

echo "SHELLINABOX - Generating certifactes..."
openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -keyout /etc/ssl/private/bastion-selfsigned.key \
    -out /etc/ssl/certs/bastion-selfsigned.cert

echo "SHELLINABOX - Generating Diffie-Hellman parameters..."
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo "SHELLINABOX - Enabling Apache2 modules and configs..."
modules=(
  ssl
  headers
  rewrite
  proxy
  proxy_http
  proxy_balancer
  lbmethod_byrequests
)

for mod in ${modules[@]}; do
  a2enmod ${mod}
done

a2ensite default-ssl
a2enconf ssl-params

echo "SHELLINABOX - Restarting services..."
systemctl enable apache2 shellinabox
systemctl reload-or-restart apache2 shellinabox 

echo "SHELLINABOX - Installation Complete"
