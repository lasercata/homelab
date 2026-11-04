# Umami
[Umami](https://github.com/umami-software) is a privacy-first web analytics platform.

## Setup
Create the `.env` from the example:
```
cp .env.example .env
```
and change the passwords.

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| umami      | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: umami.domain.tld
Scheme: http
Forward Hostname / IP: translite
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


