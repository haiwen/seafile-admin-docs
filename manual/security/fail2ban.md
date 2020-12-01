# seafile-authentication-fail2ban

#### What is fail2ban ?

Fail2ban is an intrusion prevention software framework which protects computer servers from brute-force attacks. Written in the Python programming language, it is able to run on POSIX systems that have an interface to a packet-control system or firewall installed locally, for example, iptables or TCP Wrapper.

(Definition from wikipedia - https://en.wikipedia.org/wiki/Fail2ban)

#### Why do I need to install this fail2ban's filter  ?

To protect your seafile website against brute force attemps. Each time a user/computer tries to connect and fails 3 times, a new line will be write in your seafile logs (`seahub.log`).

Fail2ban will check this log file and will ban all failed authentications with a new rule in your firewall.

## Installation

#### Change to right Time Zone in seahub_settings.py

***WARNING: Without this your Fail2Ban filter will not work.***

You need to add the following settings to seahub_settings.py but change it to your own time zone.
```
 # TimeZone
 TIME_ZONE = 'Europe/Stockholm'

```

#### Copy and edit jail.local file

***WARNING: this file may override some parameters from your `jail.conf` file***

Edit `jail.local` with :
* ports used by your seafile website (e.g. `http,https`) ;
* logpath (e.g. `/home/yourusername/logs/seahub.log`) ;
* maxretry (default to 3 is equivalent to 9 real attemps in seafile, because one line is written every 3 failed authentications into seafile logs).

#### Create the file `jail.local` in `/etc/fail2ban` with the following content:

```
# All standard jails are in the file configuration located
# /etc/fail2ban/jail.conf

# Warning you may override any other parameter (e.g. banaction,
# action, port, logpath, etc) in that section within jail.local

# Change logpath with your file log used by seafile (e.g. seahub.log)
# Also you can change the max retry var (3 attemps = 1 line written in the
# seafile log)
# So with this maxrety to 1, the user can try 3 times before his IP is banned

[seafile]

enabled  = true
port     = http,https
filter   = seafile-auth
logpath  = /home/yourusername/logs/seahub.log
maxretry = 3
```

#### Create the fail2ban filter file `seafile-auth.conf` in `/etc/fail2ban/filter.d` with the following content:

```
# Fail2Ban filter for seafile
#

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = seaf-server

failregex = Login attempt limit reached.*, ip: <HOST>

ignoreregex = 

# DEV Notes:
#
# pattern :     2015-10-20 15:20:32,402 [WARNING] seahub.auth.views:155 login Login attempt limit reached, username: <user>, ip: 1.2.3.4, attemps: 3
#		2015-10-20 17:04:32,235 [WARNING] seahub.auth.views:163 login Login attempt limit reached, ip: 1.2.3.4, attempts: 3
```


#### Restart fail2ban

Finally, just restart fail2ban and check your firewall (iptables for me) :

```
sudo fail2ban-client reload
sudo iptables -S
```

Fail2ban will create a new chain for this jail.
So you should see these new lines :

```
...
-N fail2ban-seafile
...
-A fail2ban-seafile -j RETURN
```

## Tests

To do a simple test (but you have to be an administrator on your seafile server) go to your seafile webserver URL and try 3 authentications with a wrong password.

Actually, when you have done that, you are banned from http and https ports in iptables, thanks to fail2ban.

To check that :

on fail2ban

```
denis@myserver:~$ sudo fail2ban-client status seafile
Status for the jail: seafile
|- filter
|  |- File list:	/home/<youruser>/logs/seahub.log
|  |- Currently failed:	0
|  `- Total failed:	1
`- action
   |- Currently banned:	1
   |  `- IP list:	1.2.3.4
   `- Total banned:	1
```

on iptables :

```
sudo iptables -S

...
-A fail2ban-seafile -s 1.2.3.4/32 -j REJECT --reject-with icmp-port-unreachable
...
```

To unban your IP address, just execute this command :

```
sudo fail2ban-client set seafile unbanip 1.2.3.4
```

## Note

As three (3) failed attempts to login will result in one line added in seahub.log a Fail2Ban jail with the settings maxretry = 3 is the same as nine (9) failed attempts to login.
