# Welcome page
This is the source for the front page of my server.

## Setup
Launch it: `docker compose up -d`

In the nginx proxy manager, add a *proxy host*:
```
Domain name: domain.tld
Scheme: http
Forward Hostname / IP: welcome-page
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

## Update
To update the running web page, after new commits were added to the remote of the submodule `lasercata_website`, update first this repo:
```bash
# Pull the repo and its (nested) submodules
cd lasercata_website/
git pull --recurse-submodules
cd ../

# Commit changes
git add lasercata_website/
git commit -m "welcome-page: updated site (...)"
```

Then on the server, pull this repo with
```bash
git pull --recurse-submodules
```

And finally restart the compose and rebuild it:
```bash
docker compose up --build -d
```
