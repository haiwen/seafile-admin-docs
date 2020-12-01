# FUSE extension

Files in the seafile system are split to blocks, which means what are stored on your seafile server are not complete files, but blocks. This design faciliates effective data deduplication.

However, administrators sometimes want to access the files directly on the server. You can use seaf-fuse to do this.

`Seaf-fuse` is an implementation of the [FUSE](http://fuse.sourceforge.net) virtual filesystem. In a word, it mounts all the seafile files to a folder (which is called the '''mount point'''), so that you can access all the files managed by seafile server, just as you access a normal folder on your server.

Note:

* Encrypted folders can't be accessed by seaf-fuse.
* Currently the implementation is '''read-only''', which means you can't modify the files through the mounted folder.
* One debian/centos systems, you need to be in the "fuse" group to have the permission to mount a FUSE folder.

### How to start seaf-fuse

Assume we want to mount to `/data/seafile-fuse`.

##### Create the folder as the mount point

```
mkdir -p /data/seafile-fuse
```

##### Start seaf-fuse with the script

Note: Before start seaf-fuse, you should have started seafile server with `./seafile.sh start`.

```
./seaf-fuse.sh start /data/seafile-fuse
```

Since Community server version 4.2.1 and Pro server 4.2.0, the script supports standard mount options for FUSE. For example, you can specify ownership for the mounted folder:

```
./seaf-fuse.sh start -o uid=<uid> /data/seafile-fuse
```

You can find the complete list of supported options in `man fuse`.

##### Special notes for used with Ceph

If you use Ceph (via librados) as storage backend, you need to add the `-f` option to seaf-fuse.sh, to ask the fuse program not to daemonize. Otherwise the fuse program will have strange "frozen" behaviors when accessing files.

```
./seaf-fuse.sh start -f /data/seafile-fuse
```

##### Stop seaf-fuse

```
./seaf-fuse.sh stop
```

### Contents of the mounted folder

##### The top level folder

Now you can list the content of `/data/seafile-fuse`.

```
$ ls -lhp /data/seafile-fuse

drwxr-xr-x 2 root root 4.0K Jan  1  2015 abc@abc.com/
drwxr-xr-x 2 root root 4.0K Jan  4  2015 foo@foo.com/
drwxr-xr-x 2 root root 4.0K Jan  1  2015 plus@plus.com/
drwxr-xr-x 2 root root 4.0K Jan  1  2015 sharp@sharp.com/
drwxr-xr-x 2 root root 4.0K Jan  3  2015 test@test.com/
```

* The top level folder contains many subfolders, each of which corresponds to a user

##### The folder for each user

```
$ ls -lhp /data/seafile-fuse/abc@abc.com

drwxr-xr-x 2 root root  924 Jan  1  1970 5403ac56-5552-4e31-a4f1-1de4eb889a5f_Photos/
drwxr-xr-x 2 root root 1.6K Jan  1  1970 a09ab9fc-7bd0-49f1-929d-6abeb8491397_My Notes/
```

From the above list you can see, under the folder of a user there are subfolders, each of which represents a library of that user, and has a name of this format: '''{library_id}-{library-name}'''.

##### The folder for a library

```
$ ls -lhp /data/seafile-fuse/abc@abc.com/5403ac56-5552-4e31-a4f1-1de4eb889a5f_Photos/

-rw-r--r-- 1 root root 501K Jan  1  2015 image.png
-rw-r--r-- 1 root root 501K Jan  1  2015 sample.jpng
```

##### If you get a "Permission denied" error

If you get an error message saying "Permission denied" when running `./seaf-fuse.sh start`, most likely you are not in the "fuse group". You should:

* Add yourself to the fuse group
```
sudo usermod -a -G fuse <your-user-name>
```

* Logout your shell and login again
* Now try `./seaf-fuse.sh start <path>`again.

