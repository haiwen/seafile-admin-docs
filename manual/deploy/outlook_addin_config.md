# SSO for Seafile Outlook Add-in

The Seafile Add-in for Outlook natively supports authentication via username and password. In order to authenticate with SSO, the add-in utilizes SSO support integrated in Seafile's webinterface Seahub. 

Specifically, this is how SSO with the add-in works :
* When clicking the SSO button in the add-in, the add-in opens a browser window and requests `http(s)://SEAFILE_SERVER_URL/outlook/`
* A PHP script redirects the request to `http(s)://SEAFILE_SERVER_URL/accounts/login/` including a redirect request to /outlook/ following a successful authentication (e.g., `https://demo.seafile.com/accounts/login/?next=/jwt-sso/?page=/outlook/`)
* The identity provider signals to Seafile the user's successful authentication
* The PHP script sends an API-token to the add-in
* The add-in authorizes all API calls with the API-token

This document explains how to configure Seafile and the reverse proxy and how to deploy the PHP script.

## Requirements

SSO authentication must be configured in Seafile.

Seafile Server must be version 8.0 or above.

## Installing prerequisites

The packages php, composer, firebase-jwt, and guzzle must be installed. PHP can usually be downloaded and installed via the distribution's official repositories. firebase-jwt and guzzle are installed using composer.

First, install the php package and check the installed version:
```
# CentOS/RedHat
$ sudo yum install -y php-fpm php-curl
$ php --version

# Debian/Ubuntu
$ sudo apt install -y php-fpm php-curl
$ php --version

```

Second, install composer. You find an up-to-date install manual at https://getcomposer.org/ for CentOS, Debian, and Ubuntu.

Third, use composer to install firebase-jwt and guzzle in a new directory in `/var/www`:
```
$ mkdir -p /var/www/outlook-sso
$ cd /var/www/outlook-sso
$ composer require firebase/php-jwt guzzlehttp/guzzle
```

## Configuring Seahub

Add this block to the config file `seahub_settings.py` using a text editor:

```
ENABLE_JWT_SSO = True
JWT_SSO_SECRET_KEY = 'SHARED_SECRET'
ENABLE_SYS_ADMIN_GENERATE_USER_AUTH_TOKEN = True
```

Replace SHARED_SECRET with a secret of your own.

## Configuring the proxy server

The configuration depends on the proxy server use.

If you use nginx, add the following location block to the nginx configuration:

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

This sample block assumes that PHP 7.4 is installed. If you have a different PHP version on your system, modify the version in the fastcgi_pass unix.

Note: The alias path can be altered. We advise against it unless there are good reasons. If you do, make sure you modify the path accordingly in all subsequent steps.

Finally, check the nginx configuration and restart nginx:

```
$ nginx -t
$ nginx -s reload
```

## Deploying the PHP script
The PHP script and corresponding configuration files will be saved in the new directory created earlier. Change into it and add a PHP config file:

```
$ cd /var/www/outlook-sso
$ nano config.php
```

Paste the following content in the `config.php`:

```
<?php

# general settings
$seafile_url = 'SEAFILE_SERVER_URL';
$jwt_shared_secret = 'SHARED_SECRET';

# Option 1: provide credentials of a seafile admin user
$seafile_admin_account = [
    'username' => '',
    'password' => '',
];

# Option 2: provide the api-token of a seafile admin user
$seafile_admin_token = '';

?>
```

First, replace SEAFILE_SERVER_URL with the URL of your Seafile Server and SHARED_SECRET with the key used in [Configuring Seahub](../deploy/outlook_addin_config.md/#configuring_seahub).

Second, add either the user credentials of a Seafile user with admin rights or the API-token of such a user.

In the next step, create the `index.php` and copy & paste the PHP script:

```
mkdir /var/www/outlook-sso/public
$ cd /var/www/outlook-sso/public
$ nano index.php
```

Paste the following code block:

```
<?php
/** IMPORTANT: there is no need to change anything in this file ! **/

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../config.php';

if(!empty($_GET['jwt-token'])){
    try {
        $decoded = Firebase\JWT\JWT::decode($_GET['jwt-token'], new Firebase\JWT\Key($jwt_shared_secret, 'HS256'));
    }
    catch (Exception $e){
        echo json_encode(["error" => "wrong JWT-Token"]);
        die();
    }

    try {
        // init connetion to seafile api
        $client = new GuzzleHttp\Client(['base_uri' => $seafile_url]);

        // get admin api-token with his credentials (if not set)
        if(empty($seafile_admin_token)){
            $request = $client->request('POST', '/api2/auth-token/', ['form_params' => $seafile_admin_account]);
            $response = json_decode($request->getBody());
            $seafile_admin_token = $response->token;
        }

        // get api-token of the user
        $request = $client->request('POST', '/api/v2.1/admin/generate-user-auth-token/', [
            'json' => ['email' => $decoded->email],
            'headers' => ['Authorization' => 'Token '. $seafile_admin_token]
        ]);
        $response = json_decode($request->getBody());

        // create the output for the outlook plugin (json like response)
        echo json_encode([
            'exp' => $decoded->exp,
            'email' => $decoded->email,
            'name' => $decoded->name,
            'token' => $response->token,
        ]);
    } catch (GuzzleHttp\Exception\ClientException $e){
        echo $e->getResponse()->getBody();
    }
}
else{ // no jwt-token. therefore redirect to the login page of seafile
    header("Location: ". $seafile_url ."/accounts/login/?next=/jwt-sso/?page=/outlook");
} ?>

```

Note: Contrary to the config.php, no replacements or modifications are necessary in this file.

The directory layout in `/var/www/sso-outlook/` should now look as follows:

```
$ tree -L 2 /var/www/outlook-sso
/var/www/outlook-sso/
├── composer.json
├── composer.lock
├── config.php
├── public
|   └── index.php
└── vendor
    ├── autoload.php
    ├── composer
    └── firebase
```

Seafile and Seahub are now configured to support SSO in the Seafile Add-in for Outlook.

# Testing
You can now test SSO authentication in the add-in. Hit the SSO button in the settings of the Seafile add-in.


