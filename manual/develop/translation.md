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

Additionally, run the following two commands in the seafile-server-latest directory:

* `./seahub.sh python-env python3 seahub/manage.py compilejsi18n -l <lang-code>`
* `./seahub.sh python-env python3 seahub/manage.py collectstatic --noinput -i admin -i termsandconditions --no-post-process`

6\. Restart Seahub to load changes made in django.po and djangojs.po; reload the Markdown editor to check your modifications in the seafile-editor.json file.

### Submit your translation

Please submit translations via Transifex: <https://www.transifex.com/projects/p/seahub/>

Steps:

1. Create a free account on Transifex (https\://www.transifex.com/). 
2. Send a request to join the language translation. 
3. After accepted by the project maintainer, then you can upload your file or translate online.


