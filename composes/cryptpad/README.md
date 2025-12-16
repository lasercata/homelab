# Cryptpad
[Cryptpad](https://cryptpad.org/) is a self-hostable collaborative office suite (and drive), end-to-end encrypted, and open-source.

## Setup
In the domain manager, add two lines:

| Sub-domain       | TTL  | Type  | Value                |
| ---------------- | ---- | ----- | -------------------- |
| cryptpad         | 3600 | A     | [Server IP]          |
| sandbox.cryptpad | 3600 | CNAME | cryptpad.domain.tld. |

In the nginx proxy manager, add a *proxy host*:
```
Domain name: cryptpad.domain.tld, sandbox.cryptpad.domain.tld
Scheme: http
Forward Hostname / IP: cryptpad
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
WebSockets Support: enable
```

And add a custom location for WebSockets:
```
Location: /cryptpad_websocket
Scheme: http
Forward Hostname / IP: cryptpad
Forward Port: 3003
WebSockets Support: enable
```

Then launch the docker:
```
docker compose up -d
```


