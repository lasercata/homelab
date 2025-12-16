# Forgejo
[Forgejo](forgejo.org) is a self-hosted lightweight alternative to github/gitlab.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| git        | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: git.domain.tld
Scheme: http
Forward Hostname / IP: gitlab
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

To configure the instance, go to the file `/data/gitea/conf/app.ini` in the docker:
```
docker exec -it forgejo bash
```

Better: edit the file directly from the mounted volume, at `/srv/docker/volumes/forgejo/gitea/conf/app.ini`.
And then relaunch the instance.


