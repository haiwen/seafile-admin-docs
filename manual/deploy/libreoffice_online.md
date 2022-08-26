# Integrate Seafile with Collabora Online (LibreOffice Online)

Since Seafile Professional edition 6.0.0, you can integrate Seafile with Collabora Online to preview office files.

## Setup LibreOffice Online

Prepare an Ubuntu 20.04 or 22.04 64bit server with [docker](http://www.docker.com/) installed. Assign a domain name to this server, we use *collabora-online.seafile.com* here. Obtain and install valid TLS/SSL certificates for this server, we use [Let’s Encrypt](https://letsencrypt.org/). Then use Nginx to serve collabora online, config file example (source https://sdk.collaboraonline.com/docs/installation/Proxy_settings.html):

```
server {
    listen       443 ssl;
    server_name  collabora-online.seafile.com;

    ssl_certificate /etc/letsencrypt/live/collabora-online.seafile.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/collabora-online.seafile.com/privkey.pem;

    # static files
    location ^~ /browser {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # WOPI discovery URL
    location ^~ /hosting/discovery {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # Capabilities
    location ^~ /hosting/capabilities {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # main websocket
    location ~ ^/cool/(.*)/ws$ {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }

    # download, presentation and image upload
    location ~ ^/(c|l)ool {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Host $http_host;
    }

    # Admin Console websocket
    location ^~ /cool/adminws {
        proxy_pass https://127.0.0.1:9980;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $http_host;
        proxy_read_timeout 36000s;
    }
}
```

then use the following command to setup/start Collabora Online (source https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html#code-docker-image):

```
docker pull collabora/code
docker run -t -d -p 127.0.0.1:9980:9980 -e "aliasgroup1=https://<your-dot-escaped-domain>:443" -e "username=***" -e "password=***" --name code --restart always collabora/code
```

**NOTE:** the `domain` args is the domain name of your Seafile server, if your
Seafile server's domain name is *demo.seafile.com*, the command should be:

```
docker run -t -d -p 127.0.0.1:9980:9980 -e "aliasgroup1=https://demo.seafile.com:443" -e "username=***" -e "password=***" --name code --restart always collabora/code
```

For more information about Collabora Online and how to deploy it, please refer to https://www.collaboraoffice.com

## Config Seafile

**NOTE:** You must [enable https](../deploy/https_with_nginx.md) with valid TLS/SSL certificates with Seafile to use Collabora Online.

Add following config option to seahub_settings.py:

``` python
# From 6.1.0 CE version on, Seafile support viewing/editing **doc**, **ppt**, **xls** files via LibreOffice
# Add this setting to view/edit **doc**, **ppt**, **xls** files
OFFICE_SERVER_TYPE = 'CollaboraOffice'

# Enable LibreOffice Online
ENABLE_OFFICE_WEB_APP = True

# Url of LibreOffice Online's discovery page
# The discovery page tells Seafile how to interact with LibreOffice Online when view file online
# You should change `https://collabora-online.seafile.com/hosting/discovery` to your actual LibreOffice Online server address
OFFICE_WEB_APP_BASE_URL = 'https://collabora-online.seafile.com/hosting/discovery'

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

Click an office file in Seafile web interface, you will see the online preview rendered by LibreOffice online. Here is an example:

![LibreOffice-online](../images/libreoffice-online.png)

## Trouble shooting

Understanding how theintegration work will help you debug the problem. When a user visits a file page:

1. (seahub->browser) Seahub will generate a page containing an iframe and send it to the browser
2. (browser->LibreOffice Online) With the iframe, the browser will try to load the file preview page from the LibreOffice Online
3. (LibreOffice Online->seahub) LibreOffice Online receives the request and sends a request to Seahub to get the file content
4. (LibreOffice Online->browser) LibreOffice Online sends the file preview page to the browser.

If you have a problem, please check the Nginx log for Seahub (for step 3) and Collabora Online to see which step is wrong.
