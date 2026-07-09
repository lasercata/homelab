# SSH login notification
Here is the documentation to activate notifications on SSH login

## Note
This script assumes you have `discorder` available in PATH. If not, cf to [its README](../discorder/README.md).

## Setup
Reference this script in the file `/etc/pam.d/sshd` by adding the line:
```bash
# Notification for ssh login
session optional pam_exec.so seteuid /srv/docker/scripts/ssh_notif/ssh_notif.sh
```
