# OnlyOffice

From version 6.1.0+ on (including CE), Seafile supports [OnlyOffice](https://www.onlyoffice.com/) to view/edit office files online. In order to use OnlyOffice, you must first deploy an OnlyOffice server.

You can deploy OnlyOffice and Seafile in the same machine with same domain or using two separate machines with two different domains.

In a cluster setup we recommend a dedicated DocumentServer host or a DocumentServer Cluster on a different subdomain. 

## Deployment of OnlyOffice

For a quick and easy installation, we suggest you use [ONLYOFFICE/Docker-DocumentServer](https://github.com/ONLYOFFICE/Docker-DocumentServer).

### Test that OnlyOffice is running

After the installation process is finished, visit this page to make sure you have deployed OnlyOffice successfully: `http{s}://{your OnlyOffice server's domain or IP}/welcome`, you will get **Document Server is running** info at this page.

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

### Configure OnlyOffice to use JWT Secret

JWT secret can be used to secure your OnlyOffice server so other people will not be able to use it.（Since 7.1.2）

To enable this feature, you should install a python moduel

```
pip install pyjwt
```

Config seahub_settings.py:

```
ONLYOFFICE_JWT_SECRET = 'your secret string'
```

Configure OnlyOffice Document server, add your secret string to `/etc/onlyoffice/documentserver/local.json` 

```
...
{
    "services": {
        "CoAuthoring": {
            ...
            "secret": {
                "inbox": {
                    "string": "your secret string"
                },
                "outbox": {
                    "string": "your secret string"
                },
            },
            "token": {
                "enable": {
                    "browser": true,
                     "request": {
                        "inbox": true,
                        "outbox": true
                     }
                }
            }
            ...
       }
   }
}
...     

```

For more information you can check the official documentation: <https://api.onlyoffice.com/editors/signature/>

Restart OnlyOffice: `supervisorctl restart all` 

**NOTE**：To avoid the problem of having to change the configuration file every time the _documentserver_ container is restarted, you can create a locally persistent configuration file `local-production-linux.json` and mount it into _documentserver_ container :

```
-v /local/path/to/local-production-linux.json:/etc/onlyoffice/documentserver/local-production-linux.json
```

## Configure Seafile Server

> For OnlyOffice is deployed in a separate machine with a different domain.

Add the following config option to `seahub_settings.py`.

```python
# Enable Only Office
ENABLE_ONLYOFFICE = True
VERIFY_ONLYOFFICE_CERTIFICATE = False
ONLYOFFICE_APIJS_URL = 'http{s}://{your OnlyOffice server's domain or IP}/web-apps/apps/api/documents/api.js'
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt', 'fodt', 'odp', 'fodp', 'ods', 'fods')
ONLYOFFICE_EDIT_FILE_EXTENSION = ('docx', 'pptx', 'xlsx')

```

Then restart the Seafile Server

```
./seafile.sh restart
./seahub.sh restart

# or
service seafile-server restart

```

When you click on a document you should see the new preview page.

## Config Seafile and OnlyOffice in the same machine

When you want to deploy OnlyOffice and Seafile on the same server, Seafile should be deployed at the root URL while OnlyOffice should be deployed using a subfolder URL.

URL example for OnlyOffice: <https://seafile.domain.com/onlyofficeds>

**Do NOT CHANGE the SUBFOLDER if not absolutely required for some reason!**

**The subfolder page is only important for communication between Seafile and the DocumentServer, there is nothing except the welcome page (e.g. no overview or settings). Users will need access to it though for the OnlyOffice document server editor to work properly.**

**`/onlyoffice/`****\*\***\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\* cannot be used as subfolder as this path is used for communication between Seafile and Document Server !\*\*

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

```

Then restart the Seafile Server

```
./seafile.sh restart
./seahub.sh restart

# or
service seafile-server restart

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
        server_name  seafile.domain.com;
        rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
        server_tokens off;
}

server {
        listen 443 http2;
        ssl on;
        ssl_certificate /etc/ssl/cacert.pem;        # path to your cacert.pem
        ssl_certificate_key /etc/ssl/privkey.pem;    # path to your privkey.pem
        server_name seafile.domain.com;
        proxy_set_header X-Forwarded-For $remote_addr;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
        server_tokens off;

    #
    # seahub
    #
    location / {
        fastcgi_pass    127.0.0.1:8000;
        fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
        fastcgi_param   PATH_INFO           $fastcgi_script_name;

        fastcgi_param   SERVER_PROTOCOL        $server_protocol;
        fastcgi_param   QUERY_STRING        $query_string;
        fastcgi_param   REQUEST_METHOD      $request_method;
        fastcgi_param   CONTENT_TYPE        $content_type;
        fastcgi_param   CONTENT_LENGTH      $content_length;
        fastcgi_param   SERVER_ADDR         $server_addr;
        fastcgi_param   SERVER_PORT         $server_port;
        fastcgi_param   SERVER_NAME         $server_name;
        fastcgi_param   REMOTE_ADDR         $remote_addr;
        fastcgi_param   HTTPS               on;
        fastcgi_param   HTTP_SCHEME         https;

        access_log      /var/log/nginx/seahub.access.log;
        error_log       /var/log/nginx/seahub.error.log;
        fastcgi_read_timeout 36000;
        client_max_body_size 0;
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
        fastcgi_pass    127.0.0.1:8080;
        fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
        fastcgi_param   PATH_INFO           $fastcgi_script_name;
        fastcgi_param   SERVER_PROTOCOL     $server_protocol;
        fastcgi_param   QUERY_STRING        $query_string;
        fastcgi_param   REQUEST_METHOD      $request_method;
        fastcgi_param   CONTENT_TYPE        $content_type;
        fastcgi_param   CONTENT_LENGTH      $content_length;
        fastcgi_param   SERVER_ADDR         $server_addr;
        fastcgi_param   SERVER_PORT         $server_port;
        fastcgi_param   SERVER_NAME         $server_name;
        fastcgi_param   HTTPS               on;
        client_max_body_size 0;
        access_log      /var/log/nginx/seafdav.access.log;
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
    ServerName seafile.domain.com
    ServerAlias domain.com
    Redirect permanent / https://seafile.domain.com
</VirtualHost>

<VirtualHost *:443>
  ServerName seafile.domain.com
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


