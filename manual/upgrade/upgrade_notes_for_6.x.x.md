# Upgrade notes for 6.x.x

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

From this version, the Wiki module is hidden by default. Users will not be able to turn it on. For compatibility with older versions, it can be turned on by adding the following line to `seahub_settings.py`:

```python
ENABLE_WIKI = True

```

## V6.1.0

### Video Thumbnails

Enable or disable thumbnail for video. ffmpeg and moviepy should be installed first. 
For details, please refer to the [manual](../deploy/video_thumbnails.md).

### OnlyOffice

The system requires some minor changes to support the OnlyOffice document server.
Please follow the instructions [here](../deploy/only_office.md).

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


