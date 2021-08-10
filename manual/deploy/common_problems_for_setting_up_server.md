# Common Problems for Setting up Server


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


#### Failed to upload/download file online

* Check your SERVICE_URL setting in ccnet.conf and FILE_SERVER_ROOT setting in seahub_settings.py
* Make sure you firewall for seafile fileserver is opened.
* Using chrome/firefox debug mode to find which link is given when click download button and what's wrong with this link


#### Seafile with Apache / HTTPS has text only (no CSS formatting / images)

The media folder (Alias location identified in /etc/apache2/sites-enabled/000-default (Ubuntu) has inappropriate permissions

Solutions:

1. Run installation script as non-root user
2. Copy /media folder to var/www/ and edit the Alias location in /etc/apache2/sites-enabled/000-default

