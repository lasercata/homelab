# Invidious
[Invidious](invidious.io) is an open-source alternative front-end to youtube.

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `HMAC_KEY`: generate a password
- `INVIDIOUS_COMPANION_KEY`: generate a password

<!-- Update also the `HMAC_KEY` field in `config.yml`. -->

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| inv        | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: inv.domain.tld
Scheme: http
Forward Hostname / IP: invidious
Forward Port: 5432
SSL Certificate (SSL tab): request a new certificate
```

To restrict access:
- Create a new *access list*, add a username and a password in *Authorizations*, and in *Rules*, for *Allow* enter `all` ;
- In the proxy host, change *access list* to the corresponding access list.

Then launch the docker:
```
docker compose up -d
```


