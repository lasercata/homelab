#!/usr/bin/env bash

# This script creates a tar archive of the following paths:
# - ./volumes/          backups/self/[date]_volumes.tar.gz
# - ./composes/**/.env  backups/self/[date]_env.tar.gz
# - /home/admin/        backups/self/[date]_home.tar.gz
#
# The 3 tar files are then put together in a tar file.
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

BACKUP_FOLDER="backups/self"

[[ -d "$BACKUP_FOLDER" ]] || mkdir -p "$BACKUP_FOLDER"
[[ -d "$BACKUP_FOLDER"/tmp/ ]] || mkdir "$BACKUP_FOLDER"/tmp/

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
        echo "Deleting $(ls | head -n 1) ..."
        rm $(ls | head -n 1)
        nb_files=$(ls | wc -l)
    done

    echo "(delete_firsts): cd back to"
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
    echo "--------------------------- Archiving ./volumes (you might need to enter sudo password)"
    sudo tar -czf "$BACKUP_FOLDER"/tmp/"$date_prefix"_volumes.tar.gz volumes/

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

    tar -czf "$BACKUP_FOLDER"/tmp/"$date_prefix"_env.tar.gz composes/**/.env
}

# ------ /home/admin ------
backup_home() {
    echo
    echo "====== /home/admin ======"
    echo

    tar -czf "$BACKUP_FOLDER"/tmp/"$date_prefix"_home.tar.gz /home/admin
}

# ====== Main ======
# ------ Backup all ------ 
backup_env
backup_home
backup_volumes

# Aggregate all tar in a single one
tar -cf "$BACKUP_FOLDER"/"$date_prefix"_backup_all.tar "$BACKUP_FOLDER"/tmp/"$date_prefix"*.tar.gz
rm "$BACKUP_FOLDER"/tmp/"$date_prefix"*.tar.gz
rm -d "$BACKUP_FOLDER"/tmp/

# ------ Keep only last 5 backups (remove all the previous ones) ------ 
echo "------ Deleting old backups (if applicable, keep last 5) ------"
delete_firsts "$BACKUP_FOLDER"/ '5'

# ------ Send backups to homelab ------ 
if [ -f "scripts/.backup_secrets.sh" ]; then
    source scripts/.backup_secrets.sh

    echo "Pushing backups to $BACKUP_URL"

    curl \
        -X POST \
        -H "Authorization: $BACKUP_TOKEN" \
        -F "file=@$BACKUP_FOLDER/"$date_prefix"_backup_all.tar" \
        $BACKUP_URL
fi

