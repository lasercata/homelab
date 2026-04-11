# Backup Nextcloud Calendars
Simple script to backup your nextcloud calendars.

## Setup
Create `.secrets.sh`:
```
cp .secrets.example.sh .secrets.sh
```
and edit the values.

For `USER` and `PASSWORD`, you will need to go to the *security* tab in user nextcloud settings, and create a new app password.

## Automate
Use a cron job (every four hours):
```
# mm hh   DD MM W  Program
  0  */4  *  *  *  cd /srv/docker; ./scripts/backup_nc_cal/backup_calendars.sh | discorder "backup_cal" "# Backup calendars $(date +'%Y-%m-%d %H:%M:%S')"
```
