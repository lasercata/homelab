# Server configuration

## Register
Register a domain name and buy a server / VPS.

## Domain name (DNS)
Go to the *manage domain* in your provider website.

Add a line
| Sub-domain | TTL  | Type | Value        |
| ---------- | ---- | ---- | ------------ |
| @          | 3600 | A    | [Server IP]  |

## Secure your server: SSH, add user
Connect to your server (via SSH).

### User creation
- Set a password for the root user (`passwd`).
- Create a new user (`useradd admin`), and set a password (`passwd admin`)
- Add it to the sudoers (`usermod -aG sudo admin`)

### SSH
#### Server side
Do the following (edit `/etc/ssh/sshd_config`):
- use key-based authentication (add your public key to `~/.ssh/authorized_keys`) ;
- disable password authentication ;
- disable root login
- change to port to a random one (in [2^10 ; 2^16]) ;

Then reload the daemon:
```
systemctl restart sshd
```

#### Client (admin) side
For convenience, edit (on your local machine) the file `~/.ssh/config` and add:
```
Host [domain.tld]
    IdentityFile [path/to/your/ssh/key]
    Port [your SSH port]
    User [the user you created]
```

## Firewall
Enable it.
Drop all by default.

Add rule:
| Protocol | Source IP | Source port | Destination IP | Destination port |
| -------- | --------- | ----------- | -------------- | ---------------- |
| TCP      | any       | any         | [Server IP]    | [SSH port]       |
|          |           |             |                |                  |

## Make it home
### Update
On debian:
```
sudo apt update && sudo apt upgrade
```

### Install packages
- tmux
- neovim
- git
- lf
- btop
- fastfetch
- batcat

### Clone dotfiles
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

<!-- To create it and set the permissions: -->
<!-- ``` -->
<!-- sudo mkdir -p /srv/docker/composes -->
<!-- sudo mkdir /srv/docker/volumes -->
<!-- sudo mkdir /srv/docker/logs -->
<!---->
<!-- sudo chown -hR admin:admin /srv/docker -->
<!-- ``` -->

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
- `NOTES_MAX_ENCRYPTED_PAYLOAD_LENGTH`: the maximum size for file upload, in B. Here it is set to 256MiB.

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

