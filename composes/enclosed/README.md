# Enclosed
[Enclosed](https://github.com/CorentinTh/enclosed) is a minimalistic web app desinged for sending private and secure notes.

## Setup
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `AUTHENTICATION_JWT_SECRET`: change the token
- `NOTES_MAX_ENCRYPTED_PAYLOAD_LENGTH`: the maximum size for file upload, in B. Here it is set to 25MiB.

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| enclosed   | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: enclosed.domain.tld
Scheme: http
Forward Hostname / IP: enclosed
Forward Port: 8787
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```


