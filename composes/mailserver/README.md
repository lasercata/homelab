# Setup email
I am going to use [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver) (DMS).

## DNS
| Sub-domain | TTL  | Type | Value               |
| ---------- | ---- | ---- | ------------------- |
| mail       | 3600 | A    | [Server IP]         |
| @          | 3600 | MX   | 10 mail.domain.tld. |

[SPF](#spf), [DKIM](#dkim), & [DMARC](#dmarc): see the corresponding sections.

## Server PTR
Configure the `PTR` field (reverse DNS record) to `mail.domain.tld`

## Firewall
Add the following rules to your firewall:

| Direction | Protocol | Source IP   | Source port | Destination IP | Destination port | Comment                    |
| --------- | -------- | ----------- | ----------- | -------------- | ---------------- | -------------------------- |
| Inbound   | TCP      | any         | any         | [Server IP]    | 25               | SMTP in                    |
| Inbound   | TCP      | any         | any         | [Server IP]    | 465 (587)        | SMTP submission            |
| Inbound   | TCP      | any         | any         | [Server IP]    | 143              | IMAP in                    |
| Inbound   | TCP      | any         | any         | [Server IP]    | 993              | IMAPS in                   |
| Outbound  | TCP      | [Server IP] | 25          | any            | any              | SMTP to other servs        |
| Outbound  | TCP      | [Server IP] | 465 (587)   | any            | any              | SMTP connect external mail |
<!-- | Outbound  | TCP      | [Server IP] | any         | any            | 53               | DNS queries (domain res)   | -->

Note:
Please prefer port 465 over 587, as the former provides implicit TLS.

## Configure and deploy
### 1. Edit `docker-compose.yml`
Edit the [`docker-compose.yml`](composes/mail/docker-compose.yml) file:
    - Substitue the `hostname:` value to `mail.domain.tld` (replace with your domain).

### SSL
- Create a certificate for `mail.domain.tld`:
```bash
# Requires access to port 80 from the internet, adjust your firewall if needed, and stop all services using the port 80.
docker run --rm -it \
  -v "/srv/docker/volumes/mail/certs/:/etc/letsencrypt/" \
  -v "/srv/docker/logs/mail/certs/:/var/log/letsencrypt/" \
  -p 80:80 \
  certbot/certbot certonly --standalone -d mail.<DOMAIN.TLD>
```

It asks for an email address. It is used to send notifications regarding renewals and security issues (brave AI).

- Auto renew the certificate:
Add a user cron job that runs `./renew_mail_cert.sh`:
```
$ crontab -e

# Add the line:
# 0 3 * * * cd /srv/docker && ./renew_mail_cert.sh
```

### Deploy
- Launch the image:
```
docker compose up -d
```

- Then you have two minutes to add at least one email account (after the first launch).
Run:
```
docker exec -ti <CONTAINER NAME> setup email add user@domain.tld
```

- Add a least one alias (by convention the *postmaster alias*):
```
docker exec -ti <CONTAINER NAME> setup alias add postmaster@domain.tld user@domain.tld
```

- To forward emails sent to inexistant users to admin: 
```
docker exec -ti <CONTAINER NAME> setup alias add @domain.tld admin@domain.tld
```
But this will forward all emails to the admin... (even for existing accounts)

- To list the aliases:
```
docker exec -ti <CONTAINER NAME> setup alias list
```

## SPF
Sender Policy Framework (SPF) is a simple email-validation system designed to detect email spoofing by providing a mechanism to allow receiving mail exchangers to check that incoming mail from a domain comes from a host authorized by that domain's administrators (source: Wikipedia).

Also only needed to add a DNS TXT value:

| Sub-domain    | TTL  | Type | Value            |
| ------------- | ---- | ---- | ---------------- |
| `domain.tld.` | 3600 | TXT  | `v=spf1 mx ~all` |

## DKIM
DomainKeys Identified Mail (DKIM) is an email authentication method designed to detect forged sender addresses in email (email spoofing), a technique often used in phishing and email spam (source: Wikipedia).

Generate DKIM keys:
```
docker exec -it <CONTAINER NAME> setup config dkim
```
And then restart your instance.

This should have generated a `mail.txt` file.

Then, configure the DNS accordingly:

| Sub-domain        | TTL  | Type | Value                     |
| ----------------- | ---- | ---- | ------------------------- |
| `mail._domainkey` | 3600 | TXT  | File content within (...) |

The value should look to something like `v=DKIM1; k=rsa; p=MIIBIjA.......`
For specific formatting, see [here](https://docker-mailserver.github.io/docker-mailserver/latest/config/best-practices/dkim_dmarc_spf/#web-interface)

Test it works with `dig`:
```
dig +short TXT mail._domainkey.<DOMAIN.TLD>
```

## DMARC
Enabled by default in docker-mailserver.

Only need to add a DNS TXT value:

| Sub-domain           | TTL  | Type | Value                                                                                                                                                    |
| -------------------- | ---- | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_dmarc.domain.tld.` | 3600 | TXT  | `v=DMARC1; p=none; sp=none; fo=0; adkim=r; aspf=r; pct=100; rf=afrf; ri=86400; rua=mailto:dmarc.report@example.com; ruf=mailto:dmarc.report@example.com` |

Please make sure to change the email addresses.

Info from protonmail:
> The `p=` value specifies the action to take for emails that fail DMARC. The default setting is none. This basically means even if an email fails SPF or DKIM, your server will still accept the email as usual. However, to improve your security we recommend setting this value to `p=quarantine`, which tells the receiving server to send failed emails to the spam folder.
> 
> Once you are confident that your legitimate emails are passing DMARC, you may want to set it even more aggressively to `p=reject`. This tells the receiving server to not accept failed emails. We recommend using `p=reject` if you think you are likely to be a target for email spoofing. For example, Yahoo, PayPal, and eBay use `p=reject` to prevent spammers from impersonating them.

The `sp` tag is for subdomains.
It works like the `p` tag.
By default, the subdomains inherits from the main domain's `p` tag (unless `sp` is set).

Current values: `p=quarantine, sp=reject`.

Note: nice tool to aggregate the DMARC reports: `dmarc-report-converter`.


