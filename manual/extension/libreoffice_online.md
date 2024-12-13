# Integrate Seafile with Collabora Online (LibreOffice Online)

## Setup CollaboraOnline

!!! tip "Deployment Tips"

    The steps from this guide only cover installing collabora as another container on the same docker host that your seafile docker container is on. **Please make sure your host have sufficient cores and RAM**. 
    
    If you want to install on another host please refer the collabora documentation for [instructions](https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html#code-docker-image). Then you should follow [here](#Libreoffice-server-on-a-separate-host) to configure `seahub_settings.py` to enable online office.

!!! note
    To integrate *LibreOffice* with Seafile, you have to enable **HTTPS** in your Seafile server:

    === "Deploy in Docker"
        
        Modify `.env` file:

        ```sh
        SEAFILE_SERVER_PROTOCOL=https
        ```
    
    === "Deploy from binary packages"

        Please follow the links to enable https:

        - [Nginx](../setup_binary/https_with_nginx.md)
        - [Apache](../setup_binary/https_with_apache.md)

Download the `collabora.yml`

```sh
wget https://manual.seafile.com/12.0/docker/collabora.yml
```

Insert `collabora.yml` to field `COMPOSE_FILE` lists (i.e., `COMPOSE_FILE='...,collabora.yml'`) and add the relative options in `.env`

```sh

COLLABORA_IMAGE=collabora/code:24.04.5.1.1 # image of LibreOffice
COLLABORA_PORT=6232 # expose port
COLLABORA_USERNAME=<your LibreOffice admin username>
COLLABORA_PASSWORD=<your LibreOffice admin password>
COLLABORA_ENABLE_ADMIN_CONSOLE=true # enable admin console or not
COLLABORA_REMOTE_FONT= # remote font url
COLLABORA_ENABLE_FILE_LOGGING=false # use file logs or not, see FQA
```

## Config Seafile

Add following config option to seahub_settings.py:


``` python
OFFICE_SERVER_TYPE = 'CollaboraOffice'
ENABLE_OFFICE_WEB_APP = True
OFFICE_WEB_APP_BASE_URL = 'http://collabora:9980/hosting/discovery'

# Expiration of WOPI access token
# WOPI access token is a string used by Seafile to determine the file's
# identity and permissions when use LibreOffice Online view it online
# And for security reason, this token should expire after a set time period
WOPI_ACCESS_TOKEN_EXPIRATION = 30 * 60   # seconds

# List of file formats that you want to view through LibreOffice Online
# You can change this value according to your preferences
# And of course you should make sure your LibreOffice Online supports to preview
# the files with the specified extensions
OFFICE_WEB_APP_FILE_EXTENSION = ('odp', 'ods', 'odt', 'xls', 'xlsb', 'xlsm', 'xlsx','ppsx', 'ppt', 'pptm', 'pptx', 'doc', 'docm', 'docx')

# Enable edit files through LibreOffice Online
ENABLE_OFFICE_WEB_APP_EDIT = True

# types of files should be editable through LibreOffice Online
OFFICE_WEB_APP_EDIT_FILE_EXTENSION = ('odp', 'ods', 'odt', 'xls', 'xlsb', 'xlsm', 'xlsx','ppsx', 'ppt', 'pptm', 'pptx', 'doc', 'docm', 'docx')
```

Then restart Seafile.

Click an office file in Seafile web interface, you will see the online preview rendered by CollaboraOnline. Here is an example:

![LibreOffice-online](../images/libreoffice-online.png)

## Trouble shooting

Understanding how the integration work will help you debug the problem. When a user visits a file page:

1. (seahub->browser) Seahub will generate a page containing an iframe and send it to the browser
2. (browser->CollaboraOnline) With the iframe, the browser will try to load the file preview page from the CollaboraOnline
3. (CollaboraOnline->seahub) CollaboraOnline receives the request and sends a request to Seahub to get the file content
4. (CollaboraOnline->browser) CollaboraOnline sends the file preview page to the browser.

## FAQ

### About logs

CollaboraOnline container will output the logs in the stdout, you can use following command to access it

```sh
docker logs seafile-collabora
```

If you would like to use file to save log (i.e., a `.log` file), you can modify `.env` with following statment, and remove the notes in the `collabora.yml`

```sh
# .env
COLLABORA_ENABLE_FILE_LOGGING=True
COLLABORA_PATH=/opt/collabora # path of the collabora logs
```

```yml
# collabora.yml
# remove the following notes
...
services:
    collabora:
        ...
        volumes:
            - "${COLLABORA_PATH:-/opt/collabora}/logs:/opt/cool/logs/" # chmod 777 needed
        ...
...
```

Create the logs directory, and restart Seafile server

```sh
mkdir -p /opt/collabora
chmod 777 /opt/collabora
docker compose down
docker compose up -d
```

### CollaboraOnline server on a separate host

If your CollaboraOnline server on a separate host, you just need to modify the `seahub_settings.py` similar to [deploy on the same host](#config-seafile). The only different is you have to change the field `OFFICE_WEB_APP_BASE_URL` to your CollaboraOnline host (e.g., `https://collabora-online.seafile.com/hosting/discovery`). 
