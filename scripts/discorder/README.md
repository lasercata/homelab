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

## Make it usable
For the moment, it can only be called from the folder `scripts/discorder/`.

So run (as root) the script `make_global.sh` that creates a bash file `/bin/discorder`:
```
cd scripts/discorder/discorder.sh
sudo ./make_global.sh
```

**Make sure to be in the same folder** to run the script (e.g do *not* run `./scripts/discorder/make_global.sh`, this will not work).

## Usage
Usage:
```
discorder "bot username" "message content"
```

