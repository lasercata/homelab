# Forgejo
[Forgejo](forgejo.org) is a self-hosted lightweight alternative to github/gitlab.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| git        | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: git.domain.tld
Scheme: http
Forward Hostname / IP: forgejo
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

To configure the instance, go to the file `/data/gitea/conf/app.ini` in the docker:
```
docker exec -it forgejo bash
```

Better: edit the file directly from the mounted volume, at `/srv/docker/volumes/forgejo/gitea/conf/app.ini`.
And then relaunch the instance.


## Configuration
The configuration file is located at `/srv/docker/volumes/forgejo/gitea/conf/app.ini` (or `/data/gitea/conf/app.ini` inside the container).

**It contains sensible data**, including the SMTP configuration.

## Umami stats
To add umami stats for the forgejo instance, it is possible to use the proxy serving it.

For example, with nginx-proxy-manager, go to the settings of the proxy, host, click on the gear (top right below the closing cross of settings popup), and add the following:
```nginx
location / {
    sub_filter '</head>' '<script defer src="https://umami.domain.tld/script.js" data-website-id="WEBSITE_ID"></script></head>';
    sub_filter_once on;
    # Ensure proxy_pass is set in the main NPM interface or here if overriding completely
    proxy_pass http://forgejo:3000;
    proxy_set_header Host $host;
}
```

Be sure to change:
- `umami.domain.tld`
- `WEBSITE_ID`
- `http://forgejo:3000` to the same data from the same forward hostname and port as above

To also enable heatmap:
```nginx
location / {
    sub_filter '</head>' '<script defer src="https://umami.domain.tld/script.js" data-website-id="WEBSITE_ID"></script><script defer src="https://umami.domain.tld/recorder.js" data-website-id="WEBSITE_ID"></script></head>';
    sub_filter_once on;
    # Ensure proxy_pass is set in the main NPM interface or here if overriding completely
    proxy_pass http://forgejo:3000;
    proxy_set_header Host $host;
}

# Allow your umami instance to load forgejo in an iframe to display the heatmap result
proxy_hide_header X-Frame-Options;
proxy_hide_header Content-Security-Policy;

add_header Content-Security-Policy "frame-ancestors 'self' https://umami.domain.tld" always;
add_header X-Frame-Options "SAMEORIGIN" always;
```
