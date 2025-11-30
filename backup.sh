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
date_prefix=$(date +'%Y-%m-%d_%H:%M')

[[ -d backups/ ]] || mkdir backups/

# ====== Utils ======
# ------ delete_firsts ------
## This function aims to keep at most `n` files in the target folder.
# It remove the first files (from ls order). This is to keep only the most
# recent ones assuming they are correctly named.
#
# @param $1 - folder: the folder in which delete the `N - n` first files
# @param $2 - n: the number of files to keep
delete_firsts() {
    cd $1
    nb_files=$(ls | wc -l)
    nb_max=$2

    while [ $nb_files -gt $nb_max ]; do
        rm $(ls | head -n 1)
        nb_files=$(ls | wc -l)
    done

    cd -
}

# ====== Backup functions ======
# ------ ./volumes ------
backup_volumes() {
    echo "====== ./volumes ======"

    #---Init
    services_folders=$(ls composes/)

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
}

# ------ ./composes/**/.env ------
backup_env() {
    echo
    echo "====== ./composes/**/.env ======"
    echo

    tar -czf backups/"$date_prefix"_env.tar.gz composes/**/.env
}

# ------ /home/admin ------
backup_home() {
    echo
    echo "====== /home/admin ======"
    echo

    tar -czf backups/"$date_prefix"_home.tar.gz /home/admin
}

# ====== Main ======
# ------ Backup all ------ 
backup_env
backup_home
backup_volumes

# ------ Keep only last 3 backups (remove all the previous ones) ------ 
# Note: one backup is 3 tar files => we keep the 9 last files
delete_firsts 'backups/' '9'

