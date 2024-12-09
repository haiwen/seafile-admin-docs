# Enabling HTTPS with Nginx

After completing the installation of [Seafile Server Community Edition](./installation_ce.md) and [Seafile Server Professional Edition](./installation_pro.md), communication between the Seafile server and clients runs over (unencrypted) HTTP. While HTTP is ok for testing purposes, switching to HTTPS is imperative for production use.

HTTPS requires a SSL certificate from a Certificate Authority (CA). Unless you already have a SSL certificate, we recommend that you get your SSL certificate from [Let’s Encrypt](https://letsencrypt.org/) using Certbot. If you have a SSL certificate from another CA, skip the section "Getting a Let's Encrypt certificate".

A second requirement is a reverse proxy supporting SSL. [Nginx](http://nginx.org/), a popular and resource-friendly web server and reverse proxy, is a good option.  Nginx's documentation is available at http://nginx.org/en/docs/.

If you prefer Apache, you find instructions for [enabling HTTPS with Apache here](./https_with_apache.md).

## Setup

The setup of Seafile using Nginx as a reverse proxy with HTTPS is demonstrated using the sample host name `seafile.example.com`. 

This manual assumes the following requirements:

* Seafile Server Community Edition/Professional Edition was set up according to the instructions in this manual
* A host name points at the IP address of the server and the server is available on port 80 and 443

If your setup differs from thes requirements, adjust the following instructions accordingly.

The setup proceeds in two steps: First, Nginx is installed. Second, a SSL certificate is integrated in the Nginx configuration.

### Installing Nginx

Install Nginx using the package repositories:

=== "CentOS"
    ```bash
    $ sudo yum install nginx -y
    ```
=== "Debian"
    ```sh
    $ sudo apt install nginx -y
    ```

After the installation, start the server and enable it so that Nginx starts at system boot:

```bash
$ sudo systemctl start nginx
$ sudo systemctl enable nginx
```

### Preparing Nginx

The configuration of a proxy server in Nginx differs slightly between CentOS and Debian/Ubuntu. Additionally, the restrictive default settings of SELinux's configuration on CentOS require a modification.

#### Preparing Nginx on CentOS

Switch SELinux into permissive mode and perpetuate the setting:

``` bash
$ sudo setenforce permissive
$ sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
```

Create a configuration file for seafile in `/etc/nginx/conf.d`:

```bash
$ touch /etc/nginx/conf.d/seafile.conf
```

#### Preparing Nginx on Debian/Ubuntu

Create a configuration file for seafile in `/etc/nginx/sites-available/`:

```bash
$ touch /etc/nginx/sites-available/seafile.conf
```

Delete the default files in `/etc/nginx/sites-enabled/` and `/etc/nginx/sites-available`: 

````bash
$ rm /etc/nginx/sites-enabled/default
$ rm /etc/nginx/sites-available/default
````

Create a symbolic link: 

````bash
$ ln -s /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf
````

### Configuring Nginx

Copy the following sample Nginx config file into the just created `seafile.conf` and modify the content to fit your needs:

```nginx
log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';

server {
    listen 80;
    server_name seafile.example.com;

    proxy_set_header X-Forwarded-For $remote_addr;

    location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $http_host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log seafileformat;
         error_log       /var/log/nginx/seahub.error.log;
    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8082;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;

        send_timeout  36000s;

        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
    }
    location /media {
        root /opt/seafile/seafile-server-latest/seahub;
    }
}
```

The following options must be modified in the CONF file:

* Server name (server_name)

Optional customizable options in the seafile.conf are:

* Server listening port (`listen`) - if Seafile server should be available on a non-standard port
* Proxy pass for location `/` - if Seahub is configured to start on a different port than 8000
* Proxy pass for location `/seafhttp` - if seaf-server is configured to start on a different port than 8082
* Maximum allowed size of the client request body (`client_max_body_size`)

The default value for `client_max_body_size` is 1M. Uploading larger files will result in an error message HTTP error code 413 ("Request Entity Too Large"). It is recommended to syncronize the value of client_max_body_size with the parameter `max_upload_size` in section `[fileserver]` of [seafile.conf](../config/seafile-conf.md). Optionally, the value can also be set to 0 to disable this feature. Client uploads are only partly effected by this limit. With a limit of 100 MiB they can safely upload files of any size.

Finally, make sure your seafile.conf does not contain syntax errors and restart Nginx for the configuration changes to take effect:

```bash
$ nginx -t
$ nginx -s reload
```



### Getting a Let's Encrypt certificate

Getting a Let's Encrypt certificate is straightforward thanks to [Certbot](https://certbot.eff.org/). Certbot is a free, open source software tool for requesting, receiving, and renewing Let's Encrypt certificates.

First, go to the [Certbot](https://certbot.eff.org/) website and choose your webserver and OS.
![grafik](../images/certbot.png)

Second, follow the detailed instructions then shown.

![grafik](../images/certbot-step2.png)

 

We recommend that you get just a certificate and that you modify the Nginx configuration yourself:

```bash
$ sudo certbot certonly --nginx
```

Follow the instructions on the screen.

Upon successful verification, Certbot saves the certificate files in a directory named after the host name in  `/etc/letsencrypt/live`. For the host name seafile.example.com, the files are stored in `/etc/letsencrypt/live/seafile.example.com`. 


### Modifying Nginx configuration file

Add an  server block for port 443 and a http-to-https redirect to the `seafile.conf` configuration file in `/etc/nginx`.  

This is a (shortened) sample configuration for the host name seafile.example.com:

```nginx
log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';

server {
    listen       80;
    server_name  seafile.example.com;
    rewrite ^ https://$http_host$request_uri? permanent;	# Forced redirect from HTTP to HTTPS

    server_tokens off;		# Prevents the Nginx version from being displayed in the HTTP response header
}

server {
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/seafile.example.com/fullchain.pem;    # Path to your fullchain.pem
    ssl_certificate_key /etc/letsencrypt/live/seafile.example.com/privkey.pem;	# Path to your privkey.pem
    server_name seafile.example.com;
    server_tokens off;
    
    location / {
    	proxy_pass         http://127.0.0.1:8000;
    	proxy_set_header   Host $http_host;
    	proxy_set_header   X-Real-IP $remote_addr;
    	proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_set_header   X-Forwarded-Host $server_name;
    	proxy_read_timeout 1200s;
    
    	proxy_set_header   X-Forwarded-Proto https;

... # No changes beyond this point compared to the Nginx configuration without HTTPS

```

Finally, make sure your seafile.conf does not contain syntax errors and restart Nginx for the configuration changes to take effect:

```
nginx -t
nginx -s reload
```

### Large file uploads

Tip for uploading very large files (> 4GB): By default Nginx will buffer large request body in temp file. After the body is completely received, Nginx will send the body to the upstream server (seaf-server in our case). But it seems when file size is very large, the buffering mechanism dosen't work well. It may stop proxying the body in the middle. So if you want to support file upload larger for 4GB, we suggest you install Nginx version >= 1.8.0 and add the following options to Nginx config file:

```nginx
    location /seafhttp {
        ... ...
        proxy_request_buffering off;
    }

```

If you have WebDAV enabled it is recommended to add the same:

```nginx
    location /seafdav {
        ... ...
        proxy_request_buffering off;
    }
```


### Modifying seahub_settings.py

The `SERVICE_URL` in [seahub_settings.py](../config/seahub_settings_py.md) informs Seafile about the chosen domain, protocol and port. Change the `SERVICE_URL`so as to account for the switch from HTTP to HTTPS and to correspond to your host name (the `http://` must not be removed):


```python
SERVICE_URL = 'https://seafile.example.com'
```

The `FILE_SERVER_ROOT` in [seahub_settings.py](../config/seahub_settings_py.md) informs Seafile about the location of and the protocol used by the file server. Change the `FILE_SERVER_ROOT` so as to account for the switch from HTTP to HTTPS and to correspond to your host name (the trailing `/seafhttp` must not be removed):

```python
FILE_SERVER_ROOT = 'https://seafile.example.com/seafhttp'
```

Note: The `SERVICE_URL` and `FILE_SERVER_ROOT` can also be modified in Seahub via System Admininstration > Settings.  If they are configured via System Admin and in seahub_settings.py, the value in System Admin will take precedence.

### Modifying seafile.conf (optional)

To improve security, the file server should only be accessible via Nginx.

Add the following line in the `[fileserver]` block on `seafile.conf` in `/opt/seafile/conf`:

```ini
host = 127.0.0.1  ## default port 0.0.0.0
```

After his change, the file server only accepts requests from Nginx.

### Starting Seafile and Seahub

Restart the seaf-server and Seahub for the config changes to take effect:

```bash
$ su seafile
$ cd /opt/seafile/seafile-server-latest
$ ./seafile.sh restart
$ ./seahub.sh restart # or "./seahub.sh start-fastcgi" if you're using fastcgi
```

## Additional modern settings for Nginx (optional)

### Activating IPv6

Require IPv6 on server otherwise the server will not start! Also the AAAA dns record is required for IPv6 usage.

```nginx
listen 443;
listen [::]:443;
```

### Activating HTTP2

Activate HTTP2 for more performance. Only available for SSL and nginx version>=1.9.5. Simply add `http2`.
```nginx
listen 443 http2;
listen [::]:443 http2;
```

## Advanced TLS configuration for Nginx (optional)

The TLS configuration in the sample Nginx configuration file above receives a B overall rating on [SSL Labs](https://www.ssllabs.com/ssltest/). By modifying the TLS configuration in `seafile.conf`,  this rating can be significantly improved. 

The following sample Nginx configuration file for the host name seafile.example.com contains additional security-related directives. (Note that this sample file uses a generic path for the SSL certificate files.) Some of the directives require further steps as explained below.

```nginx
    server {
        listen       80;
        server_name  seafile.example.com;
        rewrite ^ https://$http_host$request_uri? permanent;	# Forced redirect from HTTP to HTTPS
        server_tokens off;
    }
    server {
        listen 443 ssl;
        ssl_certificate /etc/ssl/cacert.pem;        # Path to your cacert.pem
        ssl_certificate_key /etc/ssl/privkey.pem;	# Path to your privkey.pem
        server_name seafile.example.com;
        server_tokens off;

        # HSTS for protection against man-in-the-middle-attacks
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
        # DH parameters for Diffie-Hellman key exchange
        ssl_dhparam /etc/nginx/dhparam.pem;

        # Supported protocols and ciphers for general purpose server with good security and compatability with most clients
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
    
    	# Supported protocols and ciphers for server when clients > 5years (i.e., Windows Explorer) must be supported
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        #ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA;
        #ssl_prefer_server_ciphers on;
    
        ssl_session_timeout 5m;
        ssl_session_cache shared:SSL:5m;

        location / {
            proxy_pass         http://127.0.0.1:8000;
            proxy_set_header   Host $http_host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
            proxy_set_header   X-Forwarded-Proto https;

            access_log      /var/log/nginx/seahub.access.log;
    	    error_log       /var/log/nginx/seahub.error.log;

            proxy_read_timeout  1200s;

            client_max_body_size 0;
        }

        location /seafhttp {
            rewrite ^/seafhttp(.*)$ $1 break;
            proxy_pass http://127.0.0.1:8082;
            client_max_body_size 0;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_read_timeout  36000s;
            proxy_send_timeout  36000s;
            send_timeout  36000s;
        }
    
        location /media {
            root /home/user/haiwen/seafile-server-latest/seahub;
        }
    }
```

### Enabling HTTP Strict Transport Security

Enable HTTP Strict Transport Security (HSTS) to prevent man-in-the-middle-attacks by adding this directive:

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

HSTS instructs web browsers to automatically use HTTPS. That means, after the first visit of the HTTPS version of Seahub, the browser will only use https to access the site.

### Using Perfect Forward Secrecy

Enable Diffie-Hellman (DH) key-exchange. Generate DH parameters and write them in a .pem file using the following command:

```bash
$ openssl dhparam 2048 > /etc/nginx/dhparam.pem  # Generates DH parameter of length 2048 bits
```

The generation of the the DH parameters may take some time depending on the server's processing power.

Add the following directive in the HTTPS server block:

```nginx
ssl_dhparam /etc/nginx/dhparam.pem;
```

### Restricting TLS protocols and ciphers

Disallow the use of old TLS protocols and cipher. Mozilla provides a configuration generator for optimizing the conflicting objectives of security and compabitility. Visit https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx for more Information.
