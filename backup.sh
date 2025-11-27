#!/usr/bin/env bash

# This script creates a tar archive of the following paths:
# - ./volumes/          backups/[date]_volumes.tar
# - ./composes/**/.env  backups/[date]_env.tar
# - /home/admin/        backups/[date]_home.tar
#
# It first stops the running containers, and relaunch them (and only the ones that were running).
#
# Sudo needed to backup the `volumes/`.
#
# Notes (tar parameters):
# - Create tar archive: `tar -czvf name.tar.gz dir/` (`c`: create, `z`: compress with gz, `v`: verbose, `f`: give file name).
# - Extract archive: `tar -xzvp --same-owner -f name.tar.gz dest/` (`x`: extract, `p`: preserve permissions, `same-owner`: preserve owner)
#
# Avoid the -v (verbose) parameter as it flood the error messages.

# ====== Init ======
services_folders=$(ls composes/)
date_prefix=$(date +'%Y-%m-%d_%H:%M')

mkdir backups/

# ====== ./volumes ======
echo "====== ./volumes ======"

#---Docker compose down every service
# First save which container is running
running_services=$(docker ps --format '{{.Names}}')

# Then down each
echo
echo "Stopping the services..."
echo
cd composes/
for service in $services_folders; do
    cd "$service"

    echo "In folder '$service':"
    if [[ $running_services =~ "$service" ]]; then
        echo "stopping it"
        docker compose down
    else
        echo "is not running"
    fi

    cd ..
done
cd ..

#---Tar
sudo tar -czf backups/"$date_prefix"_volumes.tar.gz volumes/

#---Docker compose up
echo
echo "Relaunching the services..."
echo
cd composes/
for service in $services_folders; do
    cd "$service"

    echo "In folder '$service':"
    if [[ $running_services =~ "$service" ]]; then
        echo "relaunching it"
        docker compose up -d
    else
        echo "was not running"
    fi

    cd ..
done
cd ..

# ====== ./composes/**/.env ======
echo
echo "====== ./composes/**/.env ======"
echo

tar -czf backups/"$date_prefix"_env.tar.gz composes/**/.env

# ====== /home/admin ======
echo
echo "====== /home/admin ======"
echo

tar -czf backups/"$date_prefix"_home.tar.gz /home/admin
