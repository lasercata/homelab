# Piwigo
[Piwigo](https://piwigo.org) is a photo library

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the values:
- `db_user_password`: set the password

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| photo      | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: photo.domain.tld
Scheme: http
Forward Hostname / IP: translite
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


