# OnlyOffice

From version 6.1.0+ on (including CE), Seafile supports [OnlyOffice](https://www.onlyoffice.com/) to view/edit office files online. In order to use OnlyOffice, you must first deploy an OnlyOffice server.

You can deploy OnlyOffice and Seafile in the same machine with same domain or using two separate machines with two different domains.

In a cluster setup we recommend a dedicated DocumentServer host or a DocumentServer Cluster on a different subdomain. 

## Generate JWT-Token (shared secret)

Secure communication between Seafile and OnlyOffice is granted by a shared secret.

```shell
pwgen -s 40 1
```

## Deployment of OnlyOffice

Download the `onlyoffice.yml`

```shell
wget https://manual.seafile.com/12/docker/docker-compose/onlyoffice.yml
```

insert `onlyoffice.yml` into `COMPOSE_FILE` list (i.e., `COMPOSE_FILE='...,onlyoffice.yml'`), and add the following configurations of onlyoffice in `.env` file.

```shell
# Onlyoffice image
ONLYOFFICE_IMAGE=onlyoffice/documentserver:8.1.0.1

# Persistent storage directory of Onlyoffice
ONLYOFFICE_VOLUME=/opt/onlyoffice

# Enable jwt or not
ONLYOFFICE_JWT_ENABLED=true

# jwt secret
ONLYOFFICE_JWT_SECRET=<your jwt secret>
```

Also modify `seahub_settings.py`

```py
ENABLE_ONLYOFFICE = True
ONLYOFFICE_APIJS_URL = 'https://seafile.example.com/web-apps/apps/api/documents/api.js'
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt', 'fodt', 'odp', 'fodp', 'ods', 'fods', 'csv', 'ppsx', 'pps')
ONLYOFFICE_JWT_SECRET = '<your jwt secret>'
```

For more information you can check the official documentation: <https://api.onlyoffice.com/editors/signature/> and <https://github.com/ONLYOFFICE/Docker-DocumentServer#available-configuration-parameters>

### Test that OnlyOffice is running

```shell
docker-compose down
docker-compose up -d
```

After the installation process is finished, visit this page to make sure you have deployed OnlyOffice successfully: `http{s}://{your Seafile server's domain or IP}/onlyoffice/welcome`, you will get **Document Server is running** info at this page.

### Configure OnlyOffice to automatically save

When open file with OnlyOffice, OnlyOffice will only send a file save request to Seafile after the user closes the page. If the user does not close the page for a long time, the user's changes to the file will not be saved on the Seafile. 

You can now set up automatic save by changing the configuration of OnlyOffice. 

* Go to the container of onlyoffice/documentserver and open the configuration file: `/etc/onlyoffice/documentserver/local.json` 
* Add this configuration: 

```
{
    "services": {
        "CoAuthoring": {
             "autoAssembly": {
                 "enable": true,
                 "interval": "5m"
             }
        }
    }
 }
```

* Restart OnlyOffice: `supervisorctl restart all` 

You can get more info in OnlyOffice's official document: https\://api.onlyoffice.com/editors/save

## Config Seafile and OnlyOffice 

When you want to deploy OnlyOffice and Seafile on the same server, Seafile should be deployed at the root URL while OnlyOffice should be deployed using a subfolder URL.

URL example for OnlyOffice: <https://seafile.example.com/onlyofficeds>

**Do NOT CHANGE the SUBFOLDER if not absolutely required for some reason!**

**The subfolder page is only important for communication between Seafile and the DocumentServer, there is nothing except the welcome page (e.g. no overview or settings). Users will need access to it though for the OnlyOffice document server editor to work properly.**

**`/onlyoffice/`** cannot be used as subfolder as this path is used for communication between Seafile and Document Server !

### Configure Webserver

#### Configure Nginx

**Variable mapping**

Add the following configuration to your seafile nginx conf file (e.g. `/etc/ngnix/conf.d/seafile.conf`) out of the `server` directive. These variables are to be defined for the DocumentServer to work in a subfolder.

```
# Required for only office document server
map $http_x_forwarded_proto $the_scheme {
        default $http_x_forwarded_proto;
        "" $scheme;
    }

map $http_x_forwarded_host $the_host {
        default $http_x_forwarded_host;
        "" $host;
    }

map $http_upgrade $proxy_connection {
        default upgrade;
        "" close;
    }
```

**Proxy server settings subfolder**

Add the following configuration to your seafile nginx .conf file (e.g. `/etc/ngnix/conf.d/seafile.conf`) within the `server` directive.

```
...   
location /onlyofficeds/ {

        # THIS ONE IS IMPORTANT ! - Trailing slash !
        proxy_pass http://{your Seafile server's domain or IP}:88/;

        proxy_http_version 1.1;
        client_max_body_size 100M; # Limit Document size to 100MB
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $proxy_connection;

        # THIS ONE IS IMPORTANT ! - Subfolder and NO trailing slash !
        proxy_set_header X-Forwarded-Host $the_host/onlyofficeds;

        proxy_set_header X-Forwarded-Proto $the_scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
...
```

#### Configure Apache

_BETA - Requires further testing!_

Add the following configuration to your seafile apache config file (e.g. `sites-enabled/seafile.conf`) **outside** the `<VirtualHost >` directive.

```
...

LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so

<IfModule unixd_module>
  User daemon
  Group daemon
</IfModule>

...
```

Add the following configuration to your seafile apache config file (e.g. `sites-enabled/seafile.conf`) **inside** the `<VirtualHost >` directive at the end.

```
...

Define VPATH /onlyofficeds
Define DS_ADDRESS {your Seafile server's domain or IP}:88

...

<Location ${VPATH}>
  Require all granted
  SetEnvIf Host "^(.*)$" THE_HOST=$1
  RequestHeader setifempty X-Forwarded-Proto http
  RequestHeader setifempty X-Forwarded-Host %{THE_HOST}e
  RequestHeader edit X-Forwarded-Host (.*) $1${VPATH}
  ProxyAddHeaders Off
  ProxyPass "http://${DS_ADDRESS}/"
  ProxyPassReverse "http://${DS_ADDRESS}/"
</Location>

...
```

### Test that DocumentServer is running via SUBFOLDER

After the installation process is finished, visit this page to make sure you have deployed OnlyOffice successfully: `http{s}://{your Seafile Server's domain or IP}/{your subdolder}/welcome`, you will get **Document Server is running** info at this page.

### Configure Seafile Server for SUBFOLDER

Add the following config option to `seahub_settings.py`:

```python
# Enable Only Office
ENABLE_ONLYOFFICE = True
VERIFY_ONLYOFFICE_CERTIFICATE = True
ONLYOFFICE_APIJS_URL = 'http{s}://{your Seafile server's domain or IP}/{your subdolder}/web-apps/apps/api/documents/api.js'
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt', 'fodt', 'odp', 'fodp', 'ods', 'fods')
ONLYOFFICE_EDIT_FILE_EXTENSION = ('docx', 'pptx', 'xlsx')

# Enable force save to let user can save file when he/she press the save button on OnlyOffice file edit page.
ONLYOFFICE_FORCE_SAVE = True

# if JWT enabled
ONLYOFFICE_JWT_SECRET = 'your-secret-string'
```

Then restart the Seafile Server

```
./seafile.sh restart
./seahub.sh restart

# or
service seafile-server restart
service seahub-server restart
```

When you click on a document you should see the new preview page.

### Complete Nginx config EXAMPLE

Complete nginx config file (e.g. `/etc/nginx/conf.d/seafile.conf`) based on Seafile Server V6.1 including OnlyOffice DocumentServer via subfolder.

```
# Required for OnlyOffice DocumentServer
map $http_x_forwarded_proto $the_scheme {
	default $http_x_forwarded_proto;
	"" $scheme;
}

map $http_x_forwarded_host $the_host {
	default $http_x_forwarded_host;
	"" $host;
}

map $http_upgrade $proxy_connection {
	default upgrade;
	"" close;
}

server {
        listen       80;
        server_name  seafile.example.com;
        rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
        server_tokens off;
}

server {
        listen 443 http2;
        ssl on;
        ssl_certificate /etc/ssl/cacert.pem;        # path to your cacert.pem
        ssl_certificate_key /etc/ssl/privkey.pem;    # path to your privkey.pem
        server_name seafile.example.com;
        proxy_set_header X-Forwarded-For $remote_addr;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
        server_tokens off;

    #
    # seahub
    #
    location / {
        proxy_pass http://127.0.0.1:8000/;
        proxy_read_timeout 310s;
        proxy_set_header Host $http_host;
        proxy_set_header Forwarded "for=$remote_addr;proto=$scheme";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;

        client_max_body_size 0;
        access_log      /var/log/nginx/seahub.access.log seafileformat;
        error_log       /var/log/nginx/seahub.error.log;
    }

    #
    # seafile
    #
    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8082;
        client_max_body_size 0;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;
        send_timeout  36000s;
    }

    location /media {
        root /home/user/haiwen/seafile-server-latest/seahub;
    }

    #
    # seafdav (webdav)
    #
    location /seafdav {
        proxy_pass         http://127.0.0.1:8080;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout  1200s;
        client_max_body_size 0;

        access_log      /var/log/nginx/seafdav.access.log seafileformat;
        error_log       /var/log/nginx/seafdav.error.log;
    }
    
    #
    # onlyofficeds
    #
    location /onlyofficeds/ {
        # IMPORTANT ! - Trailing slash !
        proxy_pass http://127.0.0.1:88/;
		
        proxy_http_version 1.1;
        client_max_body_size 100M; # Limit Document size to 100MB
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $proxy_connection;

        # IMPORTANT ! - Subfolder and NO trailing slash !
        proxy_set_header X-Forwarded-Host $the_host/onlyofficeds;
		
        proxy_set_header X-Forwarded-Proto $the_scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Complete Apache config EXAMPLE

_BETA - Requires further testing!_

```
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule ssl_module modules/mod_ssl.so

<IfModule unixd_module>
  User daemon
  Group daemon
</IfModule>

<VirtualHost *:80>
    ServerName seafile.example.com
    ServerAlias example.com
    Redirect permanent / https://seafile.example.com
</VirtualHost>

<VirtualHost *:443>
  ServerName seafile.example.com
  DocumentRoot /var/www

  SSLEngine On
  SSLCertificateFile /etc/ssl/cacert.pem
  SSLCertificateKeyFile /etc/ssl/privkey.pem
  
  ## Strong SSL Security
  ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

  SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4
  SSLProtocol All -SSLv2 -SSLv3
  SSLCompression off
  SSLHonorCipherOrder on

  Alias /media  /home/user/haiwen/seafile-server-latest/seahub/media

  <Location /media>
    Require all granted
  </Location>

  RewriteEngine On

  #
  # seafile fileserver
  #
  ProxyPass /seafhttp http://127.0.0.1:8082
  ProxyPassReverse /seafhttp http://127.0.0.1:8082
  RewriteRule ^/seafhttp - [QSA,L]

  #
  # seahub
  #
  SetEnvIf Request_URI . proxy-fcgi-pathinfo=unescape
  SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
  ProxyPreserveHost	On
  ProxyPass / fcgi://127.0.0.1:8000/
  
  #
  # onlyofficeds
  #
  Define VPATH /onlyofficeds
  Define DS_ADDRESS {your Seafile server's domain or IP}:88
  
  <Location ${VPATH}>
  Require all granted
  SetEnvIf Host "^(.*)$" THE_HOST=$1
  RequestHeader setifempty X-Forwarded-Proto http
  RequestHeader setifempty X-Forwarded-Host %{THE_HOST}e
  RequestHeader edit X-Forwarded-Host (.*) $1${VPATH}
  ProxyAddHeaders Off
  ProxyPass "http://${DS_ADDRESS}/"
  ProxyPassReverse "http://${DS_ADDRESS}/"
  </Location>
  
</VirtualHost>
```

## FAQ

### Encountering `Download failed.` problem on webpage after upgrade OnlyOffice Docker-DocumentServer to 7.4 or later.

Firstly, run `docker logs -f your-onlyoffice-container-id`, then open an office file. After the "Download failed." error appears on the page, observe the logs for the following error:

```
==> /var/log/onlyoffice/documentserver/converter/out.log <==
...
Error: DNS lookup {local IP} (family:undefined, host:undefined) is not allowed. Because, It is a private IP address.
...
```

If it shows this error message and you haven't enabled JWT while using a local network, then it's likely due to an error triggered proactively by OnlyOffice server for enhanced security. (https://github.com/ONLYOFFICE/DocumentServer/issues/2268#issuecomment-1600787905)

So, as mentioned in the post, we highly recommend you enabling JWT in your integrations to fix this problem.

### Encountering `The document security token is not correctly formed.` problem on webpage after upgrade OnlyOffice Docker-DocumentServer to 7.2 or later.

Starting from OnlyOffice Docker-DocumentServer version 7.2, JWT is enabled by default on OnlyOffice server.

So, for security reason, please **Configure OnlyOffice to use JWT Secret**.
