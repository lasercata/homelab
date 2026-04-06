# Backup uploader server
[Backup upload server](https://github.com/lasercata/backup_upload_server) is simple server to upload files (in this case, backups)

## Setup
Note that there is a `docker-compose.yaml` file in the folder `backup_upload_server/`, but this one is an example, and not configured to run on this stack.

Create the `.env` from the example:
```
cp backup_upload_server/.env.example .env
```

Update the important values:
- `token`: change the token

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| backup     | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: backup.domain.tld
Scheme: http
Forward Hostname / IP: enclosed
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


