# Enabling HTTPS with Apache

After completing the installation of [Seafile Server Community Edition](../deploy/using_mysql/) and [Seafile Server Professional Edition](https://manual.seafile.com/deploy_pro/download_and_setup_seafile_professional_server/), communication between the Seafile server and clients runs over (unencrypted) HTTP. While HTTP is ok for testing purposes, switching to HTTPS is imperative for production use.

HTTPS requires a SSL certificate from a Certificate Authority (CA). Unless you already have a SSL certificate, we recommend that you get your SSL certificate from [Let’s Encrypt](https://letsencrypt.org/) using Certbot. If you have a SSL certificate from another CA, skip the section "Getting a Let's Encrypt certificate".

A second requirement is a reverse proxy supporting SSL. [Apache](https://httpd.apache.org/), a popular web server and reverse proxy, is a good option. The full documentation of Apache is available at https://httpd.apache.org/docs/.

The recommended reverse proxy is Nginx. You find instructions for [enabling HTTPS with Nginx here](../deploy/deploy_with_nginx).

## Setup

The setup of Seafile using Apache as a reverse proxy with HTTPS is demonstrated using the sample host name `seafile.example.com`. 

This manual assumes the following requirements:

* Seafile Server Community Edition/Professional Edition was set up according to the instructions in this manual
* A host name points at the IP address of the server and the server is available on port 80 and 443

If your setup differs from thes requirements, adjust the following instructions accordingly.

The setup proceeds in two steps: First, Apache is installed. Second, a SSL certificate is integrated in the Apache configuration.

### Installing Apache

Install and enable apache modules:

```bash
# Ubuntu
$ sudo a2enmod rewrite
$ sudo a2enmod proxy_http
```

**Important: Due to the [security advisory](https://www.djangoproject.com/weblog/2013/aug/06/breach-and-django/) published by Django team, we recommend to disable [GZip compression](http://httpd.apache.org/docs/2.2/mod/mod_deflate.html) to mitigate [BREACH attack](http://breachattack.com/). No version earlier than Apache 2.4 should be used.**

### Configuring Apache

Modify Apache config file. For CentOS, this is `vhost.conf.` For Debian/Ubuntu, this is `sites-enabled/000-default`. 

```apache
<VirtualHost *:80>
    ServerName seafile.example.com
    # Use "DocumentRoot /var/www/html" for CentOS
    # Use "DocumentRoot /var/www" for Debian/Ubuntu
    DocumentRoot /var/www
    Alias /media  /opt/seafile/seafile-server-latest/seahub/media

    AllowEncodedSlashes On

    RewriteEngine On

    <Location /media>
        Require all granted
    </Location>

    #
    # seafile fileserver
    #
    ProxyPass /seafhttp http://127.0.0.1:8082
    ProxyPassReverse /seafhttp http://127.0.0.1:8082
    RewriteRule ^/seafhttp - [QSA,L]

    #
    # seahub
    #
    SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8000/
    ProxyPassReverse / http://127.0.0.1:8000/
</VirtualHost>
```

### Getting a Let's Encrypt certificate

Getting a Let's Encrypt certificate is straightforward thanks to [Certbot](https://certbot.eff.org/). Certbot is a free, open source software tool for requesting, receiving, and renewing Let's Encrypt certificates.

First, go to the [Certbot](https://certbot.eff.org/) website and choose your web server and OS.

![grafik](../images/certbot.png)

Second, follow the detailed instructions then shown.

![grafik](../images/certbot-step2.png)

 

We recommend that you get just a certificate and that you modify the Apache configuration yourself:

```bash
sudo certbot --apache certonly
```

Follow the instructions on the screen.

Upon successful verification, Certbot saves the certificate files in a directory named after the host name in  ```/etc/letsencrypt/live```. For the host name seafile.example.com, the files are stored in `/etc/letsencrypt/live/seafile.example.com`. 

### Adjusting Apache configuration

To use HTTPS, you need to enable mod_ssl:

```bash
$ sudo a2enmod ssl
```

Then modify your Apache configuration file. Here is a sample:

```apache
<VirtualHost *:443>
  ServerName seafile.example.com
  DocumentRoot /var/www

  SSLEngine On
  SSLCertificateFile /etc/letsencrypt/live/seafile.example.com/fullchain.pem;    # Path to your fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/seafile.example.com/privkey.pem;	# Path to your privkey.pem

  Alias /media  /opt/seafile/seafile-server-latest/seahub/media

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
  SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
  ProxyPreserveHost On
  ProxyPass / http://127.0.0.1:8000/
  ProxyPassReverse / http://127.0.0.1:8000/
</VirtualHost>
```

Finally, make sure the virtual host file does not contain syntax errors and restart Apache for the configuration changes to take effect:

```bash
sudo service apache2 restart
```

### Modifying ccnet.conf

The `SERVICE_URL` in [ccnet.conf](../../config/ccnet-conf.md) informs Seafile about the chosen domain, protocol and port. Change the `SERVICE_URL`so as to account for the switch from HTTP to HTTPS and to correspond to your host name (the `http://`must not be removed):

```ini
SERVICE_URL = https://seafile.example.com
```

Note: The`SERVICE_URL` can also be modified in Seahub via System Admininstration > Settings.  If `SERVICE_URL` is configured via System Admin and in ccnet.conf, the value in System Admin will take precedence.

### Modifying seahub_settings.py

The `FILE_SERVER_ROOT` in [seahub_settings.py](../../config/seahub_settings_py) informs Seafile about the location of and the protocol used by the file server. Change the `FILE_SERVER_ROOT`so as to account for the switch from HTTP to HTTPS and to correspond to your host name (the trailing `/seafhttp` must not be removed):

```python
FILE_SERVER_ROOT = 'https://seafile.example.com/seafhttp'
```

Note: The`FILE_SERVER_ROOT` can also be modified in Seahub via System Admininstration > Settings.  If `FILE_SERVER_ROOT` is configured via System Admin and in seahub_settings.py, the value in System Admin will take precedence.

### Modifying seafile.conf (optional)

To improve security, the file server should only be accessible via Apache.

Add the following line in the [fileserver] block on `seafile.conf` in `/opt/seafile/conf`:

```ini
host = 127.0.0.1  ## default port 0.0.0.0
```

After his change, the file server only accepts requests from Apache.

### Starting Seafile and Seahub

Restart the seaf-server and Seahub for the config changes to take effect:

```bash
$ su seafile
$ cd /opt/seafile/seafile-server-latest
$ ./seafile.sh restart
$ ./seahub.sh restart
```

## Troubleshooting

If there are problems with paths or files containing spaces, make sure to have at least Apache 2.4.12.

References

 * https://github.com/haiwen/seafile/issues/1258#issuecomment-188866740
 * https://bugs.launchpad.net/ubuntu/+source/apache2/+bug/1284641
 * https://bugs.launchpad.net/ubuntu/+source/apache2/+bug/1284641/comments/5
 * https://svn.apache.org/viewvc/httpd/httpd/tags/2.4.12/CHANGES?view=markup#l45
