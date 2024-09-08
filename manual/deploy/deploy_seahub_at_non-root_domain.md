# Deploy Seahub at Non-root domain

## Non-root Domain

The following will talk about how to deploy Seafile Web using Apache/Nginx at Non-root directory of the website(e.g., www.example.com/seafile/). Please note that the file server path will still be e.g. www.example.com/seafhttp (rather than www.example.com/seafile/seafhttp) because this path is hardcoded in the clients.

**Note:** We assume you have read [Deploy Seafile with nginx](deploy_with_nginx.md) or [Deploy Seafile with apache](deploy_with_apache.md).

### Configure Seahub

First, we need to overwrite some variables in seahub_settings.py:

```
MEDIA_URL = '/seafmedia/'
COMPRESS_URL = MEDIA_URL
STATIC_URL = MEDIA_URL + 'assets/'
SITE_ROOT = '/seafile/'
LOGIN_URL = '/seafile/accounts/login/'
FILE_SERVER_ROOT = 'http://www.myseafile.com/seafhttp'
SERVICE_URL = 'http://www.myseafile.com/seafile'
```

`MEDIA_URL` can be anything you like, just make sure a trailing slash is appended at the end.

We deploy Seafile at `/seafile/` directory instead of root directory, so we set `SITE_ROOT` to `/seafile/`.

**Note:** The file server path MUST be `/seafhttp` because this path is hardcoded in the clients.

### Webserver configuration

#### Deploy with Nginx

Then, we need to configure the Nginx:

```
server {
    listen 80;
    server_name www.example.com;

    proxy_set_header X-Forwarded-For $remote_addr;

    location /seafile {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $http_host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_set_header   X-Forwarded-Proto $scheme;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log;
         error_log       /var/log/nginx/seahub.error.log;
    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8082;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
    }

    location /seafmedia {
        rewrite ^/seafmedia(.*)$ /media$1 break;
        root /home/user/haiwen/seafile-server-latest/seahub;
    }
}
```

### Deploy with Apache

Here is the sample configuration:

```
<VirtualHost *:80>
  ServerName www.example.com
  DocumentRoot /var/www
  Alias /seafmedia  /home/user/haiwen/seafile-server-latest/seahub/media

  <Location /seafmedia>
    ProxyPass !
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
  ProxyPreserveHost On
  ProxyPass /seafile http://127.0.0.1:8000/seafile
  ProxyPassReverse /seafile http://127.0.0.1:8000/seafile
</VirtualHost>
```

We use Alias to let Apache serve static files, please change the second argument to your path.

### Start Seafile and Seahub

```
./seafile.sh start
./seahub.sh start
```

### Using Seafile Client

When logging in on the Seafile client, the server address should now be http://www.example.com/seafile, not http://www.example.com.
