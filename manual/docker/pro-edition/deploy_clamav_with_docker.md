# Deploy Clamav with Docker

## Add Clamav to docker-compose.yml

The following section needs to be added to docker-compose.yml in the services section

```yml
services:
  ...

  av:
    image: mkodockx/docker-clamav:alpine
    container_name: seafile-clamav
    networks:
      - seafile-net
```

## Modify seafile.conf

Add this to seafile.conf

```conf
[virus_scan]
scan_command = clamdscan
virus_code = 1
nonvirus_code = 0
scan_interval = 5
scan_size_limit = 20
threads = 2
```

## Restart docker container

```shell
docker compose down
docker compose up -d 
```

Wait some minutes until Clamav finished initializing.

Now Clamav can be used.
