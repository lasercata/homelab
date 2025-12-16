# Nginx proxy manager
[Nginx proxy manager](https://nginxproxymanager.com/) is an open-source web-based tool to manage the Nginx reverse proxy and SSL certificates.

## Setup
Create a docker network:
```
docker network create docker-network
```

Launch it: `docker compose up -d`

Allow connections to the port 81 in the firewall.
Go to `domain.tld:81`, and create an account.

Then create a new sub-domain `npm.domain.tld`.
First go into manage domain, DNS zone, and add a line:
Add a line
| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| npm        | 3600 | A    | [Server IP]  |

Then create a new *proxy host*
```
Domain name: npm.domain.tld
Scheme: http
Forward Hostname / IP: domain.tld
Forward Port: 81
SSL Certificate (SSL tab): request a new certificate
```

After this wait a bit for `npm.domain.tld` is accessible.

You can now remove the firewall rule allowing the port 81.


