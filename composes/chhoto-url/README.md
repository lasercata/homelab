# Chhoto-url
[Chhoto-url](https://github.com/SinTan1729/chhoto-url) is a simple self-hosted URL shortener.

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `password`: change the password

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| s          | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: s.domain.tld
Scheme: http
Forward Hostname / IP: chhoto-url
Forward Port: 4567
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


