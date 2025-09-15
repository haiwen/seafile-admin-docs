# Seafile FSCK

On the server side, Seafile stores the files in the libraries in an internal format. Seafile has its own representation of directories and files (similar to *Git*).

With default installation, these internal objects are stored in the server's file system directly (such as ***Ext4***, ***NTFS***). But most file systems don't assure the integrity of file contents after a hard shutdown or system crash. So if new Seafile internal objects are being written when the system crashes, they can be corrupt after the system reboots. This will make part of the corresponding library not accessible.

!!! warning
    If you store the seafile-data directory in a ***battery-backed NAS*** (like *EMC* or *NetApp*), or use S3 backend available in the Pro edition, the internal objects won't be corrupt.

!!! note
    If your Seafile server is deployed with Docker, make sure you have enter the container before executing the following commands in this manual:

    ```sh
    docker exec -it seafile bash
    ```

    This is also required for the other scripts in this document.

We provide a seaf-fsck.sh script to check the integrity of libraries. The seaf-fsck tool accepts the following arguments:

```sh
cd /opt/seafile/seafile-server-latest
./seaf-fsck.sh [--repair|-r] [--export|-E export_path] [repo_id_1 [repo_id_2 ...]]
```

There are three modes of operation for seaf-fsck:

1. checking integrity of libraries.
2. repairing corrupted libraries.
3. exporting libraries.

## Checking Integrity of Libraries

Running seaf-fsck.sh without any arguments will run a **read-only** integrity check for all libraries.

```
./seaf-fsck.sh

```

If you want to check integrity for specific libraries, just append the library id's as arguments:

```
./seaf-fsck.sh [library-id1] [library-id2] ...

```

The output looks like:

```
[02/13/15 16:21:07] fsck.c(470): Running fsck for repo ca1a860d-e1c1-4a52-8123-0bf9def8697f.
[02/13/15 16:21:07] fsck.c(413): Checking file system integrity of repo fsck(ca1a860d)...
[02/13/15 16:21:07] fsck.c(35): Dir 9c09d937397b51e1283d68ee7590cd9ce01fe4c9 is missing.
[02/13/15 16:21:07] fsck.c(200): Dir /bf/pk/(9c09d937) is corrupted.
[02/13/15 16:21:07] fsck.c(105): Block 36e3dd8757edeb97758b3b4d8530a4a8a045d3cb is corrupted.
[02/13/15 16:21:07] fsck.c(178): File /bf/02.1.md(ef37e350) is corrupted.
[02/13/15 16:21:07] fsck.c(85): Block 650fb22495b0b199cff0f1e1ebf036e548fcb95a is missing.
[02/13/15 16:21:07] fsck.c(178): File /01.2.md(4a73621f) is corrupted.
[02/13/15 16:21:07] fsck.c(514): Fsck finished for repo ca1a860d.

```

The corrupted files and directories are reported in the above message. By the way, you may also see output like the following:

```
[02/13/15 16:36:11] Commit 6259251e2b0dd9a8e99925ae6199cbf4c134ec10 is missing
[02/13/15 16:36:11] fsck.c(476): Repo ca1a860d HEAD commit is corrupted, need to restore to an old version.
[02/13/15 16:36:11] fsck.c(314): Scanning available commits...
[02/13/15 16:36:11] fsck.c(376): Find available commit 1b26b13c(created at 2015-02-13 16:10:21) for repo ca1a860d.

```

This means the ***head commit*** (current state of the library) recorded in database is not consistent with the library data. In such case, fsck will try to find the last consistent state and check the integrity in that state.

!!! tip
    If you have many libraries, it's helpful to save the fsck output into a log file for later analysis.

## Repairing Corruption

Corruption repair in seaf-fsck basically works in two steps:

1. If the library state (commit) recorded in database is not found in data directory, find the last available state from data directory.
2. Check data integrity in that specific state. If files or directories are corrupted, set them to empty files or empty directories. The corrupted paths will be reported, so that the user can recover them from somewhere else.

Running the following command repairs all the libraries:

```
./seaf-fsck.sh --repair

```

Most of time you run the read-only integrity check first, to find out which libraries are corrupted. And then you repair specific libraries with the following command:

```
./seaf-fsck.sh --repair [library-id1] [library-id2] ...

```

After repairing, in the library history, seaf-fsck includes the list of files and folders that are corrupted. So it's much easier to located corrupted paths.

### Best Practice for Repairing a Library

To check all libraries and find out which library is corrupted, the system admin can run seaf-fsck.sh without any argument and save the output to a log file. Search for keyword "Fail" in the log file to locate corrupted libraries. You can run seaf-fsck to check all libraries when your Seafile server is running. It won't damage or change any files.

When the system admin find a library is corrupted, he/she should run seaf-fsck.sh with "--repair" for the library. After the command fixes the library, the admin should inform user to recover files from other places. There are two ways:

* Upload corrupted files or folders via the web interface
* If the library was synced to some desktop computer, and that computer has a correct version of the corrupted file, resyncing the library on that computer will upload the corrupted files to the server.

## Speeding up FSCK by not checking file contents

Starting from Pro edition 7.1.5, an option is added to speed up FSCK. Most of the running time of seaf-fsck is spent on calculating hashes for file contents. This hash will be compared with block object ID. If they're not consistent, the block is detected as corrupted.

In many cases, the file contents won't be corrupted most of time. Some objects are just missing from the system. So it's enough to only check for object existence. This will greatly speed up the fsck process.

To skip checking file contents, add the `--shallow` or `-s` option to seaf-fsck.

## Exporting Libraries to File System

You can use seaf-fsck to export all the files in libraries to external file system (such as Ext4). This procedure doesn't rely on the seafile database. As long as you have your seafile-data directory, you can always export your files from Seafile to external file system. The command about this operation is

```sh
./seaf-fsck.sh --export top_export_path [library-id1] [library-id2] ...
```

The argument `top_export_path` is a directory to place the exported files. Each library will be exported as a sub-directory of the export path. If you don't specify library ids, all libraries will be exported.

!!! note
    Currently **only un-encrypted libraries can be exported**. Encrypted libraries will be skipped.

## Checking file size

Starting from version 13.0.9, fsck has added an option to check whether the file size matches the actual file content. Some problematic clients may upload incorrect blocks, causing the actual file size to not match the file content. With this option, you can detect files with size mismatches, along with the method and time of their upload.

To check whether the file size matches, add the `--check-file-size` or `-S` option to seaf-fsck.
