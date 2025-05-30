# HTTPS and Caddy

!!! note
    From Seafile Docker 12.0, HTTPS will be handled by the [***Caddy***](https://caddyserver.com/docs/). The default caddy image used of Seafile docker is [`lucaslorentz/caddy-docker-proxy:2.9-alpine`](https://github.com/lucaslorentz/caddy-docker-proxy).

Caddy is a modern open source web server that mainly binds external traffic and internal services in [seafile docker](./overview.md). In addition to the advantages of traditional proxy components (e.g., *nginx*), Caddy also makes it easier for users to complete the acquisition and update of HTTPS certificates by providing simpler configurations. 

## Engage HTTPS by caddy

We provide two options for enabling HTTPS via *Caddy*, which mainly rely on The caddy docker proxy container from [Lucaslorentz](https://github.com/lucaslorentz/caddy-docker-proxy) supports dynamic configuration with labels:

- With a automatically generated certificate
- Using a custom (existing) certificate

### With a automatically generated certificate

To engage HTTPS, users only needs to correctly configure the following fields in `.env`:

```shell
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=example.com
```

### Using a custom (existing) certificate

With the `caddy.yml`, a default volume-mount is created: `/opt/seafile-caddy` (as you can change it by modifying `SEAFILE_CADDY_VOLUME` in `.env`). By convention you should provide your certificate & key files in the container host filesystem under `/opt/seafile-caddy/certs/` to make it available to caddy:

```sh
/opt/seafile-caddy/certs/
├── cert.pem  # xxx.crt in some case
├── key.pem # xxx.key in some case
```

!!! tip "Command to generate custom certificates"
    With this command, you can generate your own custom certificates:

    ```sh
    cd /opt/seafile-caddy/certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./key.pem -out ./cert.pem
    ```

    **Please be aware that custom certicates can not be used for ip-adresses**

Then modify `seafile-server.yml` to enable your custom certificate, by the way, we strongly recommend you to make a backup of `seafile-server.yml` before doing this:

```sh
cp seafile-server.yml seafile-server.yml.bak
nano seafile-server.yml
```

and

```yml
services:
  ...
  seafile:
    ...
    volumes:
      ...
      # If you use a self-generated certificate, please add it to the Seafile server trusted directory (i.e. remove the comment symbol below)
      # - "/opt/seafile-caddy/certs/cert.pem:/usr/local/share/ca-certificates/cert.crt"
    labels:
      caddy: ${SEAFILE_SERVER_HOSTNAME:?Variable is not set or empty} # leave this variables only
      caddy.tls: "/data/caddy/certs/cert.pem /data/caddy/certs/key.pem"
      ...
```

!!! warning "DNS resolution must work inside the container"

    If you're using a ***non-public url*** like `my-custom-setup.local`, you have to make sure, that the docker container can resolve this DNS query. If you don't run your own DNS servers, you have to add extras_hosts to your `.yml` file.

## Modify `seahub_settings.py` and restart the server

If you enabled HTTPS during initial deployment, you can skip this section (the HTTPS will take effect with the first time startup).

1. Modify `seahub_settings.py` and change all `http://seafile.example.com` to `https://seafile.example.com`.
2. Restart the server:

```sh
docker compose down && docker compose up -d
```
