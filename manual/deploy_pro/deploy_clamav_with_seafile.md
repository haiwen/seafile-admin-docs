# Deploy ClamAV with Seafile

## Use Clamav with Docker based deployment

### Add Clamav to docker-compose.yml

The following section needs to be added to docker-compose.yml in the services section

```yml
services:
  ...

  av:
    image: clamav/clamav:latest
    container_name: seafile-clamav
    networks:
      - seafile-net
```

### Modify seafile.conf

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

* Test the software

```
$ curl https://www.eicar.org/download/eicar.com.txt | clamdscan -
```

The output must include:

```
stream: Eicar-Test-Signature FOUND
```

