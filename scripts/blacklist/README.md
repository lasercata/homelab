# Blacklist
See the script `scripts/blacklist/update_blacklist.sh` for reference.

## Script details
### Steps
The scripts download bad IP lists from [`IPsum`](https://github.com/stamparm/ipsum/) and [`spamhaus`](https://www.spamhaus.org/).

Then it creates and populates (or flush and populate again) an `ipset` list with those IPs.

This `ipset` list is then used in `iptables` to drop all traffic from these IPs.

### Notes
- As I use docker containers, the traffic does not pass through the `INPUT`chain, but through the `DOCKER-USER` one.

- To test if an IP is in the blacklist:
```
sudo ipset test blacklist [IP]
```

- `notopng` reads the packets *before* they are dropped by `iptables`.

## Cron job
The script takes around 12 minutes to run (~ 21200 + 1500 IPs to populate; with IPsum >= 3, now it uses IPsum >= 2, so ~43000 + 1500 IPs, so probably two times longer)

To add a job to run every day at 3:00 a.m, as root:
```
$ sudo crontab -e

# Add the line:
# 0 3 * * * cd /srv/docker/scripts/blacklist/ && ./update_blacklist.sh
```

## Logs
The logs on my system are stored in the file `/var/log/kern.log`.
With the prefix in the rule, you can grep:
```
sudo grep "iptables: BLACKLIST" /var/log/kern.log | bat
```

I deactivated the logs in order to save memory.


