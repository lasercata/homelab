# ntop-ng
[ntop-ng](https://www.ntop.org/products/traffic-analysis/ntopng/) is a web-based traffic analysis and flow collection.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| ntop       | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: ntop.domain.tld
Scheme: http
Forward Hostname / IP: 172.21.0.1
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Note: to get the IP (here `172.21.0.1`), run
```
docker network inspect docker-network | bat
```
and look for the `Gateway`.

This is because `ntop-ng` runs in the host network (`network_type: host`) in order to see all the connections to the machine, and the nginx proxy manager runs in the docker network `docker-network` (as all the other services, apart email) in order to isolate it from the host network.

Then launch the docker:
```
docker compose up -d
```

Note: The default username/password are `admin/admin`, and the web interface will ask to change after first login.


