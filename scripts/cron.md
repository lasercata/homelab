# Cron
Here are my cronjobs

## VPS
``` cron
$ crontab -l
# mm   hh DD MM W  Program
  */10 *  *  *  *  cd /srv/projects/isde-projects-2025-N/ && docker compose down isde-ecommerce && docker compose up -d
  0    3  *  *  *  cd /srv/docker/scripts/mail_cert/ && ./renew_mail_cert.sh 2>&1 | discorder "mail_cert_renew" "Mail certificate renewer finished"
  15   3  *  *  *  discorder "disk_usage" "## Disk usage $(printf '\n ') \`\`\`$(df -h /)\`\`\`"

$ sudo crontab -l
# mm hh DD MM W  Program
  0  3  *  *  *  cd /srv/docker/scripts/blacklist/ && ./update_blacklist.sh && discorder "update_blacklist" "Blacklist update finished"
  30 3  *  *  *  cd /srv/docker/ && ./backup.sh 2>&1 | discorder "backup_cron" "# Backup $(date +'\%Y-\%m-\%d')"
  15 3  *  *  *  cd /srv/docker/volumes/; discorder "size_cron" "## Volumes size $(printf '\n ') \`\`\`$(du -hs * | sort -h)\`\`\`"
```

## Serv
``` cron
$ crontab -l
# mm hh   DD MM W  Program
  0  */4  *  *  *  cd /srv/docker; ./scripts/backup_nc_cal/backup_calendars.sh 2>&1 | discorder "backup_cal" "# Backup calendars $(date +'\%Y-\%m-\%d \%H:\%M:\%S')"
  0  6    *  *  *  cd /srv/docker/backups/self; nl=$'\n'; discorder "backup_cron" "## Backups size ${nl} \`\`\`$(du -hs *)\`\`\`"
  0  6    *  *  *  cd /srv/docker/backups/remote; nl=$'\n'; discorder "backup_cron" "## Backups uploaded size ${nl} \`\`\`$(du -hs *)\`\`\`"
  0  6    *  *  *  nl=$'\n'; discorder "disk_usage" "## Disk usage ${nl} \`\`\`$(df -h | grep -e File -e /dev/mapper)\`\`\`"

$ sudo crontab -l
# mm hh DD MM W  Program
  30 3  *  *  *  cd /srv/docker/ && ./backup.sh 2>&1 | discorder "backup_cron" "# Backup $(date +'\%Y-\%m-\%d')"
```
