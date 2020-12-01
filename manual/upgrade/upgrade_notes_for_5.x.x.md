# Upgrade notes for 5.x.x

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

**In Seafile 5.0, we moved all config files to the folder \*\***`/seafile-root/conf`\***\*, including:**

* seahub_settings.py -> conf/seahub_settings.py
* ccnet/ccnet.conf -> conf/ccnet.conf
* seafile-data/seafile.conf -> conf/seafile.conf
* \[pro only] pro-data/seafevents.conf -> conf/seafevents.conf

## V5.1.4

**Python upgrade**
If you upgrade to 5.1.4+, you need to install the python-urllib3:

```
# for Ubuntu 16.04
sudo apt-get install python-urllib3

# for Debian 8
apt-get install python-urllib3

# for Centos 7
sudo yum install python-urllib3

# for Arch Linux
pacman -Sy python2-urllib3

```


