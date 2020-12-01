# Upgrade notes

These notes give additional information about changes.
Please always follow the [main upgrade guide](./upgrade.md).

## Summary

* [Upgrade notes for V6.x.x](#upgrade-notes-v6.x.x)
* [Upgrade notes for V5.x.x](#upgrade-notes-v5.x.x)
* [Upgrade notes for V4.x.x](#upgrade-notes-v4.x.x)

*This documentation is just done from V4 + !*

------

# Upgrade Notes V6.x.x

## Important release changes

From this version, the Wiki module is hidden by default. Users will not be able to turn it on. For compatibility with older versions, it can be turned on by adding the following line to `seahub_settings.py`:

```python
ENABLE_WIKI = True
```

---

## V6.1.0

### Video Thumbnails

Enable or disable thumbnail for video. ffmpeg and moviepy should be installed first. 
For details, please refer to the [manual](./video_thumbnails.md).

### OnlyOffice
The system requires some minor changes to support the OnlyOffice document server.  
Please follow the instructions [here](./only_office.md).

### Pip Pillow upgrade

```
# for Ubuntu 16.04
sudo apt-get install libjpeg-dev
pip install --upgrade Pillow
# If the pillow installation fails you may install
# "build-dep python-imaging" instead of just "libjpeg-dev"

# for Debian 8
apt-get install libjpeg-dev
pip install --upgrade Pillow

# If the pillow installation fails you may install
# "build-dep python-imaging" instead of just "libjpeg-dev"

# for Centos 7
sudo yum install libjpeg-dev
pip install --upgrade Pillow
```

### Seahub does not start

In case Seahub does not start after the upgrade, install python-requests.

```bash
sudo apt-get install python-requests
```

---

## V6.0.0 - V6.0.9

There are no other special instructions.

---

# Upgrade Notes V5.x.x

## Important release changes

__In Seafile 5.0, we moved all config files to the folder ```/seafile-root/conf```, including:__

- seahub_settings.py -> conf/seahub_settings.py
- ccnet/ccnet.conf -> conf/ccnet.conf
- seafile-data/seafile.conf -> conf/seafile.conf
- [pro only] pro-data/seafevents.conf -> conf/seafevents.conf

------

## V5.1.4

**Python upgrade**
If you upgrade to 5.1.4+, you need to install the python 3 libs:

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

---

## V5.0.0 - V5.1.3

Nothing to be installed/changed.

------

# Upgrade Notes V4.x.x
These notes just give additional information about changes within each major version.  
Please always follow the [main installation guide](./upgrade.md).

## Important release changes

- [Thumbnail string to number](##V4.3.0)

---

## V4.3.1 - V4.4.6

There are no other special instructions.

---

## V4.3.0

Change the setting of THUMBNAIL_DEFAULT_SIZE from string to number in ```seahub_settings.py```:

Use ```THUMBNAIL_DEFAULT_SIZE = 24```, instead of ```THUMBNAIL_DEFAULT_SIZE = '24'```.

---

## V4.2.0 - V4.2.3

**Note when upgrading to 4.2:**  
If you deploy Seafile in a non-root domain, you need to add the following extra settings in ```seahub_settings.py```:
```
COMPRESS_URL = MEDIA_URL
STATIC_URL = MEDIA_URL + '/assets/'
```

---

## V4.0.0 - V4.1.2

There are no other special instructions.
