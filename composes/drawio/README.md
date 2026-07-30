# Draw.io
[Draw.io](https://github.com/jgraph/drawio) is a diagramming and whiteboarding application

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| drawio     | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: drawio.domain.tld
Scheme: http
Forward Hostname / IP: drawio
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


