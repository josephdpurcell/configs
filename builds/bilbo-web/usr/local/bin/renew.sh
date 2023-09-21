#!/bin/bash

set -e
set -x

service apache2 stop || true
certbot renew --dry-run
certbot renew
service apache2 start

