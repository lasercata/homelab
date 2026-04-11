#!/usr/bin/env bash

# Be sure to cd to the root of the git repo to run this script (or use full path in secrets.sh)

# ====== Init ======
if [ -f ".secrets.sh" ]; then
    source .secrets.sh
elif [ -f "scripts/backup_nc_cal/.secrets.sh" ]; then
    source scripts/backup_nc_cal/.secrets.sh
else
    echo "Error: file .secrets.sh not found"
    exit
fi

date_prefix=$(date +'%Y-%m-%d_%H:%M')

[[ -d "${BACKUP_FOLDER}/${date_prefix}" ]] || mkdir -p "${BACKUP_FOLDER}/${date_prefix}"


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

# ====== Backup ======
curl \
    -u "${USER}:${PASSWORD}" \
    -X PROPFIND \
    -H "Depth: 1" \
    "${URL}/remote.php/dav/calendars/${USER}" |
    grep -oP '<d:href>\K[^<]+' |
    while read -r cal_path; do
        cal_name=$(basename $cal_path)

        if [[ "$cal_name" != "$USER" ]]; then
            echo "Downloading calendar ${cal_name}..."

            curl \
                -u "${USER}:${PASSWORD}" \
                -X GET \
                -o "${BACKUP_FOLDER}/${date_prefix}/${cal_name}" \
                "${URL}${cal_path}?export" \
                2> /dev/null

            echo "Done"
        fi
    done;

echo "------ Creating the tar.gz archive... ------"
tar -czf "${BACKUP_FOLDER}/${date_prefix}_calendars.tar.gz" "${BACKUP_FOLDER}/${date_prefix}"

echo "Done, deleting folder..."
rm -r "${BACKUP_FOLDER}/${date_prefix}"

echo "Done"

# ------ Keep only last N backups (remove all the previous ones) ------ 
echo "------ Deleting old backups (if applicable, keep last $KEEP_N) ------"
delete_firsts "${BACKUP_FOLDER}/" "$KEEP_N"
