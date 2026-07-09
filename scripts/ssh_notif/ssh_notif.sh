#!/usr/bin/env bash

# Configuration
SUBJECT="SSH Login Notification"

# Extract PAM environment variables
USER="$PAM_USER"
IP="$PAM_RHOST"
HOSTNAME=$(hostname)
DATE=$(date)

# Notify only on session open, not close
if [ "$PAM_TYPE" = "open_session" ]; then
    MESSAGE="SSH login detected on \`$HOSTNAME\`
    Date: **$DATE**
    User: \`$USER\`
    IP: \`$IP\`"
    discorder "$SUBJECT" "$MESSAGE"
fi

exit 0
