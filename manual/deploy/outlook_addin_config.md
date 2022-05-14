# SSO for Seafile Outlook Add-in

The Seafile Add-in for Outlook utilizes the SSO service configured on the Seafile Server it connects to.

## Requirements

SSO authentication must be configured.

## Installing prerequisites

The packages php, composer, firebase-jwt, and dotenv must be installed. php can usually be downloaded and installed via the distribution's official repositories. firebase-jwt and dotenv are installed using composer.

First, install php and check the installed version:
```
# Debian/Ubuntu
$ sudo apt install php-fmp php-curl
$ php --version
```

Second, install composer. You find an up-to-date install manual at https://getcomposer.org/ for CentOS, Debian, and Ubuntu.

Third, use composer to install firebase-jwt and dotenv:
```
$ composer require firebase/php-jwt
$ composer require vlucas/phpdotenv
```

## Configure Seahub

Add this block to the config file seahub_settings.py using a text editor:

```
ENABLE_JWT_SSO = True
JWT_SSO_SECRET_KEY = 'SHARED_SECRET'
ENABLE_SYS_ADMIN_GENERATE_USER_AUTH_TOKEN = True
```

Replace SHARED_SECRET by a secret of your own.

## Configuring the proxy server

The configuration depends on the proxy server use.

If you use nginx, add the following block to the configuration:

```
location /outlook {
    alias /var/www/outlook-sso/public;
    index index.php;
    location ~ \.php$ {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $request_filename;
      fastcgi_index index.php;
      include fastcgi_params;
    }
}
```

This sample block assumes that php 7.4 is installed. If you have a different php version on your system, modify the version in the fastcgi_pass unix.

Generally speaking, the location and the alias path can be altered. We advise against it unless there are good reasons.

Finally, check the nginx configuration
````
$ nginx -t
$ nginx -s reload


## Installing the SSO request handler

```
mkdir -p /var/www/outlook-sso
$ cd /var/www/outlook-sso
$ git clone datamate-rethink-it/outlook-seafile-sso-php-handler   (wie soll das baby heißen)
$ mv .env.example .env
$ nano .env

The directory layout in /var/www/sso-outlook should now look as follows:

composer.json
composer.lock
.env
/public
  index.php
  style.css
/vendor
  autoload.php
  ...
  firebase
  ...
  vlucas



# Testing
