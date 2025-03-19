# Seafile Server Changelog

> You can check Seafile release table to find the lifetime of each release and current supported OS: <https://cloud.seatable.io/dtable/external-links/a85d4221e41344c19566/?tid=0000&vid=0000>


## 12.0

**Upgrade**

Please check our document for how to upgrade to [12.0](../upgrade/upgrade_notes_for_12.0.x.md)

### 12.0.10 (2025-03-03)

* [fix] Fix seaf-fuse support
* [fix] Fix "save to" button in external link
* [fix] Search library text in system admin page is incorrect  
* [fix] Fix library path displays issue in read-only shared
* Improve icons for creating Wiki and inviting links
* [fix] Fix a bug in Collabora integration: Interface in English despite Seafile interface in French

### 12.0.9 (2025-02-14)

* Improve consistency of format of logs
* [fix] Thumbnail server does not preserve ICC profiles, resulting in washed out colors
* [fix] A few small UI fixes and improvements


### 12.0.7 (2025-01-08)

* [fix] Some UI improvements and fixes
* [Wiki] Some UI improvements and fixes
* Clean inconsistent format in logs
* [fix] Fix WebDAV upload "0 Byte Files" issue

### 12.0.6 beta (2024-12-19)

* [fix] Fix seafevents not started
* Update translation
* Some UI fixes

### 12.0.4 beta (2024-11-21)

* A redesigned Web UI
* SeaDoc is now stable, providing online notes and documents feature
* A new wiki module
* A new trash mechanism, that deleted files will be recorded in database for fast listing
* The password strength level is now calculated by algorithm. The old USER_PASSWORD_MIN_LENGTH, USER_PASSWORD_STRENGTH_LEVEL is removed. Only USER_STRONG_PASSWORD_REQUIRED is still used.
* ADDITIONAL_APP_BOTTOM_LINKS is removed. Because there is no buttom bar in the navigation side bar now.
* SERVICE_URL and FILE_SERVER_ROOT are removed. SERVICE_URL will be calculated from SEAFILE_SERVER_PROTOCOL and SEAFILE_SERVER_HOSTNAME in `.env` file.
* `ccnet.conf` is removed. Some of its configuration items are moved from `.env` file, others are read from items in `seafile.conf` with same name.
* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.
* Support online GC 


## 11.0

**Upgrade**

Please check our document for how to upgrade to [11.0](../upgrade/upgrade_notes_for_11.0.x.md)


### 11.0.12 (2024-08-14)

* Update translations

### 11.0.11 (2024-08-07)

* [fix] [important] Fix a security bug in WebDAV


### 11.0.10 (2024-08-06)

Seafile

* [fix] Use user's name in reset password email instead of internal ID
* [fix] Fix SeaDoc incompatible with go fileserver
* [fix] Fix invited guest cannot be revoke
* [fix] Fix keyerror when using backup code in two-factor auth
* [fix] Do not print warning in seaf-server.log when a LDAP user login


### 11.0.9 (2024-05-30)

Seafile

* Improve accessibility
* Support open ODG files with LibreOffice (Collabora Online)
* Support showing last modified time for folders in WebDAV
* [fix] Fix "remember me" in 2FA

SDoc editor 0.8

* Support automatically adjusting table width to fit page width
* Improve comments feature
* Improve documents shown on mobile
* More UI fixes and improvements


### 11.0.8 (2024-04-22)

* Fix a bug in generating sharing links

### 11.0.7 (2024-04-18)

Seafile

* Support log rotate for golang file server and notification server
* Update UI for upload link
* Support OnlyOffice version feature
* Show files' original path in the trash

SDoc editor 0.7

* Improve file comment feature
* Improve file diff showing
* Support print a document
* Improve table editing


### 11.0.6 (2024-03-14)

Seafile

* Fix column view is limited to 100 items
* Fix LDAP user login for WebDAV
* Remove the configuration item "ENABLE_FILE_COMMENT" as it is no longer needed
* Enable copy/move files between encrypted and non-encrypted libraries
* Forbid creating libraries with Emoji in name
* Fix some letters in the file name do not fit in height in some dialogs
* Some other UI fixes and improvements
* Fix a performance issue in sending file updates report

SDoc editor 0.6

* Support convert docx file to sdoc file
* Support Markdown format in comments
* Support drag rows/columns in table element and other improvements for table elements
* Other UI fixes and improvements

### 11.0.5 (2024-01-31)

Seafile

* Fix captcha showing issue


### 11.0.4 (2024-01-26)

Seafile

* Add move dir/file, copy dir/file, delete dir/file, rename dir/file APIs for library token based API
* Support preview of JFIF image format
* Use user's current language when create Office files in OnlyOffice
* More UI fixes and improvements

SDoc editor 0.5

* Support convert sdoc to docx format
* Improve UX for internal document linking
* Support icons in callout element
* Add Search/Replace feature
* More UI fixes and improvements

### 11.0.3 (2023-12-19)

Seafile

* Use file type icon as favicon for file preview pages
* More UI fixes and improvements
* [fix] seafdav.conf workers parameters does not to be used

SDoc editor 0.4

* Add templates with predefined stypes for tables
* Support combining table cells
* Add callout element
* Support drag and drop elements
* Improve file comments
* Improve file history display by grouping history items
* More UI fixes and improvements


### 11.0.2 (2023-11-20)

Seafile

* Update folder icon
* The activities page support filter records based on modifiers
* Add indicator for folders that has been shared out
* Some small UI fixes
* [fix] Fix some small bugs in golang file server
* [fix] Fix LDAP users cannot login via desktop client
* Add login ID field when exporting users in admin panel

SDoc editor 0.3

* Improved file comment feature
* Improved revision and review feature
* Support file tags
* Better support editing list/table/code/image element
* Support getting link for header element


### 11.0.1 beta (2023-10-18)

Seafile

* Improve UI of notifications dialog
* Improve UI of dropdown menus for libraries and files
* Improve UI for file tags
* Remove file comment features as they are used very little

SDoc editor 0.2

* All major elements like tables, lists are now supported
* The editor is basically stable to use. Everyone is welcome to try it out.

### 11.0.0 beta (cancelled)

* Use a virtual ID to identify a user
* LDAP login update
* SAML/Shibboleth/OAuth login update
* Update Django to version 4.2
* Update SQLAlchemy to version 2.x
* Improve UI of PDF view page
* Add seafevents component


## 10.0

**Upgrade**

Please check our document for how to upgrade to [10.0](../upgrade/upgrade_notes_for_10.0.x.md).

### 10.0.1 (2023-04-11)

* Support generating multiple share links for a file and a folder
* [fix] Fix a bug in golang file server when zip-downloading a folder in encrypted library
* [fix] Fix a bug in upgrading script when there is no configuration for Nginx
* Video player support changing playback speed
* [fix] Fix a few bugs in notification server


### 10.0.0 beta (2023-02-22)

* Update Python dependencies and support Ubuntu 22.04 and Debian 11
* Add a new notification server (document will be provided later)
* Update WebDAV password to use one-way hash
* Remove SQL sub queries to improve SQL query speed in seaf-server
* Show number of shared users/groups if any when deleting a folder
* Support online playing of .wav files


## 9.0

### 9.0.10 (2022-12-07)

* Admin list all users API now return last_login and last_access_time
* [fix] Fix a bug in displaying markdown file in sharing link
* [fix] Fix notification mails are sent to inactive users
* [fix] Fix viewing a file in an old snapshot leads to server hickup
* [fix] Fix an HTTP/500 "Internal server error" when the user sets password containing non-latin characters for sharing links
* [fix] Fix "document convertion failed” error visiting a shared document with preview only
* [fix] Fix memory leak when block cache is enabled
* Enable 'zoom in/out by pinch' for mobile in pdf file view page
* [fix] Prevent system admin creating libraries with invalid name in admin panel
* Improve performance in golang file server

### 9.0.9 (2022-09-22)

* [fix] Fix a memory leak problem
* [fix] Fix a bug that will lead to seaf-fsck crash
* [fix] Fix a stored XSS problem for library names
* [fix] Disable open a file in OnlyOffice for encrypted libraries when open from trash

### 9.0.8 (2022-09-07)

* [fix] Fix a UI bug in sending sharing link by email
* [fix] Markdown editor does not properly filter javscript URIs from the href attribute, which results in stored XSS
* [fix] Fix a bug in OCM sharing
* [fix] Fix a bug in un-linking a device in admin panel
* [fix] Adding URL security check in `/accounts/login` redirect by `?next=` parameter


### 9.0.7 (2022-08-10)

Note: included lxml library is removed for some compatiblity reason. The library is used in published libraries feature and WebDAV feature. You need to install lxml manually after upgrade to 9.0.7. Use command `pip3 install lxml` to install it.

* A page in published libraries is rendered at the server side to improve loading speed.
* Upgrade Django from 3.2.6 to 3.2.14
* Fix a bug in collaboration notice sending via email to users' contact email
* Support OnlyOffice oform/docxf files
* Improve user search when sharing a library
* Admin panel support searching a library via ID prefix
* [fix] Fix preview PSD images
* [fix] Fix a bug that office files can't be opened in sharing links via OnlyOffice
* [fix] Go fileserver: Folder or File is not deletable when there is a spurious utf-8 char inside the filename


### 9.0.6 (2022-06-22)

* Show table of contents in Markdown sharing link
* Check if quota exceeded before file uploading in upload sharing link
* Support import group member via contact email


### 9.0.5 (2022-05-13)

* [fix] Fix a bug that sometimes a shared subfolder is unshared automatically by database access error
* [fix] Fix a bug in work with Python 3.10+
* [fix] Fix a bug in smart link redict to the file page
* [fix] Fix a UI bug when drag and drop a file
* [fix] Fix zip downloading a folder not having .zip suffix when using golang file server
* Improve UI for file tags
* Show file tags in sharing links
* Improve UI of file comments
* [fix] Fix permission check in deleting/editing a file comment
* Remove the feature of related files as it is not used
* Support editing of expire time for sharing links
* Improve SQL performance when deleting a library
* Show ISO date and time in file history page instead of showing relative time
* Add "Visit related snapshot" in the dropdown menu of an entry in file history

### 9.0.4 (2022-02-21)

* [fix] Fix a UI bug in file moving/copying dialog
* Support admin enforcing a strong password in WebDAV secret
* [fix] Fix WebDAV error while filename contains special chars

### 9.0.3 (2022-02-15)

* Enable deleting fs objects in GC
* Users can save files or folders in shared folder link to their own libraries
* [fix] Fix language in calendar UI component used when picking date in sharing dialog
* [fix] Fix markdown file print
* Improve UI of file moving/copying dialog to show folders with long names
* Expand to the current folder when open file moving/copying dialog
* [fix] Fix a bug in golang file server log rotate support
* [fix] Fix a bug in folder download-link and try to download files/folders as zip using golang file server
* Show current number of shared users and groups when deleting a library
* [fix] Fix support for customizing of favicon
* [fix] Fix printing support of Markdown file
* [fix] Fix zip-downloading in sharing links when golang file server is used

### 9.0.2 (2021-12-10)

* Fix OnlyOffice/Collabora integration when golang http server
* Enable showing password for encrypted sharing links

### 9.0.1 beta (2021-11-20)

* Fix OnlyOffice integration

### 9.0.0 beta (2021-11-11)

* Upgrade Django to 3.2
* Rewrite HTTP service in seaf-server with golang and move it to a separate component (turn off by default)
* Upgrade PDFjs to new version, support viewing of password protected PDF
* Use database to store OnlyOffice cache keys
* Supporting converting files like doc to docx using OnlyOffice for online editing
* Move SERVICE_URL configuration from ccnet.conf to seahub_settings.py

The new file-server written in golang serves HTTP requests to upload/download/sync files. It provides three advantages:

* The performance is better in a high-concurrency environment and it can handle long requests. Now you can sync libraries with large number of files.
* Now file zipping and downloading can be done simutaneously. When zip downloading a folder, you don't need to wait until zip is done.
* Support rate control for file uploading and downloading.

You can turn golang file-server on by adding following configuration in seafile.conf

```
[fileserver]
use_go_fileserver = true
```


## 8.0

Please check our document for how to upgrade to [8.0](../upgrade/upgrade_notes_for_8.0.x.md).

### 8.0.8 (2021/12/06)

* [fix] Fix a security issue in token check in file syncing
* [fix] Fix URL encoding problem when view a file's history for files with special characters in file name.

### 8.0.7 (2021/08/09)

* Improve performance for listing deleted files in trash
* [fix] Fix FORCE_PASSWORD_CHANGE does not force the new user to change the password if the user is added by admin
* [fix] Fix setting a webdav password when 2FA enabled
* [fix] Fix search in a shared sub-folder
* [fix] Remove watermark shown in Collabora integration

### 8.0.6 (2021/07/14)

* [fix] Fix a cache problem in OnlyOffice integration when automatically saving is used
* Admin can delete devices in the admin panel
* [fix] Once a user quota have been set, I can not set it back to 0 (unlimited)
* [fix] Fix collabora integration
* User's can manage his/her Web API Auth Token in profile page
* A group admin can now leave a group
* [fix] Fix Lazy loading / pagination breaks image viewer (https://forum.seafile.com/t/lazy-loading-pagination-breaks-image-viewer/14655)

### 8.0.5 (2021/05/14)

* Add "Open via Client" button in file view page
* Add an admin API to change a user's email
* [fix] Fix a bug in seaf-gc
* [fix] Fix wrong links of files in library history details dialog
* [fix] Fix deleting libraries without owner in admin panel
* [fix] Fix a XSS problem in notification
* [fix] Fix JWT token support in OnlyOffice integration
* [fix] Fix sometimes webdav cache files are not cleaned

### 8.0.4 (2021/03/25)

* [fix] Fix a permission denial problem in OCM, if a library is shared to more than two users in another server
* [fix] Fix a bug in password protected upload link
* [fix] Fix running seafile-controller with "seafile-controller -t" 
* [fix] Fix user search in "Transfering a library" dialog
* Add "Open via Client" button in file view page
* Add an admin API to change a user's email

### 8.0.3 (2021/01/27)

* Users can use secret key to access WebDAV after enabling two-factor authentication
* Fix fuse
* Fix navigation side panel in public library on mobile
* Improve UI of file search
* Add QR code for sharing links
* Fix OnlyOffice integration when JWT is enabled

### 8.0.2 (2021/01/04)

* Fix LDAP problem
* Fix upgrade script

### 8.0.1 beta (2021/01/04)

* Update translations for help pages
* Add missing upgrade script
* Add open cloud mesh feature

### 8.0.0 beta (2020/11/27)

* Support searching file in a library
* Rewrite upload link page to use React technology
* Improve GC performance
* Upgrade Django to 2.2 version
* Remove ccnet-server component
* Update help page
* Release v4 encrypted library format to enhance security for v3 encrypted format

## 7.1

**Feature changes**

Progresql support is dropped as we have rewritten the database access code to remove copyright issue.

**Upgrade**

Please check our document for how to upgrade to [7.1](../upgrade/upgrade_notes_for_7.1.x.md).

### 7.1.5 (2020/09/22)

* \[fix] Fix a bug in returned group library permission for  SeaDrive client
* \[fix] Fix files preview using OnlyOffice in public shared links 
* Support pagination when listing libraries in a group
* Update wsgidav used in WebDAV
* \[fix] Fix WebDAV failed login via WebDAV secret
* \[fix] Fix WebDAV error if a file is moved immediately after uploading
* Remove redundent logs in seafile.log
* \[fix] Fix "save to..." in share link
* Add an option to show a user's email in sharing dialog (ENABLE_SHOW_CONTACT_EMAIL_WHEN_SEARCH_USER)
* Add database connection pool to reduce database connection usage
* Enable generating internal links for files in an encrypted library
* Support setting the expire date time of a share link to a specific date time
* GC add --id-prefix option to scan a specific range of libraries
* fsck add an option to not check block integrity to speed up scanning
* \[fix] ccnet no longer listen on port 10001

### 7.1.4 (2020/05/19)

* \[fix] Fix page error in "System Admin-> Users -> A User -> Groups"
* \[fix] Fix listing LDAP imported users when number of users is greater than 500
* Support selecting and downloading multiple files in a sharing link
* Show share link expiration time in system admin
* \[fix] Fix file download links in public libraries
* Other UI fixes

### 7.1.3 (2020/03/26)

* Support sort libraries by size and number of files in admin panel
* Support sort users by used storage in admin panel
* \[fix] Fix Markdown print for markdown with more than 1 page
* Other UI fixes

### 7.1.2 beta (2020/03/05)

* \[fix] Fix HTTP/2 support
* Markdown page can now be printed using browser's "Print..."
* Add zoom buttons for PDF page
* Add sort function to directory share link page
* Add support for JSON web tokens in OnlyOffice integration
* UI improvements for pages in admin panel

### 7.1.1 beta (2019/12/23)

* \[fix] Fix Gunicorn warning
* \[fix] Fix SQLite upgrade script
* \[fix] Fix Seahub can't started problem on Debian 10
* \[fix] For for Excel and PPT, the default fonts are Chinese font sets.
* Some other UI fixes and improvements

### 7.1.0 beta (2019/12/05)

* Rewrite the system admin pages with React
* Upgrade to Python3
* Add library API Token, you can now generate API tokens for a library and use them in third party programs.
* Add a feature abuse report for reporting abuse for download links.

## 7.0

**Feature changes**

In version 6.3, users can create public or private Wikis. In version 7.0, private Wikis is replaced by column mode view. Every library has a column mode view. So users don't need to explicitly create private Wikis.

Public Wikis are now renamed to published libraries.

**Upgrade**

Just follow our document on major version upgrade. No special steps are needed.

### 7.0.5 (2019/09/23)

* \[fix] Fix '\\n' in system wide notification will lead to blank page
* \[fix] Remove all metadata in docx template
* \[fix] Fix redirection after login
* \[fix] Fix group order is not alphabetic
* \[fix] Fix download button in sharing link
* Mobile UI Improvement (Now all major pages can be used in Mobile smoothly)
* Add notification when a user try to leave a page during file transfer
* Add UI waiting notification when resetting a user's password in admin panel
* Add generating internal link (smart-link) for folders
* \[fix] Fix file drag and drop in IE and Firefox
* Improve UI for file uploading, support re-upload after error
* \[fix] Fix devices login via Shibboleth not show in devices list
* Support of OnlyOffice auto-save option
* \[fix] Fix zip download when user selecting a long list of files
* Other UI fixes

### 7.0.4 (2019/07/26)

* Fix avatar problem when deployed under non-root domain
* Add get internal link in share dialog
* Fix newly created DOCX files are not empty and have a Chinese font set as default font
* Fix system does not send email to new user when adding new user in system admin
* Fix thumbnail for TIFF files
* Fix direct download link for sharing links

### 7.0.3 (2019/07/05)

* UI Improvements and fixes
* Fix file upload button with Safari, IE edge
* Fix compatibility with "Open library in web" from the old version desktop client
* Support "." in group name
* Add back "send link" for upload links
* Add back grid view for folder sharing links
* Fix preview for PSD, TIFF files
* Fix deleting of favorate items when they are shared items but the sharing are revoked
* Fix avatar broken problem when using a non-stardard port
* Fix resumable file uploading

### 7.0.2 (2019/06/13)

* UI fixes
* Support index.md in published library
* Fix IE Edge support

### 7.0.1 beta (2019/05/31)

* \[fix] Fix database upgrade problem
* \[fix] Fix WebDAV can't be started
* \[fix] Some UI fixes

### 7.0.0 beta (2019/05/23)

* Upgraded Web UI with React framework. The look and feel of the new UI is much better.
* Improved Markdown editor
* Add columns view mode (tree view like in the Windows Explorer)
* Add context menu to manipulate files
* Move files via drag and drop
* Redesigned file tags
* Support editing share link permission after creating a link

## 6.3

In version 6.3, Django is upgraded to version 1.11. Django 1.8, which is used in version 6.2, is deprecated in 2018 April.

With this upgrade, the fast-cgi mode is no longer supported. You need to config Seafile behind Nginx/Apache in WSGI mode.

The way to run Seahub in another port is also changed. You need to modify the configuration file `conf/gunicorn.conf` instead of running `./seahub.sh start <another-port>`.

Version 6.3 also changed the database table for file comments, if you have used this feature, you need migrate old file comments using the following commends after upgrading to 6.3:

```
./seahub.sh python-env seahub/manage.py migrate_file_comment

```

> Note, this command should be run while Seafile server is running.

### 6.3.4 (2018/09/15)

* \[fix] Fix a security issue in Shibboleth authentication
* \[fix] Fix sometimes Web UI will not autoload a >100 item directory view

### 6.3.3 (2018/09/07)

* Add generating of internal links
* Support copy a file to its own parent folder, creating a file with a suffix like test-1.docx
* Support setting the language list
* Redirect '/shib-login' to '/sso'
* Change "Unknown error" to "network error" when uploading failed caused by network error
* \[fix] Fix groups not shown in system admin panel
* Support files be manually saved in OnlyOffice
* Improve performance when getting users quota usage
* Improve Markdown editor
* The new Wiki feature is ready
* Update Django to 1.11.11

### 6.3.2 (2018/07/09)

* \[fix] Fix error when public wiki be viewed by anonymous users
* Remove department field in users' profile page
* \[fix] Print warning instead of exit when there are errors in database table upgrade
* \[fix] Send notification to the upload link creator after there are files uploaded
* \[fix] Fix customize css via "custom/custom.css"
* \[api] return the last modifier in file detail API
* \[fix] Fix ZIP download can't work in some languages

### 6.3.1 (2018/06/24)

* Allow fullscreen presentation when view ppt(x) file via CollaboraOffice.
* Support mobile UI style when view file via OnlyOffice.
* Some UI improvement.
* Show terms and condition link if terms and condition is enabled
* \[fix] Update OnlyOffice callback func (save file when status is 6).
* \[fix] Show library’s first commit’s desc on library history page.
* \[fix] Check if is an deleted library when admin restore a deleted library.
* \[fix] Removed dead 'quota doc' link on user info popup.
* \[fix] Fix bug of OnlyOffice file co-authoring.
* \[api] Add starred field to file detail api.
* Use ID instead of email on sysadmin user page.
* \[fix] Fix database upgrade problems
* \[fix] Fix support for sqlite3
* \[fix] Fix crash when seaf-fsck, seaf-gc receive wrong arguments

### 6.3.0 beta (2018/05/26)

* UI Improvements: moving buttons to top bar, improve scrolling in file/library list
* Update Django to 1.11, remove fast-cgi support
* Update jQuery to version 3.3.1
* Update pdf.js
* Add invite people link to share dialog if the feature is enabled
* Remove login log after delete a user
* \[admin] Support customize site title, site name, CSS via Web UI
* \[beta] Wiki, users can create public wikis
* Add an option to define the listening address for WSGI mode
* \[fix] Fix a bug that causing seaf-fsck crash
* \[fix] Fix support for uploading folder via ‘Cloud file browser’
* \[fix] Cancel Zip download task at the server side when user close zip download dialog
* Other fixes

## 6.2

From 6.2, It is recommended to use WSGI mode for communication between Seahub and Nginx/Apache. Two steps are needed if you'd like to switch to WSGI mode:

1. Change the config file of Nginx/Apache.
2. Restart Seahub with `./seahub.sh start` instead of `./seahub.sh start-fastcgi`

The configuration of Nginx is as following:

```
location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log;
         error_log       /var/log/nginx/seahub.error.log;
    }

```

The configuration of Apache is as following:

```
    # seahub
    SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
    ProxyPass / http://127.0.0.1:8000/
    ProxyPassReverse / http://127.0.0.1:8000/

```

### 6.2.5 (2018/01/23)

* \[fix] Fix OAuth bug
* \[fix] Improve the performance of returning a user's all group libraries
* \[new] Support customize the list of groups that a user can see when sharing a library

### 6.2.4 (2018/01/16)

* \[new] Add the feature "remember this device" after two-factor authentication
* \[new] Add option to notify the admin after new user registration (NOTIFY_ADMIN_AFTER_REGISTRATION)
* \[fix] Fix a bug in modify permission for a a shared sub-folder
* \[fix] Fix support for PostgreSQL
* \[fix] Fix a bug in SQLite database support
* \[fix] Fix support for uploading 500+ files via web interface (caused by API rate throttle)
* \[improve, ui] Add transition to show/hide of feedback messages.
* \[improve] Improve performance of file history page.
* \[improve] Show two file history records at least.
* \[fix] show shared sub-folders when copy/move file/folder to “Other Libraries”.
* \[fix] Remove the white edge of webpage when previewing file via OnlyOffice.
* \[fix] Don’t check if user exists when deleting a group member in admin panel.
* \[fix, oauth] Don’t overwrite public registration settings when login a nonexistent user.
* Other UI improvements.

### 6.2.3 (2017/11/15)

* Support OAuth.
* WSGI uses 5 processors by default instead of 3 processors each with 5 threads
* \[share] Add "click to select" feature for download/upload links.
* \[admin] Show/edit contact email in admin panel.
* \[admin] Show upload links in admin panel.
* \[fix] Fix Shibboleth login redirection issue, see <https://forum.seafile.com/t/shared-links-via-shibboleth/4067/19>
* \[fix] In some case failed to unshare a folder.
* \[fix] LDAP search issue.
* \[fix] Fix Safari downloaded file names are encoded like 'test-%2F%4B.doc' if it contains special characters.
* \[fix] Disable client encrypt library creation when creating encrypt library is disabled on server.

### 6.2.2 (2017/09/25)

* \[fix] Fix register button can't be clicked in login page
* \[fix] Fix login_success field not exist in sysadmin_extra_userloginlog

### 6.2.1 (2017/09/22)

* \[fix] Fix upgrade script for SQLite database
* Add Czech language
* \[ui] Move password setting to a separate section
* \[ui] Add divider to file operation menu
* \[ui] Use high DPI icon in favorites page
* \[ui] Focus on password fields by default
* \[ui] Show feedback message when restore a library to a snapshot
* \[fix] Don't import settings in seafile.conf to database

### 6.2.0 beta (2017/09/14)

* Redesign login page, adding a background image.
* Add two factor authentication
* Clean the list of languages
* Add the ability of tagging a snapshot of a library (Use `ENABLE_REPO_SNAPSHOT_LABEL = True` to turn the feature on)
* \[admin] Add an option to enable users to share a library to any groups in the system.
* Use WSGI as the default mode for deploying Seahub.
* Add a field Reference ID to support changing users primary ID in Shibboleth or LDAP
* Improved performance of loading library list
* Support adding a custom user search function (<https://github.com/haiwen/seafile-docs/commit/115f5d85cdab7dc272da81bcc8e8c9b91d85506e>)
* Other small UI improvements

## 6.1

If you upgrade from 6.0 and you'd like to use the feature video thumbnail, you need to install ffmpeg package:

```
# for ubuntu 16.04
apt-get install ffmpeg
pip install pillow moviepy

# for Centos 7
yum -y install epel-release
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
yum -y install ffmpeg ffmpeg-devel
pip install pillow moviepy

```

### 6.1.2 (2017.08.15)

* Use user's language as lang setting for OnlyOffice
* Improve performance for getting user’s unread messages
* Fix error when uploading files to system default library template
* Users can restore their own deleted libraries
* Improve performance when move or copy multiple files/folders
* Add “details” for libraries, folders and files to show information like how many files in a library/folder
* \[fix] Fix a bug in seaf-gc
* \[fix, api] Fix a bug in creating folder API
* \[admin] Improve performance in getting total file number, used space and total number of devices
* \[fix] Fix MySQL connection pool in Ccnet

### 6.1.1 (2017.06.15)

* Disable thumbnail for video files in default
* Enable fixing the email for share link to be fixed in certain language (option SHARE_LINK_EMAIL_LANGUAGE in seahub_setting.py). So admin can force the language for a email of a share link to be always in English, regardless of what language the sender is using.
* The language of the interface of CollaboraOffice/OnlyOffice will be determined by the language of the current user.
* Display the correct image thumbnails in favorites instead of the generic one
* Enable set favicon and logo via admin panel
* Admin can add libraries in admin panel

### 6.1.0 beta (2017.05.11)

Web UI Improvement:

1. Add thumbnail for video files
2. Improved image file view, using thumbnail to view pictures
3. Improve pdf preview in community edition
4. Move items by drap & drop
5. Add create docx/xlsx/pptx in web interface
6. Add OnlyOffice integration
7. Add Collabora integration
8. Support folder upload in community edition
9. Show which client modify a file in history, this will help to find which client accidentally modified a file or deleted a file.

Improvement for admins:

1. Admin can set user’s quote, delete users in bulk
2. Support using admin panel in mobile platform
3. Add translation for settings page

System changes:

1. Remove wiki by default
2. Upgrade Django to 1.8.18
3. Clean Ajax API
4. Increase share link token length to 20 characters
5. Upgrade jstree to latest version

## 6.0

Note: If you ever used 6.0.0 or 6.0.1 or 6.0.2 with SQLite as database and encoutered a problem with desktop/mobile client login, follow <https://github.com/haiwen/seafile/pull/1738> to fix the problem.

### 6.0.9 (2017.03.30)

* Show user' name instead of user's email in notifications sent out by email
* Add config items for setting favicon, disable wiki feature
* Add css id to easily hide user password reset and delete account button
* \[fix] Fix UI bug in restoring a file from snapshot
* \[fix] Fix after renaming a file, the old versions before file rename can't be downloaded
* \[security] Fix XSS problem of the "go back" button in history page and snapshot view page

### 6.0.8 (2017.02.16)

Improvement for admin

* Admin can add/delete group members
* Admin can create group in admin panel
* Show total storage, total number of files, total number of connected devices in the info page of admin panel
* Force users to change password if imported via csv
* Support set user's quota, name when import user via csv
* Set user's quota in user list page
* Add search group by group name
* Use ajax when deleting a user's library in admin panel
* Support logrotate for controller.log
* Add `# -*- coding: utf-8 -*-` to seahub_settings.py, so that admin can use non-ascii characters in the file.
* Ingore white space character in the end of lines in ccnet.conf
* Add a log when a user can't be find in LDAP during login, so that the system admin can know whether it is caused by password error or the user can't be find
* Delete shared libraries information when deleting a user

Other

* \[fix] Uploading files with special names lets seaf-server crash
* \[fix] Fix user search when global address book is disabled in CLOUD_MODE
* \[fix] Avoid timeout in some cases when showing a library trash
* Show "the account is inactive" when an inactive account try to login
* \[security] Remove viewer.js to show open document files (ods, odt) because viewer.js is not actively maintained and may have potential security bugs (Thanks to Lukas Reschke from Nextcloud GmbH to report the issue)
* \[fix] Fix PostgreSQL support
* Update Django to 1.8.17
* Change time_zone to UTC as default
* \[fix] Fix quota check: users can't upload a file if the quota will be exceeded after uploading the file
* \[fix] Fix quota check when copy file from one library to another
* \[fix] Prevent admin from access group's wiki
* \[fix] Fix a bug when download folder in grid view

### 6.0.7 (2016.12.16)

* \[fix] Fix generating of password protected link in file view page
* \[fix] Fix .jpg/.JPG image display in IE10
* Export quota usage in export Excel in user list admin page
* \[fix] Fix admin can't delete broken libraries
* Add "back to previous page" link in trash page, history page
* \[fix] Improve logo show in About page
* \[fix] Fix file encoding for text file editing online
* \[fix] Don't show operation buttons for broken libraries in normal users page

### 6.0.6 (2016.11.16)

* \[fix] Fix the shared folder link in the notification message when a user share a folder to another user
* \[fix] Update Django version from 1.8.10 to 1.8.16
* \[fix] Fix support for PostgreSQL
* \[fix] Fix SQLite database locking problem
* \[fix] Fix the shared folder name is not changed after removing the old share, renaming the folder and re-sharing the folder
* \[fix] Fix sub-folder accidentially show the files in parent folder when the parent folder contains more than 100 files
* \[fix] Fix image preview navigation when there are more than 100 entries in a folder
* \[fix] Fix bug when admin searching unexisting user
* \[fix] Fix jpeg image display in IE10
* Add support for online view of mov video files
* Make web access token expiring time configurable
* Add an option on server to control block size for web upload files

### 6.0.5 (2016.10.17)

* \[fix] Fix API for uploading file by blocks (Used by iOS client when uploading a large file)
* \[fix] Fix a database connection problem in ccnet-server
* \[fix] Fix moved files are still present in local folder until refresh
* \[fix] Fix admin panel can't show deleted libraries

### 6.0.4 (2016.09.22)

* \[fix] Fix not able to move files via WebDAV interface
* Check whether the quota will exceed before saving the uploaded file to Seafile via Web UI or API
* \[fix] Fix owner can't restore a deleted file or folder in snapshot
* \[fix] Fix UI of personal profile page
* \[fix] Fix in some cases mobile devices can't be unlinked
* \[fix] Fix connection problem for the latest MariaDB in initialisation script
* \[fix] PNG Thumbnail creation broken in 6.0.3 (getexif failes)
* Make maxNumberOfFiles configurable
* \[fix] Remember the sorting of libraries
* Add Finnish translation
* Video + audio no longer be limited by max preview size

### 6.0.3 (2016.09.03)

* \[fix] Fix a bug in sqlite database upgrade script
* \[fix] Fix a bug in database connection pool
* \[fix] Fix a bug in file comment

### 6.0.2 (2016.09.02)

* \[fix] Fix a bug in sqlite database table locking
* Update translations
* Support create libraries for Seafile Drive client

### 6.0.1 beta (2016.08.22)

* \[fix] Fix  default value of created_at in table api2_tokenv2. This bug leads to login problems for desktop and mobile clients.
* \[fix] Fix a bug in generating a password protected share link
* Improve checking the user running Seafile must be the owner of seafile-data. If seafile-data is symbolic link, check the destination folder instead of the symbolic link.
* \[ui] Improve rename operation
* Admin can set library permissions in admin panel
* Show name/contact email in admin panel and enable search user by name/contact email
* Add printing style for markdown
* The “Seafile” in "Welcome to Seafile" message can be customised by SITE_NAME
* Improve sorting of files with numbers
* \[fix] Fix can't view more than 100 files
* \[api] Add admin API to only return LDAP imported user list

### 6.0.0 beta (2016.08.02)

* Add full screen Web UI
* Code clean and update Web APIs
* Add file comment
* Improve zip downloading by adding zip progress
* Change of navigation labels
* \[admin] Add group transfer function in admin panel
* Remove number of synced libraries in devices page for simplify the interface and concept
* Update help pages

## 5.1

Warning:

* The concept of sub-library is removed in version 5.1. You can do selective sync with the latest desktop client
* The group message **reply** function is removed, and the old reply messages will not be shown with the new UI

Note: when upgrade from 5.1.3 or lower version to 5.1.4+, you need to install python-urllib3 (or python2-urllib3 for Arch Linux) manually:

```
# for Ubuntu
sudo apt-get install  python-urllib3
# for CentOS
sudo yum install python-urllib3

```

### 5.1.4 (2016.07.23)

* \[fix] Fix seaf-fsck.sh --export fails without database
* \[fix] Fix users with Umlauts in their display name breaks group management and api2/account/info on some special Linux distribution
* Remove user from groups when a user is deleted.
* \[fix] Fix can't generate shared link for read-only shared library
* \[fix] Fix can still view file history after library history is set to "no history".
* \[fix] Fix after moving or deleting multiple selected items in the webinterface, the buttons are lost until reloading
* Check user before start seafile. The user must be the owner of seafile-data directory
* Don't allow emails with very special characters that may containing XSS string to register
* \[fix] During downloading multiple files/folders, show "Total size exceeds limits" instead of "internal server error" when selected items exceeds limits.
* \[fix] When delete a share, only check whether the be-shared user exist or not. This is to avoid the situation that share to a user can't be deleted after the user be deleted.
* Add a notificition to a user if he/she is added to a group
* Improve UI for password change page when forcing password change after admin reset a user's password
* \[fix] Fix duplicated files show in Firefox if the folder name contains single quote '

### 5.1.3 (2016.05.30)

* \[security]  Fix permission checking for generating share links
* Add an option (ENABLE_SETTINGS_VIA_WEB) to ignore settings via Web UI (system admin->settings)
* \[fix] Making user search (used in auto-completion) case insensitive

### 5.1.2 (2016.05.13)

* \[fix] Fix group rename
* \[fix] Fix group transfer
* Send notifications to members when a new library is shared to a group
* Download multiple selected files from Seahub as a ZIP-file
* Use seafile-data/http-temp to store zip file when downloading a dir
* \[ui] Remember the expanded status of groups in the left hand nav bar
* \[accessibility] Improve accessiblity of library trash/history page by making links for operations selectable by tab.
* \[accessibility] Improve accessiblity of dialogs, add missing labelledby properties for the whole dialog.
* \[accessibility] Improve file/folder upload menu
* list all devices in admin panel
* Add syslog support for seafile.log

### 5.1.1 (2016.04.08)

Note: downloading multiple files at once will be added in the next release.

* A few UI Improvement and fixes
* Add group-discussion (warning: the group message reply function is removed, and the old reply messages will not be shown with the new UI)
* Add an option for disable forcing users to change password (FORCE_PASSWORD_CHANGE, default is True)
* Support new Shibboleth users be created as inactive and activated via Admin later (SHIB_ACTIVATE_AFTER_CREATION , default is True)
* Update jquery to v1.11

### 5.1.0 beta (2016.03.22)

Note: in this version, the group discussion is not re-implement yet. It will be available when the stable verison is released.

* Redesign navigation
* Rewrite group management
* Improve sorting for large folder
* Remember the sorting option for folder
* Improve devices page
* Update icons for libraries and files
* Remove library settings page, re-implement them with dialogs
* Remove group avatar
* Don't show share menu in top bar when multiple item selected
* Auto-focus on username field when loading the login page
* Remove self-introduction in user profile
* Upgrade to django 1.8
* Force the user to change password if adding by admin or password reset by admin
* disable add non-existing user to a group
