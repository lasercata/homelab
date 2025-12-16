# Welcome page
This is the source for the front page of my server.

## Setup
Launch it: `docker compose up -d`

In the nginx proxy manager, add a *proxy host*:
```
Domain name: domain.tld
Scheme: http
Forward Hostname / IP: welcome-page
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```


