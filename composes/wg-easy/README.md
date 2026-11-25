# Wireguard

Creates a vpn to host using [wg-easy](https://wg-easy.github.io/wg-easy/latest/) (with a web-based admin UI).

## Setup
Run the container:
```
docker compose up -d
```

### VPN
On your firewall, open the port `51820`.

### Web UI
You can add a proxy host to the web UI:
```
Domain name: [your local ip, e.g 192.168.1.1]
Scheme: http
Forward Hostname / IP: wg-easy
Forward Port: 51821
```
