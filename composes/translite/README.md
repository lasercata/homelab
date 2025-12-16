# Translite
[Translite](https://codeberg.org/gospodin/translite/) is an alternative frontend for multiple known translators.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| translate  | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: translate.domain.tld
Scheme: http
Forward Hostname / IP: translite
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


