# Office Documents Preview with LibreOffice

> This is a deprecated feature since version 11. Integrating with CollaboraOnline or OnlyOffice is recommended.

Seafile Professional Server supports previewing office documents online by converting them to PDF. You can follow these steps to use the feature. If you'd like to edit office files online, you can integrate Seafile with Microsoft Office Online server, CollaboraOnline or OnlyOffice.


## Version 7.1.x - 8.0.x

### Install Libreoffice/UNO

Libreoffice 6.2+ and Python-uno library are required to enable office files online preview.

On Ubuntu/Debian:

```bash
sudo apt-get install libreoffice libreoffice-script-provider-python
```

> For older version of Ubuntu: `sudo apt-get install libreoffice python-uno`

On Centos/RHEL, you need to first remove the default libreoffice in the distribution:

```
yum remove --setopt=clean_requirements_on_remove=0 libreoffice-* 
```

Then install version 6.4 or newer ([Installation of LibreOffice on Linux](https://wiki.documentfoundation.org/Documentation/Install/Linux#Terminal-Based_Install)).

Also, you may need to install fonts for your language, especially for Asians, otherwise the office document may not display correctly.

### Enable Office Preview

Open file `seafevents.conf`, in the `OFFICE CONVERTER` section:

```conf
[OFFICE CONVERTER]
enabled = true
host = 127.0.0.1
port = 6000
```

After modifying and saving `seafevents.conf`, restart seafile server by `./seafile.sh restart`

The office converter process will be started and listen on 127.0.0.1:6000

In `seahub_settings.py`, add the following config

```
OFFICE_CONVERTOR_ROOT = 'http://127.0.0.1:6000/'
```

Open a doc/ppt/xls file on Seahub, you should be about the previewing it in your browser.

### Other Configurable Options

Here are full list of options you can fine tune:

```conf
[OFFICE CONVERTER]

## must be "true" to enable office file online preview
enabled = true

## How many libreoffice worker processes to run concurrenlty
workers = 1

## where to store the converted office/pdf files. Deafult is /tmp/.
outputdir = /tmp/

host = 127.0.0.1
port = 6000
```

## Version 9.0.x or above

We use Docker to deploy LibreOffice as an example, so you need to install Docker on the server in advance (Docker installation is not introduced here). The office-preview service needs to be deployed on the same machine as the Seafile service.

### Prepare `docker-compose.yml`

Download and change [docker-compose.yml](./office-preview-yml/docker-compose.yml).

```
services:
  office-preview:
    image: seafileltd/office-preview:latest
    container_name: seafile-office-preview
    environment:
      - IGNORE_JWT_CHECK=true   # Usually, seafile and office-perview are deployed on the same machine and communicate through the intranet, so the jwt check can be ignored.
    ports:
      - "192.x.x.x:8089:8089"   # 192.x.x.x is the IP address of the machine
    command: bash start.sh
    volumes:
      - /opt/office-preview/shared:/shared  # the host path can be customized
```

### Start `seafile-office-preview` container

```
docker compose up -d
```

Add `/opt/office-preview/shared/office_convertor_settings.py` manually.

```
# Make sure the SECRET_KEY is the same as value in seahub_settings.py
SECRET_KEY = "o@^yktib39k+oor2_busbcxqaach_$b5zq-)4l6l39v#8ky5ta"  

WORKERS = 10                   # worker number
OUTPUT_DIR = '/shared/output'  # output folder in container
PORT = 8089                    # port in container
```

Restart `seafile-office-preview` container.
```
docker restart  seafile-office-preview
```

### Config seahub_settings.py

Add the following configuration to `seahub_settings.py`.

```
OFFICE_CONVERTOR_ROOT = 'http://192.x.x.x:8089'   # 192.x.x.x is the IP address of the machine
```

Restart seahub.
```
./seahub.sh restart
```

## FAQ about Office document preview

#### Document preview doesn't work, where to find more information?

You can check the log at logs/seafevents.log

#### My server is CentOS, and I see errors like "/usr/lib64/libreoffice/program/soffice.bin X11 error: Can't open display", how could I fix it?

This error indicates you have not installed the `libreoffice-headless` package. Install it by `"sudo yum install libreoffice-headless"`.

#### Document preview doesn't work on my Ubuntu/Debian server, what can I do?

Current office online preview works with libreoffice 4.0-4.2. If the version of libreoffice installed by `apt-get` is too old or too new, you can solve this by:

Remove the installed libreoffice:

```
sudo apt-get remove libreoffice* python-uno python3-uno
```

Download libreoffice packages from [libreoffice official site](https://downloadarchive.documentfoundation.org/libreoffice/old/)

Install the downloaded pacakges:

```
tar xf LibreOffice_4.1.6_Linux_x86-64_deb.tar.gz
cd LibreOffice_4.1.6.2_Linux_x86-64_deb
cd DEBS
sudo dpkg -i *.deb
```

Restart your seafile server and try again. It should work now.

```
./seafile.sh restart
```

#### The browser displays "document conversion failed", and in the logs I see messages like `[WARNING] failed to convert xxx to ...`, what should I do?

Sometimes the libreoffice process need to be restarted, especially if it's the first time seafile server is running on the server.

Try to kill the libreoffice process with `pkill -f soffice.bin`. Then try re-opening the preview page in the brower again. If you are deploying seafile in cluster mode, make sure memcached is working on each server.

#### The above solution does not solve my problem.

Please check whether the user you run Seafile can correctly start the libreoffice process. There may be permission problems. For example, if you use www-data user to run Seafile, make sure www-data has a home directory and can write to the home directory.
