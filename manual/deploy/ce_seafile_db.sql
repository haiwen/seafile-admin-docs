-- MySQL dump 10.13  Distrib 5.5.53, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: seafile_db
-- ------------------------------------------------------
-- Server version	5.5.53-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Branch`
--

DROP TABLE IF EXISTS `Branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Branch` (
  `name` varchar(10) NOT NULL DEFAULT '',
  `repo_id` char(41) NOT NULL DEFAULT '',
  `commit_id` char(41) DEFAULT NULL,
  PRIMARY KEY (`repo_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GarbageRepos`
--

DROP TABLE IF EXISTS `GarbageRepos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GarbageRepos` (
  `repo_id` char(36) NOT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `InnerPubRepo`
--

DROP TABLE IF EXISTS `InnerPubRepo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `InnerPubRepo` (
  `repo_id` char(37) NOT NULL,
  `permission` char(15) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `OrgQuota`
--

DROP TABLE IF EXISTS `OrgQuota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `OrgQuota` (
  `org_id` int(11) NOT NULL,
  `quota` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `OrgUserQuota`
--

DROP TABLE IF EXISTS `OrgUserQuota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `OrgUserQuota` (
  `org_id` int(11) NOT NULL DEFAULT '0',
  `user` varchar(255) NOT NULL DEFAULT '',
  `quota` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`org_id`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Repo`
--

DROP TABLE IF EXISTS `Repo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Repo` (
  `repo_id` char(37) NOT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoFileCount`
--

DROP TABLE IF EXISTS `RepoFileCount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoFileCount` (
  `repo_id` char(36) NOT NULL,
  `file_count` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoGroup`
--

DROP TABLE IF EXISTS `RepoGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoGroup` (
  `repo_id` char(37) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `permission` char(15) DEFAULT NULL,
  UNIQUE KEY `group_id` (`group_id`,`repo_id`),
  KEY `repo_id` (`repo_id`),
  KEY `user_name` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoHead`
--

DROP TABLE IF EXISTS `RepoHead`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoHead` (
  `repo_id` char(37) NOT NULL,
  `branch_name` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoHistoryLimit`
--

DROP TABLE IF EXISTS `RepoHistoryLimit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoHistoryLimit` (
  `repo_id` char(37) NOT NULL,
  `days` int(11) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoOwner`
--

DROP TABLE IF EXISTS `RepoOwner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoOwner` (
  `repo_id` char(37) NOT NULL,
  `owner_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`repo_id`),
  KEY `owner_id` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoSize`
--

DROP TABLE IF EXISTS `RepoSize`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoSize` (
  `repo_id` char(37) NOT NULL,
  `size` bigint(20) unsigned DEFAULT NULL,
  `head_id` char(41) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoTokenPeerInfo`
--

DROP TABLE IF EXISTS `RepoTokenPeerInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoTokenPeerInfo` (
  `token` char(41) NOT NULL,
  `peer_id` char(41) DEFAULT NULL,
  `peer_ip` varchar(41) DEFAULT NULL,
  `peer_name` varchar(255) DEFAULT NULL,
  `sync_time` bigint(20) DEFAULT NULL,
  `client_ver` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoTrash`
--

DROP TABLE IF EXISTS `RepoTrash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoTrash` (
  `repo_id` char(36) NOT NULL,
  `repo_name` varchar(255) DEFAULT NULL,
  `head_id` char(40) DEFAULT NULL,
  `owner_id` varchar(255) DEFAULT NULL,
  `size` bigint(20) DEFAULT NULL,
  `org_id` int(11) DEFAULT NULL,
  `del_time` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`repo_id`),
  KEY `owner_id` (`owner_id`),
  KEY `org_id` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoUserToken`
--

DROP TABLE IF EXISTS `RepoUserToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoUserToken` (
  `repo_id` char(37) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `token` char(41) DEFAULT NULL,
  UNIQUE KEY `repo_id` (`repo_id`,`token`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `RepoValidSince`
--

DROP TABLE IF EXISTS `RepoValidSince`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RepoValidSince` (
  `repo_id` char(37) NOT NULL,
  `timestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SharedRepo`
--

DROP TABLE IF EXISTS `SharedRepo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SharedRepo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_id` char(37) DEFAULT NULL,
  `from_email` varchar(255) DEFAULT NULL,
  `to_email` varchar(255) DEFAULT NULL,
  `permission` char(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `repo_id` (`repo_id`),
  KEY `from_email` (`from_email`),
  KEY `to_email` (`to_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SystemInfo`
--

DROP TABLE IF EXISTS `SystemInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SystemInfo` (
  `info_key` varchar(256) DEFAULT NULL,
  `info_value` varchar(1024) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UserQuota`
--

DROP TABLE IF EXISTS `UserQuota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserQuota` (
  `user` varchar(255) NOT NULL,
  `quota` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UserShareQuota`
--

DROP TABLE IF EXISTS `UserShareQuota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UserShareQuota` (
  `user` varchar(255) NOT NULL,
  `quota` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `VirtualRepo`
--

DROP TABLE IF EXISTS `VirtualRepo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `VirtualRepo` (
  `repo_id` char(36) NOT NULL,
  `origin_repo` char(36) DEFAULT NULL,
  `path` text,
  `base_commit` char(40) DEFAULT NULL,
  PRIMARY KEY (`repo_id`),
  KEY `origin_repo` (`origin_repo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `WebAP`
--

DROP TABLE IF EXISTS `WebAP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `WebAP` (
  `repo_id` char(37) NOT NULL,
  `access_property` char(10) DEFAULT NULL,
  PRIMARY KEY (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-11-21 21:33:50
