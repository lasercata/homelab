#!/usr/bin/env bash

# Usage:
#   ./discorder.sh "bot username" "message content"

# Retrieve the WEBHOOK_URL variable
FILE_PATH=$(readlink ${BASH_SOURCE} || echo ${BASH_SOURCE}) # Points to the path of the file even if run from another directory or 1 symlink
ENV_PATH=$(dirname "$FILE_PATH")
source $ENV_PATH/.env || exit

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

# Gets the arguments
bot_name="$1"
msg="$2"

# Read from stdin only if piped
if [ ! -t 0 ]; then
    read msg_pipe
else
    msg_pipe=""
fi

post_message "$bot_name" "$msg
$msg_pipe"
