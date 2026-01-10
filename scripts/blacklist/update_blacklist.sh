#!/usr/bin/env bash

# This scripts download various IP list from Cyber Threat Intelligence and blacklist them.
# Run this as root (sudo is used anyway)

# ====== Init ======
echo "Downloading IP lists"
IPsum_source="https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt"
# # This one removes the ones that have only 1 or 2 number of blacklists
# IPsum_IPs=$(curl --compressed "$IPsum_source" 2> /dev/null | grep -v "#" | grep -v -E "\\s[1-2]$" | cut -f 1)

# This one removes the ones that have only 1 number of blacklists
IPsum_IPs=$(curl --compressed "$IPsum_source" 2> /dev/null | grep -v "#" | grep -v -E "\\s1$" | cut -f 1)

Spamhaus_source="https://www.spamhaus.org/drop/drop.txt"
Spamhaus_IPs=$(curl --compressed "$Spamhaus_source" 2> /dev/null | cut -d ';' -f 1 | grep " ")


# ====== ipset ======
# Flush and recreate the ipset list `blacklist`
echo "Recreating the ipset list"
sudo ipset -q flush blacklist
sudo ipset -q create blacklist hash:net

# Populate the ipset list
echo "Populating the ipset list"
for ip in $IPsum_IPs $Spamhaus_IPs; do
    echo "Adding $ip ..."
    sudo ipset add blacklist $ip
done

# ====== iptables ======
# Adding the rule into iptables, into the chain 'DOCKER-USER', because
# Docker apparently creates a jump from the FORWARD to DOCKER-USER, that
# is used for all container-based traffic
echo "Adding the iptable rule (DOCKER-USER)"
! sudo iptables -C DOCKER-USER -m set --match-set blacklist src -j DROP 2>/dev/null && \
sudo iptables -I DOCKER-USER -m set --match-set blacklist src -j DROP

# echo "Adding the iptable log rule (DOCKER-USER)"
# ! sudo iptables -C DOCKER-USER -m set --match-set blacklist src -j LOG --log-prefix "iptables: BLACKLIST: docker-user" --log-level 7 2> /dev/null && \
# sudo iptables -I DOCKER-USER -m set --match-set blacklist src -j LOG --log-prefix "iptables: BLACKLIST: docker-user" --log-level 7

# Also adding the rule to INPUT (just in case)
echo "Adding the iptable rule (INPUT)"
! sudo iptables -C INPUT -m set --match-set blacklist src -j DROP 2>/dev/null && \
sudo iptables -I INPUT -m set --match-set blacklist src -j DROP

# echo "Adding the iptable log rule (INPUT)"
# ! sudo iptables -C INPUT -m set --match-set blacklist src -j LOG --log-prefix "iptables: BLACKLIST: input" --log-level 7 2> /dev/null && \
# sudo iptables -I INPUT -m set --match-set blacklist src -j LOG --log-prefix "iptables: BLACKLIST: input" --log-level 7

