# Seahub customization

## Customize Seahub Logo and CSS

Create customize folder

=== "Deploy in Docker"
    ```sh
    mkdir -p /opt/seafile-data/seahub/media/custom
    ```
=== "Deploy from binary packages"
    ```sh
    mkdir /opt/seafile/seafile-server-latest/seahub/media/custom
    ```

During upgrading, Seafile upgrade script will create symbolic link automatically to preserve your customization.

### Customize Logo

Add your logo file to `custom/`

Overwrite `LOGO_PATH` in `seahub_settings.py`

```py
LOGO_PATH = 'custom/mylogo.png'
```

Default width and height for logo is 149px and 32px, you may need to change that according to yours.

```python
LOGO_WIDTH = 149
LOGO_HEIGHT = 32
```

### Customize Favicon

Add your favicon file to `custom/`

Overwrite `FAVICON_PATH` in `seahub_settings.py`

```py
FAVICON_PATH = 'custom/favicon.png'
```

### Customize Seahub CSS

Add your css file to `custom/`, for example, `custom.css`

Overwrite `BRANDING_CSS` in `seahub_settings.py`

```py
BRANDING_CSS = 'custom/custom.css'
```

## Customize help page

=== "Deploy in Docker"
    ```sh
    mkdir -p /opt/seafile-data/seahub/media/custom/templates/help/
    cd /opt/seafile-data/seahub/media/custom
    cp ../../help/templates/help/base.html templates/help/
    ```
=== "Deploy from binary packages"
    ```sh
    mkdir /opt/seafile/seafile-server-latest/seahub/media/custom/templates/help/
    cd /opt/seafile/seafile-server-latest/seahub/media/custom
    cp ../../help/templates/help/base.html templates/help/
    ```

For example, modify the `templates/help/base.html` file and save it. You will see the new help page.

!!! note
    There are some more help pages available for modifying, you can find the list of the html file [here](https://github.com/haiwen/seahub/tree/master/seahub/help/templates/help)


## Add an extra note in sharing dialog

You can add an extra note in sharing dialog in seahub_settings.py

```
ADDITIONAL_SHARE_DIALOG_NOTE = {
    'title': 'Attention! Read before shareing files:',
    'content': 'Do not share personal or confidential official data with **.'
}
```

Result:

![](../images/additional-share-dialog-note.png)

## Add custom navigation items

Since Pro 7.0.9, Seafile supports adding some custom navigation entries to the home page for quick access. This requires you to add the following configuration information to the `conf/seahub_settings.py` configuration file:

```
CUSTOM_NAV_ITEMS = [
    {'icon': 'sf2-icon-star',
     'desc': 'Custom navigation 1',
     'link': 'https://www.seafile.com'
    },
    {'icon': 'sf2-icon-wiki-view',
     'desc': 'Custom navigation 2',
     'link': 'https://www.seafile.com/help'
    },
    {'icon': 'sf2-icon-wrench',
     'desc': 'Custom navigation 3',
     'link': 'http://www.example.com'
    },
]
```

!!! note
    The `icon` field currently only supports icons in Seafile that begin with `sf2-icon`. You can find the list of icons [here](https://github.com/haiwen/seahub/blob/master/media/css/seahub.css)

Then restart the Seahub service to take effect.

Once you log in to the Seafile system homepage again, you will see the new navigation entry under the `Tools` navigation bar on the left.


## Add more links to about dialog

```
ADDITIONAL_ABOUT_DIALOG_LINKS = {
    'seafile': 'https://example.seahub.com/seahub',
    'dtable-web': 'https://example.seahub.com/dtable-web'
}
```

Result:

![](../images/additional-about-dialog-links.png)
