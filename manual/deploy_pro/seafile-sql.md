```
CREATE TABLE IF NOT EXISTS FileLockTimestamp (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(40),
  update_time BIGINT NOT NULL,
  UNIQUE INDEX(repo_id)
);

CREATE TABLE IF NOT EXISTS FileLocks (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(40) NOT NULL,
  path TEXT NOT NULL,
  user_name VARCHAR(255) NOT NULL,
  lock_time BIGINT,
  expire BIGINT,
  KEY(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS FolderGroupPerm (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(36) NOT NULL,
  path TEXT NOT NULL,
  permission CHAR(15),
  group_id INTEGER NOT NULL,
  INDEX(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS FolderPermTimestamp (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(36),
  timestamp BIGINT,
  UNIQUE INDEX(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS FolderUserPerm (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(36) NOT NULL,
  path TEXT NOT NULL,
  permission CHAR(15),
  user VARCHAR(255) NOT NULL,
  INDEX(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS GCID (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(36),
  gc_id CHAR(36),
  UNIQUE INDEX(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS LastGCID (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(36),
  client_id VARCHAR(128),
  gc_id CHAR(36),
  UNIQUE INDEX(repo_id, client_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OrgGroupRepo (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  org_id INTEGER,
  repo_id CHAR(37),
  group_id INTEGER,
  owner VARCHAR(255),
  permission CHAR(15),
  UNIQUE INDEX(org_id, group_id, repo_id),
  INDEX (repo_id), INDEX (owner)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OrgInnerPubRepo (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  org_id INTEGER,
  repo_id CHAR(37),
  UNIQUE INDEX(org_id, repo_id),
  permission CHAR(15)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OrgRepo (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  org_id INTEGER,
  repo_id CHAR(37),
  user VARCHAR(255),
  UNIQUE INDEX(org_id, repo_id),
  UNIQUE INDEX (repo_id),
  INDEX (org_id, user),
  INDEX(user)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS OrgSharedRepo (
  id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
  org_id INT,
  repo_id CHAR(37) ,
  from_email VARCHAR(255),
  to_email VARCHAR(255),
  permission CHAR(15),
  INDEX(repo_id),
  INDEX (org_id, repo_id),
  INDEX(from_email), INDEX(to_email)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS RepoStorageId (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  repo_id CHAR(40) NOT NULL,
  storage_id VARCHAR(255) NOT NULL,
  UNIQUE INDEX(repo_id)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS RoleQuota (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  role VARCHAR(255),
  quota BIGINT,
  UNIQUE INDEX(role)
) ENGINE=INNODB;
```