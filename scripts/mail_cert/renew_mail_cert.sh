#!/usr/bin/env bash

# ====== Stop containers using port 443 ======
cd /srv/docker/composes/nginx-proxy-manager/
docker compose stop


# ====== Renew cert if needed ======
docker run --rm -it \
  -v "/srv/docker/volumes/mail/certs/:/etc/letsencrypt/" \
  -v "/srv/docker/logs/mail/certs/:/var/log/letsencrypt/" \
  -p 80:80 \
  -p 443:443 \
  certbot/certbot renew

# ====== Restart containers using port 443 ======
docker compose start
