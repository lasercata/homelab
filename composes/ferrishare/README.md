# FerriShare
[FerriShare](https://github.com/TobiasMarschner/ferrishare/) is a simple self-hostable filesharing application, with built-in end-to-end encryption.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| share      | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: share.domain.tld
Scheme: http
Forward Hostname / IP: ferrishare
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Configure the app settings (admin password, max upload size, max service storage, ...):
```
docker compose run --rm -it ferrishare --init
```

Then launch the docker:
```
docker compose up -d
```


