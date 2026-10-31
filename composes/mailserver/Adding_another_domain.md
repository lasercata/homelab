# Adding a second domain
This documents how to add another domain to an existing docker-mailserver service.

## Notations
Main domain: `domain.tld`
Second domain: `second.tld`

## DNS
In the main domain, add to the dns zone:
| Sub-domain                | TTL  | Type | Value     |
| ------------------------- | ---- | ---- | --------- |
| second.tld._report._dmarc | 3600 | TXT  | v=DMARC1; |

This is to accept the email dmarc reports from the main domain email (see dmarc config below, with the main domain admin email address)

In the second domain, add to the dns zone:
| Sub-domain         | TTL  | Type | Value               |
| ------------------ | ---- | ---- | ------------------- |
| mail               | 3600 | A    | [Server IP]         |
| mail               | 3600 | AAAA | [Server IPv6]       |
| @                  | 3600 | MX   | 10 mail.domain.tld. |
| @                  | 3600 | TXT  | v=spf1 mx ~all      |
| mail._domainkey    | 3600 | TXT  | v=DKIM1; h=sha256; k=rsa; p=.... |
| _dmarc.second.tld. | 3600 | TXT  | v=DMARC1; ... [1]   |

[1]: `v=DMARC1; p=quarantine; sp=reject; fo=0; adkim=r; aspf=r; pct=100; rf=afrf; ri=86400; rua=mailto:admin@domain.tld; ruf=mailto:admin@domain.tld`

Note: you will be able to add the DKIM line only after the generation of the key (see below)

## Certificate
The TLS certificate is for the server FQDN, it is not for all domains. The only certificate needed is for `mail.domain.tld`.

## Create an account
```
docker exec -it <CONTAINER NAME> setup email add admin@second.tld
```

## Generate DKIM keys
Generate DKIM keys:
```
docker exec -it <CONTAINER NAME> setup config dkim
```
And then restart your instance.

This should have generated a `mail.txt` file for the new domain.
Location: `/srv/docker/volumes/mail/docker-data/dms/config/opendkim/keys/<second.tld>/mail.txt`.
