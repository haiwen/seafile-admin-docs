# Deploy ClamAV with Seafile

## Deploy with Docker

If your Seafile server is deployed using [Docker](../setup/setup_pro_by_docker.md), we also recommend that you use Docker to deploy ClamAV by following the steps below, otherwise you can [deploy it from  binary package of ClamAV](#use-clamav-in-binary-based-deployment).

### Download clamav.yml and insert to Docker-compose lists in .env

Download `clamav.yml`

```sh
wget https://manual.seafile.com/13.0/repo/docker/pro/clamav.yml
```

Modify `.env`, insert `clamav.yml` to field `COMPOSE_FILE`

```sh
COMPOSE_FILE='seafile-server.yml,caddy.yml,clamav.yml'
```

### Modify seafile.conf

Add the following statements to seafile.conf

```conf
[virus_scan]
scan_command = clamdscan
virus_code = 1
nonvirus_code = 0
scan_interval = 5
scan_size_limit = 20
threads = 2
```

### Restart docker container

```shell
docker compose down
docker compose up -d 
```

Wait some minutes until Clamav finished initializing.

Now Clamav can be used.

## Use ClamAV in binary based deployment

### Install clamav-daemon & clamav-freshclam

```
apt-get install clamav-daemon clamav-freshclam
```

You should run Clamd with a root permission to scan any files. 
Edit the conf `/etc/clamav/clamd.conf`,change the following line:

```
LocalSocketGroup root
User root
```

### Start the clamav-daemon

```
systemctl start clamav-daemon
```

!!! success "Test the software"

    ```
    $ curl https://secure.eicar.org/eicar.com.txt | clamdscan -
    ```

    The output must include:

    ```
    stream: Eicar-Test-Signature FOUND
    ```

