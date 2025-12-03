#!/usr/bin/env bash

# ====== Init ======
domain="lasercata.com"
backups_pull_folder="backups_pull/"

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

    cd -
}

# ====== Run ======
[[ -d "$backups_pull_folder" ]] || mkdir "$backups_pull_folder"

echo "------ Syncing from server (rsync) ------"
rsync -rvhP "$domain":/srv/docker/backups/ "$backups_pull_folder"

echo "------ Deleting old backups (keep last 5) ------"
delete_firsts "$backups_pull_folder" '15'
