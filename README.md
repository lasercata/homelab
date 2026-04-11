# Server configuration
This repository contains the description for the infrastructure on my servers (with documentation).

I mainly use docker-compose to deploy services.

Below is a description on how to start from scratch your homelab.

This repository contains submodules. Clone with `--recursive`.

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

### Make it home
#### Update
On Debian:
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
git clone --recursive https://codeberg.org/lasercata/homelab.git docker
```

And create the missing folders:
```
mkdir docker/volumes docker/logs
```

### Install and run a service
Go to `composes/[service-name]/README.md` for details on how to setup `[service-name]`.

Start with `nginx-proxy-manager`.


## Setup email
For details on how to setup an e-mail server using `docker-mailserver`, please look at [`composes/mailserver/README.md`](composes/mailserver/README.md).

## Backups
### Data to backup
- `/srv/docker/volumes/`: the services' data ;
- `/srv/docker/composes/**/.env`: the private environment variables ;
- `/home/admin/.ssh`: the SSH keys
- `/home/admin/`: optional. The configuration of the admin user.

Note: when creating the backup, the corresponding volume should be down to ensure the data integrity.

### Setup
If you have multiple servers and want to use [backup upload server](https://git.lasercata.com/lasercata/backup_upload_server), then you can setup the file `scripts/.backup_secrets.sh`.

If the file is not created, then the backup script will not attempt anything.

Otherwise, set the URL and the token, and the tar will be sent there.

To create it:
```
cp scripts/.backup_secrets.example.sh scripts/.backup_secrets.sh
```

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

# Or, with discorder:
# 30 3 * * * cd /srv/docker && ./backup.sh 2>&1 | discorder "backup_cron" "# Backup $(date +'%Y-%m-%d')"

# And to see the size:
# 0  6  *  *  *  cd /srv/docker/backups; nl=$'\n'; discorder "backup_cron" "## Backups size ${nl} \`\`\`$(du -hs *)\`\`\`"
# 2   0  6  *  *  *  cd /srv/docker/backups_uploaded; nl=$'\n'; discorder "backup_cron" "## Backups uploaded size ${nl} \`\`\`$(du -hs *)\`\`\`"
```

## Blacklist
For details on the IP blacklist script, please look at [`scripts/blacklist/README.md`](scripts/blacklist/README.md).

## Discord notification (crontab)
For details on the discorder script, please look at [`scripts/discorder/README.md`](scripts/discorder/README.md).

This script is used by the others to send a notification when they are successful.

