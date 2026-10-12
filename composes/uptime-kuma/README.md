# Uptime Kuma
[Uptime Kuma](https://github.com/louislam/uptime-kuma) is an uptime page service.

## Note
Better if you have at least two distinct servers: run it on both servers, so that each monitors the other.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value         |
| ---------- | ---- | ---- | ------------- |
| uptime2    | 3600 | A    | [Server1 IP]  |
| uptime1    | 3600 | A    | [Server2 IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: uptime1.domain.tld
Scheme: http
Forward Hostname / IP: uptime-kuma
Forward Port: 3001
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

Repeat the process for server 2.

## DNS
I choose the following convention:
- `uptime.serv.[domain.tld]` points to `vps`, that monitors `serv`.
- `uptime.vps.[domain.tld]` points to `serv`, that monitors `vps`.
