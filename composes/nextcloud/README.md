# NextCloud
[NextCloud](https://github.com/nextcloud/docker) is a self-hostable file server, and more.

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `MYSQL_PASSWORD`: change the password
- `DATA_PATH`: the path where to store the nextcloud data (use no trailing slash)

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| cloud      | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: cloud.domain.tld
Scheme: http
Forward Hostname / IP: nextcloud
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

