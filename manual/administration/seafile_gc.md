# Seafile GC

Seafile uses storage de-duplication technology to reduce storage usage. The underlying data blocks will not be removed immediately after you delete a file or a library. As a result, the number of unused data blocks will increase on Seafile server.

To release the storage space occupied by unused blocks, you have to run a
"garbage collection" program to clean up unused blocks on your server.

The GC program cleans up two types of unused blocks:

1. Blocks that no library references to, that is, the blocks belong to deleted libraries;
2. If you set history length limit on some libraries, the out-dated blocks in those libraries will also be removed.


## Run GC

### Dry-run Mode

To see how much garbage can be collected without actually removing any garbage, use the dry-run option:

```
seaf-gc.sh --dry-run [repo-id1] [repo-id2] ...

```

The output should look like:

```
[03/19/15 19:41:49] seafserv-gc.c(115): GC version 1 repo My Library(ffa57d93)
[03/19/15 19:41:49] gc-core.c(394): GC started. Total block number is 265.
[03/19/15 19:41:49] gc-core.c(75): GC index size is 1024 Byte.
[03/19/15 19:41:49] gc-core.c(408): Populating index.
[03/19/15 19:41:49] gc-core.c(262): Populating index for repo ffa57d93.
[03/19/15 19:41:49] gc-core.c(308): Traversed 5 commits, 265 blocks.
[03/19/15 19:41:49] gc-core.c(440): Scanning unused blocks.
[03/19/15 19:41:49] gc-core.c(472): GC finished. 265 blocks total, about 265 reachable blocks, 0 blocks can be removed.

[03/19/15 19:41:49] seafserv-gc.c(115): GC version 1 repo aa(f3d0a8d0)
[03/19/15 19:41:49] gc-core.c(394): GC started. Total block number is 5.
[03/19/15 19:41:49] gc-core.c(75): GC index size is 1024 Byte.
[03/19/15 19:41:49] gc-core.c(408): Populating index.
[03/19/15 19:41:49] gc-core.c(262): Populating index for repo f3d0a8d0.
[03/19/15 19:41:49] gc-core.c(308): Traversed 8 commits, 5 blocks.
[03/19/15 19:41:49] gc-core.c(264): Populating index for sub-repo 9217622a.
[03/19/15 19:41:49] gc-core.c(308): Traversed 4 commits, 4 blocks.
[03/19/15 19:41:49] gc-core.c(440): Scanning unused blocks.
[03/19/15 19:41:49] gc-core.c(472): GC finished. 5 blocks total, about 9 reachable blocks, 0 blocks can be removed.

[03/19/15 19:41:49] seafserv-gc.c(115): GC version 1 repo test2(e7d26d93)
[03/19/15 19:41:49] gc-core.c(394): GC started. Total block number is 507.
[03/19/15 19:41:49] gc-core.c(75): GC index size is 1024 Byte.
[03/19/15 19:41:49] gc-core.c(408): Populating index.
[03/19/15 19:41:49] gc-core.c(262): Populating index for repo e7d26d93.
[03/19/15 19:41:49] gc-core.c(308): Traversed 577 commits, 507 blocks.
[03/19/15 19:41:49] gc-core.c(440): Scanning unused blocks.
[03/19/15 19:41:49] gc-core.c(472): GC finished. 507 blocks total, about 507 reachable blocks, 0 blocks can be removed.

[03/19/15 19:41:50] seafserv-gc.c(124): === Repos deleted by users ===
[03/19/15 19:41:50] seafserv-gc.c(145): === GC is finished ===

[03/19/15 19:41:50] Following repos have blocks to be removed:
repo-id1
repo-id2
repo-id3

```

If you give specific library ids, only those libraries will be checked; otherwise all libraries will be checked.

!!! note "repos have blocks to be removed"

    Notice that at the end of the output there is a "repos have blocks to be removed" section. It contains the list of libraries that have garbage blocks. Later when you run GC without --dry-run option, you can use these libraris ids as input arguments to GC program.

### Removing Garbage

To actually remove garbage blocks, run without the --dry-run option:

```
seaf-gc.sh [repo-id1] [repo-id2] ...

```

If libraries ids are specified, only those libraries will be checked for garbage.

As described before, there are two types of garbage blocks to be removed. Sometimes just removing the first type of blocks (those that belong to deleted libraries) is good enough. In this case, the GC program won't bother to check the libraries for outdated historic blocks. The "-r" option implements this feature:

```
seaf-gc.sh -r

```

!!! success
    Libraries deleted by the users are not immediately removed from the system. Instead, they're moved into a "trash" in the system admin page. Before they're cleared from the trash, their blocks won't be garbage collected.

### Removing FS objects

Since Pro server 8.0.6 and community edition 9.0, you can remove garbage fs objects. It should be run without the --dry-run option:

```
seaf-gc.sh --rm-fs

```

!!! danger "Bug reports"
    This command has bug before Pro Edition 10.0.15 and Community Edition 11.0.7. It could cause virtual libraries (e.g. shared folders) failing to merge into their parent libraries. Please avoid using this option in the affected versions. Please contact our support team if you are affected by this bug.

### Using Multiple Threads in GC

You can specify the thread number in GC. By default,

* If storage backend is S3/Swift/Ceph, 10 threads are started to do the GC work.
* If storage backend is file system, only 1 thread is started.

You can specify the thread number in with "-t" option. "-t" option can be used together with all other options. Each thread will do GC on one library. For example, the following command will use 20 threads to GC all libraries:

```
seaf-gc.sh -t 20

```

Since the threads are concurrent, the output of each thread may mix with each others. Library ID is printed in each line of output.

### Run GC based on library ID prefix

Since GC usually runs quite slowly as it needs to traverse the entire library history. You can use multiple threads to run GC in parallel. For even larger deployments, it's also desirable to run GC on multiple server in parallel.

A simple pattern to divide the workload among multiple GC servers is to assign libraries to servers based on library ID. Since Pro edition 7.1.5, this is supported. You can add "--id-prefix" option to seaf-gc.sh, to specify the library ID prefix. For example, the below command will only process libraries having "a123" as ID prefix.

```
seaf-gc.sh --id-prefix a123

```


## GC in Seafile docker container

To perform garbage collection inside the seafile docker container, you must run the `/scripts/gc.sh` script. Simply run `docker exec <whatever-your-seafile-container-is-called> /scripts/gc.sh`.
