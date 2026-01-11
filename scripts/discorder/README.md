# Discord notification (crontab)
Here is the documentation to activate discord notifications for the scripts.

Cf to `scripts/discorder/discorder.sh`.

## .env
First, create the `.env` file:
```
cd scripts/discorder/discorder.sh
cp .env.example .env
```
And set the URL of the webhook to the `WEBHOOK_URL` variable.

## Create a symlink
For convenience, create a global symbolic link:
```
sudo ln -s /absolute/path/to/scripts/discorder/discorder.sh /bin/discorder
```

## Usage
Usage:
```
discorder "bot username" "message content"
# Or
echo "message" | discorder "bot username"
# Or
echo "message" | discorder "bot username" "message title"
```

Note: the piped message is sent as a .txt attachment.

