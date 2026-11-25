# FerriShare
[FerriShare](https://github.com/TobiasMarschner/ferrishare/) is a simple self-hostable filesharing application, with built-in end-to-end encryption.

## Setup
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| share      | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: share.domain.tld
Scheme: http
Forward Hostname / IP: ferrishare
Forward Port: 3000
SSL Certificate (SSL tab): request a new certificate
```

Configure the app settings (admin password, max upload size, max service storage, ...):
```
docker compose run --rm -it ferrishare --init
```

Then launch the docker:
```
docker compose up -d
```

## Umami stats
To monitor the instance via your umami service, it is possible to use the proxy serving ferrrishare.

For example, with nginx-proxy-manager, go to the settings of the proxy, host, click on the gear (top right below the closing cross), and add the following:
```nginx
location / {
    # It is critical to use data-exclude-hash="true" here to strip the fragment from the URL (because it contains the key)
    sub_filter '</head>' '<script defer src="https://umami.domain.tld/script.js" data-website-id="WEBSITE_ID" data-exclude-hash="true"></script><script defer src="https://umami.domain.tld/recorder.js" data-website-id="WEBSITE_ID" data-exclude-hash="true"></script></head>';
    sub_filter_once on;

    # Ensure proxy_pass is set in the main NPM interface or here if overriding completely
    proxy_pass http://ferrishare:3000;

    # Transmit headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;

    # Needed so sub_filter can read the HTML
    proxy_set_header Accept-Encoding "";
}

# Allow umami to load page in iframe (for heatmap)
proxy_hide_header X-Frame-Options;
proxy_hide_header Content-Security-Policy;

add_header Content-Security-Policy "frame-ancestors 'self' https://umami.domain.tld" always;
add_header X-Frame-Options "SAMEORIGIN" always;
```

It is critical to add `data-exclude-hash="true"` in order to strip the fragment from the URLs, because the secret key used to encrypt files are stored in URL fragments !

Be sure to change:
- `umami.domain.tld`
- `WEBSITE_ID`
- `http://ferrishare:3000` to the URL to the docker hostname (forward hostname:port)
