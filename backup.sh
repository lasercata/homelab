#!/usr/bin/env bash

# This script creates a tar archive of the following paths:
# - ./volumes/          backups/[date]_volumes.tar
# - ./composes/**/.env  backups/[date]_env.tar
# - /home/admin/        backups/[date]_admin.tar
#
# It first stops the running containers, and relaunch them (and only the ones that were running).
#
# Notes (tar parameters):
# - Create tar archive: `tar -czvf name.tar dir/` (`c`: create, `z`: compress?, `v`: verbose, `f`: give file name).
# - Extract archive: `tar -xvp --same-owner -f name.tar dest/` (`x`: extract, `p`: preserve permissions, `same-owner`: preserve owner)

# ====== Init ======
services_folders=$(ls composes/)
date_prefix=$(date +'%Y-%m-%d_%H:%M')

mkdir backups/

# ====== ./volumes ======
#---Docker compose down every service
# First save which container is running
running_services=$(docker ps --format '{{.Names}}')

# Then down each
echo "Stopping the services..."
cd composes/
for service in $services_folders; do
    cd "$service"
    echo "Stopping '$service'"
    docker compose down
    cd ..
done
cd ..

#---Tar
tar -czvf backups/"$date_prefix"_volumes.tar volumes/

#---Docker compose up
echo "Relaunching the services..."
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
tar -czvf backups/"$date_prefix"_env.tar composes/**/.env

# ====== /home/admin ======
tar -czvf backups/"$date_prefix"_env.tar /home/admin
