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
#   - $3: (optional) path to the file to attach (or "")
post_message() {
    if [ -z "$3" ]; then
        curl -X POST \
            -F "username=$1" \
            -F "content=$2" \
            "$WEBHOOK_URL"
    else
        curl -X POST \
            -F "username=$1" \
            -F "content=$2" \
            -F "file1=@$3" \
            "$WEBHOOK_URL"
    fi
}

# Gets the arguments
bot_name="$1"
msg="$2"

# Read from stdin only if piped
if [ ! -t 0 ]; then
    # Read the piped data
    msg_pipe=$(cat)

    # Save it to tmp file
    cat <<< "$msg_pipe" > /tmp/discorder.txt

    # post message
    post_message "$bot_name" "$msg" "/tmp/discorder.txt"

    # Delete tmp file
    rm /tmp/discorder.txt

else
    post_message "$bot_name" "$msg"
fi
