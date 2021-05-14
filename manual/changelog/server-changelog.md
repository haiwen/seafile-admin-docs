# Seafile Server Changelog

> You can check Seafile release table to find the lifetime of each release and current supported OS: <https://cloud.seatable.io/dtable/external-links/a85d4221e41344c19566/?tid=0000&vid=0000>

## 8.0

Please check our document for how to upgrade to 8.0: <https://manual.seafile.com/upgrade/upgrade_notes_for_8.0.x/>

### 8.0.5 (2021/05/14)

* Users can set whether to receive email notifications in the setting page
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

Please check our document for how to upgrade to 7.1: <https://manual.seafile.com/upgrade/upgrade_notes_for_7.1.x/>

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
