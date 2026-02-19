# Translation

## Seahub (Seafile Server 7.1 and above)

### Translate and try locally

1\. Locate the translation files in the seafile-server-latest/seahub directory:

* For Seahub (except Markdown editor): `/locale/<lang-code>/LC_MESSAGES/django.po`   and   `/locale/<lang-code>/LC_MESSAGES/djangojs.po`
* For Markdown editor: `/media/locales/<lang-code>/seafile-editor.json`

For example, if you want to improve the Russian translation, find the corresponding strings to be edited in either of the following three files: 

* `/seafile-server-latest/seahub/locale/ru/LC_MESSAGES/django.po`
* `/seafile-server-latest/seahub/locale/ru/LC_MESSAGES/djangojs.po`
* `/seafile-server-latest/seahub/media/locales/ru/seafile-editor.json`

If there is no translation for your language, create a new folder matching your language code and copy-paste the contents of another language folder in your newly created one. (Don't copy from the 'en' folder because the files therein do not contain the strings to be translated.) 

2\. Edit the files using an UTF-8 editor.

3\. Save your changes. 

4\. (Only necessary when you created a new language code folder) Add a new entry for your language to the language block in the `/seafile-server-latest/seahub/seahub/settings.py` file and save it. 

```
LANGUAGES = (
    ...
    ('ru', 'Русский'),
    ...
)

```

5\. (Only necessary when you edited either django.po or djangojs.po) Apply the changes made in django.po and djangojs.po by running the following two commands in `/seafile-server-latest/seahub/locale/<lang-code>/LC_MESSAGES`:

* `msgfmt -o django.mo django.po`
* `msgfmt -o djangojs.mo djangojs.po`

**Note:** msgfmt is included in the gettext package.

Additionally, run the following two commands in the seafile-server-latest directory:

* `./seahub.sh python-env python3 seahub/manage.py compilejsi18n -l <lang-code>`
* `./seahub.sh python-env python3 seahub/manage.py collectstatic --noinput -i admin -i termsandconditions --no-post-process`

6\. Restart Seahub to load changes made in django.po and djangojs.po; reload the Markdown editor to check your modifications in the seafile-editor.json file.

### Submit your translation

Please submit translations via Transifex: <https://explore.transifex.com/haiwen/seahub/>

Steps:

1. Create a free account on Transifex (https://www.transifex.com/). 
2. Send a request to join the language translation. 
3. After accepted by the project maintainer, then you can upload your file or translate online.

## FAQ

### FileNotFoundError

`FileNotFoundError` occurred when executing the command `manage.py collectstatic`.

```log
FileNotFoundError: [Errno 2] No such file or directory: '/opt/seafile/seafile-server-latest/seahub/frontend/build'
```

Steps:

1. Modify `STATICFILES_DIRS` in `/opt/seafile/seafile-server-latest/seahub/seahub/settings.py` manually

    ```python
    STATICFILES_DIRS = (
        # Put strings here, like "/home/html/static" or "C:/www/django/static".
        # Always use forward slashes, even on Windows.
        # Don't forget to use absolute paths, not relative paths.
        '%s/static' % PROJECT_ROOT,
    #    '%s/frontend/build' % PROJECT_ROOT,
    )
    ```

2. Execute the command

    ```sh
    ./seahub.sh python-env python3 seahub/manage.py collectstatic --noinput -i admin -i termsandconditions --no-post-process
    ```

3. Restore `STATICFILES_DIRS` manually

    ```python
    STATICFILES_DIRS = (
        # Put strings here, like "/home/html/static" or "C:/www/django/static".
        # Always use forward slashes, even on Windows.
        # Don't forget to use absolute paths, not relative paths.
        '%s/static' % PROJECT_ROOT,
        '%s/frontend/build' % PROJECT_ROOT,
    )

4. Restart Seahub

    ```sh
    ./seahub.sh restart
    ```

This issue has been fixed since version 11.0
