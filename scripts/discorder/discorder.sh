#!/usr/bin/env bash

# Usage:
#   ./discorder.sh "bot username" "message content"

# Retrieve the WEBHOOK_URL variable
source .env || exit

# Posts a message to the webhook.
#
# Args:
#   - $1: bot username
#   - $2: message content
#
post_message() {
    curl -X POST \
        -F "username=$1" \
        -F "content=$2" \
        "$WEBHOOK_URL"
}

post_message "$1" "$2"
