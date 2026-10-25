#!/bin/bash
# Please do not manually call this file!
# This script is run by the docker container when it is "run"

# Stop if anything fails
set -e

# Make sure apache is not running, just in case.
service apache2 stop

# Enable ssl
if [[ -n $SSL_ENABLED ]]; then
  echo "SSL_ENABLED so enabling ssl..."
  a2enmod ssl && a2ensite apache-ssl-config
else
  # ensure ssl not running
  echo "SSL_ENABLED not found so disabling SSL..."
  a2dismod ssl || true
  a2dissite apache-ssl-config || true
fi;

/usr/bin/php /root/generate-yaml-config.php

# Start supervisord to manage all processes and run in foreground
exec /usr/bin/supervisord -n
