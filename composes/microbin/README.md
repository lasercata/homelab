# Microbin
[Microbin](https://github.com/szabodanika/microbin) is a secure configurable self-hosted file-sharing web app.

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `MICROBIN_PUBLIC_PATH`: set it to `https://microbin.<domain.tld>`
- `MICROBIN_ADMIN_PASSWORD`: change the admin password


In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| microbin   | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: microbin.domain.tld
Scheme: http
Forward Hostname / IP: microbin
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

Admin page: accessible at `microbin.domain.tld/admin`.


