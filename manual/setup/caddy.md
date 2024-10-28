# HTTPS and Caddy

From Seafile 12.0, the HTTPS in deployment from Docker is handled by [***Caddy***](https://caddyserver.com/docs/). The default caddy image used of Seafile docker is [`lucaslorentz/caddy-docker-proxy:2.9`](https://github.com/lucaslorentz/caddy-docker-proxy).

Caddy is a modern open source web server that mainly binds external traffic and internal services in [seafile docker](./overview.md). In addition to the advantages of traditional proxy components (e.g., *nginx*), Caddy also makes it easier for users to complete the acquisite and update of HTTPS certificates by providing simpler configurations. 

To engage HTTPS, users only needs to correctly configure the following fields in `.env`:

```shell
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=example.com
```
