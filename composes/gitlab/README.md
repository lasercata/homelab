# Gitlab

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| gitlab     | 3600 | A    | [Server IP]  |


Create a `.env` file, with the following content:
```
DOMAIN=<domain.tld>
```

In the nginx proxy manager, add a *proxy host*:
```
Domain name: gitlab.domain.tld
Scheme: http
Forward Hostname / IP: gitlab
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

And wait (2-5 minutes, or more) that the instance launches (you get a 502 during this time).
For a more lightweight service, use `Forgejo` for example.

