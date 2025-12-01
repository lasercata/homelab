# Server configuration

## Server initialisation
### Register
Register a domain name and buy a server / VPS.

### Domain name (DNS)
Go to the *manage domain* in your provider website.

Add a line
| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| @          | 3600 | A    | [Server IP]  |

### Secure your server: SSH, add user
Connect to your server (via SSH).

#### User creation
- Set a password for the root user (`passwd`).
- Create a new user (`useradd admin`), and set a password (`passwd admin`)
- Add it to the sudoers (`usermod -aG sudo admin`)

#### SSH
##### Server side
Do the following (edit `/etc/ssh/sshd_config`):
- use key-based authentication (add your public key to `~/.ssh/authorized_keys`) ;
- disable password authentication ;
- disable root login
- change to port to a random one (in [2^10 ; 2^16]) ;

Then reload the daemon:
```
systemctl restart sshd
```

##### Client (admin) side
For convenience, edit (on your local machine) the file `~/.ssh/config` and add:
```
Host [domain.tld]
    IdentityFile [path/to/your/ssh/key]
    Port [your SSH port]
    User [the user you created]
```

### Firewall
Enable it.
Drop all by default.

Add rule:
| Direction | Protocol | Source IP | Source port | Destination IP | Destination port |
| --------- | -------- | --------- | ----------- | -------------- | ---------------- |
| Inbound   | TCP      | any       | any         | [Server IP]    | [SSH port]       |
| Inbound   |          |           |             |                |                  |

### Make it home
#### Update
On debian:
```
sudo apt update && sudo apt upgrade
```

#### Install packages
- tmux
- neovim
- git
- lf
- btop
- fastfetch
- batcat

#### Clone dotfiles
Clone `https://github.com/lasercata/minimal_dotfiles.git`, and create all the symlinks for the configuration files.

Set the default shell to bash:
```
chsh -s /bin/bash
```

## Install services
### Docker
First, install (using `apt-get`):
- `docker.io`
- `docker-compose`

Then, add the permissions to `admin`:
```
sudo usermod -aG docker admin
```

### General file structure
Here is the general file structure:
```
/
└── srv/
    └── docker/
        ├── composes/
        │   ├── service_1/
        │   ├── ...
        │   └── service_n/
        │
        ├── logs/
        │   ├── service_1/
        │   ├── ...
        │   └── service_n/
        │
        └── volumes/
            ├── service_1/
            ├── ...
            └── service_n/
```

The `composes/` folder contains the `docker-compose.yml` file (the configuration) of each service.

The `volumes/` folder contains the docker mounted volumes of the services (the data).

The `logs/` folder contains the logs of some services (currently only for a setup of emails)

### Download all config (docker)
Create the `/srv/docker/` folder and set the right owner:
```
sudo mkdir /srv/docker/
sudo chown admin:admin /srv/docker
```

And then clone this very repository into `docker`:
```
cd /srv/
git clone ssh://git@codeberg.org/lasercata/VPS.git docker
```

And create the missing folders:
```
mkdir docker/volumes docker/logs
```

### Nginx proxy manager
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

### Welcome page
Launch it: `docker compose up -d`

In the nginx proxy manager, add a *proxy host*:
```
Domain name: domain.tld
Scheme: http
Forward Hostname / IP: welcome-page
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

### Gitlab
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| gitlab     | 3600 | A    | [Server IP]  |


Create a `.env` file, with the following content:
```
DOMAIN=<domain.tld>
```

In the nginx proxy manager, add a *proxy host*:
```
Domain name: gitlab.domain.tld
Scheme: http
Forward Hostname / IP: gitlab
Forward Port: 80
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

And wait (2-5 minutes, or more) that the instance launches (you get a 502 during this time).
For a more lightweight service, use `Forgejo` for example.
### Forgejo
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| git        | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: git.domain.tld
Scheme: http
Forward Hostname / IP: gitlab
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

### Cryptpad
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

### Microbin
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `MICROBIN_PUBLIC_PATH`: set it to `https://microbin.<domain.tld>`
- `MICROBIN_ADMIN_PASSWORD`: change the admin password


In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| microbin   | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: microbin.domain.tld
Scheme: http
Forward Hostname / IP: microbin
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

Admin page: accessible at `microbin.domain.tld/admin`.

### Enclosed
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

### Chhoto-url
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `password`: change the password

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| s          | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: s.domain.tld
Scheme: http
Forward Hostname / IP: chhoto-url
Forward Port: 4567
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

### FerriShare
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

### Invidious
Create the `.env` from the example:
```
cp .env.default .env
```

Update the important values:
- `HMAC_KEY`: generate a password
- `INVIDIOUS_COMPANION_KEY`: generate a password

<!-- Update also the `HMAC_KEY` field in `config.yml`. -->

In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| inv        | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: inv.domain.tld
Scheme: http
Forward Hostname / IP: invidious
Forward Port: 5432
SSL Certificate (SSL tab): request a new certificate
```

To restrict access:
- Create a new *access list*, add a username and a password in *Authorizations*, and in *Rules*, for *Allow* enter `all` ;
- In the proxy host, change *access list* to the corresponding access list.

Then launch the docker:
```
docker compose up -d
```

### Translite
In the domain manager, add a line:

| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| translate  | 3600 | A    | [Server IP]  |


In the nginx proxy manager, add a *proxy host*:
```
Domain name: translate.domain.tld
Scheme: http
Forward Hostname / IP: translite
Forward Port: 8080
SSL Certificate (SSL tab): request a new certificate
```

Then launch the docker:
```
docker compose up -d
```

### ntop-ng
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

## Setup email
I am going to use [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver) (DMS).

### DNS
| Sub-domain | TTL  | Type | Value               |
| ---------- | ---- | ---- | ------------------- |
| mail       | 3600 | A    | [Server IP]         |
| @          | 3600 | MX   | 10 mail.domain.tld. |

DKIM, DMARC & SPF: see the corresponding sections.

### Server PTR
Configure the `PTR` field (reverse DNS record) to `mail.domain.tld`

### Firewall
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

### Configure and deploy
#### 1. Edit `docker-compose.yml`
Edit the [`docker-compose.yml`](composes/mail/docker-compose.yml) file:
    - Substitue the `hostname:` value to `mail.domain.tld` (replace with your domain).

#### SSL
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

#### Deploy
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

### DKIM
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

### DMARC
Enabled by default in docker-mailserver.

Only need to add a DNS TXT value:

| Sub-domain           | TTL  | Type | Value                                                                                                                                                    |
| -------------------- | ---- | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_dmarc.domain.tld.` | 3600 | TXT  | `v=DMARC1; p=none; sp=none; fo=0; adkim=r; aspf=r; pct=100; rf=afrf; ri=86400; rua=mailto:dmarc.report@example.com; ruf=mailto:dmarc.report@example.com` |

Please make sure to change the email addresses.

### SPF
Sender Policy Framework (SPF) is a simple email-validation system designed to detect email spoofing by providing a mechanism to allow receiving mail exchangers to check that incoming mail from a domain comes from a host authorized by that domain's administrators (source: Wikipedia).

Also only needed to add a DNS TXT value:

| Sub-domain    | TTL  | Type | Value            |
| ------------- | ---- | ---- | ---------------- |
| `domain.tld.` | 3600 | TXT  | `v=spf1 mx ~all` |

## Backups
### Data to backup
- `/srv/docker/volumes/`: the services' data ;
- `/srv/docker/composes/**/.env`: the private environment variables ;
- `/home/admin/.ssh`: the SSH keys
- `/home/admin/`: optional. The configuration of the admin user.

Note: when creating the backup, the corresponding volume should be down to ensure the data integrity.

### How to backup
#### Create the archives
To create the archives, simply run the `backup.sh` script.
It will take care of taking down the containers and relaunching them.

#### Copy the archives
From your machine, retrieve the archives using `scp`:
```bash
# Assuming you used ~/.ssh/config to setup Port, User and IdentityFile
scp domain.tld:/srv/docker/backups .
```

Or to keep a mirror of the `backups/` folder on your machine, use `rsync`:
```
# Assuming you used ~/.ssh/config to setup Port, User and IdentityFile
rsync -rvhP domain.tld:/srv/docker/backups/ backups/
```

#### Restore (when needed)
To extract content of an archive:
```
tar -xzp --same-owner -f name.tar.gz dest/
```

### Automatize (cron)
Install `cron`:
```
sudo apt install cron
```

To add a job to run every day at 3:30 a.m, as root:
```
$ sudo crontab -e

# Add the line:
# 30 3 * * * cd /srv/docker && ./backup.sh
```
