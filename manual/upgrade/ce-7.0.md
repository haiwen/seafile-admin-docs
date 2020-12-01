# ce-7.0

## Common Problems

### Not able to open Markdown file

If after upgrading to 7.0, you are not able to open Markdown file and if your seahub.log containing the following error, it is caused by you forgot to migrate file comment when you upgrade to 6.3 version.

![](./image-1558745192334.png)

<img src="./image-1558745374080.png" width="611.609375" height="null" />

You can delete the table base_filecomment and recreate the table.

```
CREATE TABLE `base_filecomment` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `author` varchar(255) NOT NULL,
    `comment` longtext NOT NULL,
    `created_at` datetime NOT NULL,
    `updated_at` datetime NOT NULL,
    `uuid_id` char(32) NOT NULL,
    `detail` longtext NOT NULL,
    `resolved` tinyint(1) NOT NULL,
  
    PRIMARY KEY (`id`),
    KEY `base_filecomment_uuid_id_4f9a2ca2_fk_tags_fileuuidmap_uuid` (`uuid_id`),
    KEY `base_filecomment_author_8a4d7e91` (`author`),  
    KEY `base_filecomment_resolved_e0717eca` (`resolved`),
    CONSTRAINT `base_filecomment_uuid_id_4f9a2ca2_fk_tags_fileuuidmap_uuid` FOREIGN KEY (`uuid_id`) REFERENCES `tags_fileuuidmap` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

```

If you are using SQLite, the corresponding SQL is:

```
CREATE TABLE "base_filecomment" (
"id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
 "author" varchar(255) NOT NULL,
 "comment" text NOT NULL, 
"created_at" datetime NOT NULL, 
"updated_at" datetime NOT NULL, 
"uuid_id" char(32) NOT NULL REFERENCES "tags_fileuuidmap" ("uuid"), 
"detail" text NOT NULL, 
"resolved" bool NOT NULL);

```


