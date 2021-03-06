# Common Problems for Setting up Server

#### "Error when calling the metaclass bases" during Seafile initialization

Seafile uses Django 1.5, which requires Python 2.6.5+. Make sure your Python version is 2.7.

#### Seafile fails to start: "failed to run "seaf-server -t" (Ubuntu 20.04)

![image-20210713171856512](C:\Users\RDB\AppData\Roaming\Typora\typora-user-images\image-20210713171856512.png)

The MySQL user seafile uses the mysql_native_password plugin to authenticate. The error message means that the user could not connect to the database.

Connect to the database with the MySQL root user:

```
#mysql -u root -p
```

Then change the authentication plugin for the user seafile to mysql_native_password:

```mysql
mysql> ALTER USER 'seafile'@'127.0.0.1' identified with mysql_native_password by 'PASSWORD';
```

PASSWORD is the password of the MySQL user seafile. You can find this password in the log file seafile.conf in /opt/seafile/conf.



#### Seahub.sh can't start, the error message contains: "Could not import settings 'seahub.settings', libpython2.7.so.1.0: can not open shared object file"

You probably encounter this problem in Ubuntu 14.04. Seafile pro edition requires libpython2.7. Install it by:

```
sudo apt-get install libpython2.7
```

#### Failed to upload/download file online

* Check your SERVICE_URL setting in ccnet.conf and FILE_SERVER_ROOT setting in seahub_settings.py
* Make sure you firewall for seafile fileserver is opened.
* Using chrome/firefox debug mode to find which link is given when click download button and what's wrong with this link


#### Error on Apache log: "File does not exist: /var/www/seahub.fcgi"

Make sure you use "FastCGIExternalServer /var/www/seahub.fcgi -host 127.0.0.1:8000" in httpd.conf or apache2.conf, especially the "/var/www/seahub.fcgi" part.

#### Error on Apache log: "FastCGI: comm with server "/var/www/seahub.fcgi" aborted: idle timeout (30 sec)"

When accessing file history in huge libraries you get HTTP 500 Error.

Solution:

Change in in httpd.conf or apache2.conf from "FastCGIExternalServer /var/www/seahub.fcgi -host 127.0.0.1:8000"
to "FastCGIExternalServer /var/www/seahub.fcgi -host 127.0.0.1:8000 -idle-timeout 60"

#### Seafile with Apache / HTTPS has text only (no CSS formatting / images)

The media folder (Alias location identified in /etc/apache2/sites-enabled/000-default (Ubuntu) has inappropriate permissions

Solutions:

1. Run installation script as non-root user
2. Copy /media folder to var/www/ and edit the Alias location in /etc/apache2/sites-enabled/000-default

