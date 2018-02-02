
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ocs` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_general_ci */;

USE `ocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_log` (
  `activity_log_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL COMMENT 'Log action of this memeber',
  `project_id` int(11) DEFAULT NULL,
  `object_id` int(11) NOT NULL COMMENT 'Key to the action (add comment, pling, ...)',
  `object_ref` varchar(45) NOT NULL COMMENT 'Refferenz to the object table (plings, project, project_comment,...)',
  `object_title` varchar(90) DEFAULT NULL COMMENT 'Title to show',
  `object_text` varchar(150) DEFAULT NULL COMMENT 'Short text of this object (first 150 characters)',
  `object_img` varchar(255) DEFAULT NULL,
  `activity_type_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Wich type of activity: create, update,delete.',
  `time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`activity_log_id`),
  KEY `member_id` (`member_id`),
  KEY `project_id` (`project_id`),
  KEY `object_id` (`object_id`),
  KEY `activity_log_id` (`activity_log_id`,`member_id`,`project_id`,`object_id`),
  KEY `idx_time` (`time`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Log all actions of a user. Wen can then generate a newsfeed ';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_log_types` (
  `activity_log_type_id` int(11) NOT NULL,
  `type_text` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`activity_log_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Type of activities';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment_types` (
  `comment_type_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  KEY `pk` (`comment_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `comment_id` int(11) NOT NULL AUTO_INCREMENT,
  `comment_target_id` int(11) NOT NULL,
  `comment_member_id` int(11) NOT NULL,
  `comment_parent_id` int(11) DEFAULT NULL,
  `comment_type` int(11) DEFAULT '0',
  `comment_pling_id` int(11) DEFAULT NULL,
  `comment_text` text,
  `comment_active` int(1) DEFAULT '1',
  `comment_created_at` datetime DEFAULT NULL,
  `source_id` int(11) DEFAULT '0',
  `source_pk` int(11) DEFAULT NULL,
  PRIMARY KEY (`comment_id`),
  UNIQUE KEY `uk_hive_pk` (`source_pk`,`source_id`),
  KEY `idx_target` (`comment_target_id`),
  KEY `idx_created` (`comment_created_at`),
  KEY `idx_parent` (`comment_parent_id`),
  KEY `idx_pling` (`comment_pling_id`),
  KEY `idx_type_active` (`comment_type`,`comment_active`),
  KEY `idx_member` (`comment_member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `comment_created` BEFORE INSERT ON `comments` FOR EACH ROW
  BEGIN
    IF NEW.comment_created_at IS NULL THEN
		SET NEW.comment_created_at = NOW();
	END IF;
	
	IF NEW.comment_type = 0 THEN
	
		UPDATE project p
		SET p.count_comments = (p.count_comments+1)
		WHERE p.project_id = NEW.comment_target_id;
		
	END IF;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `comment_update` BEFORE UPDATE ON `comments` FOR EACH ROW BEGIN

	IF NEW.comment_active = 0 AND OLD.comment_active = 1 THEN
	
		UPDATE project p
		SET p.count_comments = (p.count_comments-1)
		WHERE p.project_id = NEW.comment_target_id;
		
	END IF;


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_operating_system` (
  `os_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT '0',
  `displayname` varchar(50) DEFAULT '0',
  `order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `changend_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`os_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_store` (
  `store_id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `config_id_name` varchar(45) NOT NULL,
  `mapping_id_name` varchar(45) DEFAULT NULL,
  `order` int(11) DEFAULT '0',
  `default` int(1) DEFAULT '0',
  `is_client` int(1) DEFAULT '0',
  `google_id` varchar(45) DEFAULT NULL,
  `package_type` varchar(45) DEFAULT NULL COMMENT '1-n package_type_ids',
  `cross_domain_login` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `config_store_BEFORE_INSERT` BEFORE INSERT ON `config_store` FOR EACH ROW BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_store_category` (
  `store_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `store_id` int(11) DEFAULT NULL,
  `project_category_id` int(11) DEFAULT NULL,
  `order` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`store_category_id`),
  KEY `project_category_id_idx` (`project_category_id`),
  KEY `fk_store_id_idx` (`store_id`),
  CONSTRAINT `fk_project_category_id` FOREIGN KEY (`project_category_id`) REFERENCES `project_category` (`project_category_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `config_store_category_BEFORE_INSERT` BEFORE INSERT ON `config_store_category` FOR EACH ROW BEGIN
	IF NEW.created_at IS NULL THEN
		SET NEW.created_at = NOW();
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `foreign_key` varchar(255) DEFAULT NULL,
  `foreign_id` int(11) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_template` (
  `mail_template_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `subject` varchar(250) NOT NULL,
  `text` text NOT NULL,
  `created_at` datetime NOT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`mail_template_id`),
  UNIQUE KEY `unique_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `member_id` int(10) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `mail` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `roleId` int(11) NOT NULL,
  `avatar` varchar(255) NOT NULL DEFAULT 'default-profile.png',
  `type` int(1) NOT NULL DEFAULT '0' COMMENT 'Type: 0 = Member, 1 = group',
  `is_active` int(1) NOT NULL DEFAULT '0',
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `mail_checked` int(1) NOT NULL DEFAULT '0',
  `agb` int(1) NOT NULL DEFAULT '0',
  `newsletter` int(1) NOT NULL DEFAULT '0',
  `login_method` varchar(45) NOT NULL DEFAULT 'local' COMMENT 'local (registered on pling), facebook, twitter',
  `firstname` varchar(200) DEFAULT NULL,
  `lastname` varchar(200) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `zip` varchar(5) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `last_online` datetime DEFAULT NULL,
  `biography` text,
  `paypal_mail` varchar(255) DEFAULT NULL,
  `paypal_valid_status` mediumint(9) DEFAULT NULL,
  `wallet_address` varchar(255) DEFAULT NULL,
  `dwolla_id` varchar(45) DEFAULT NULL,
  `main_project_id` int(10) DEFAULT NULL COMMENT 'Die ID des .me-Projekts',
  `profile_image_url` varchar(355) DEFAULT '/images/system/default-profile.png' COMMENT 'URL to the profile-image',
  `profile_image_url_bg` varchar(355) DEFAULT NULL,
  `profile_img_src` varchar(45) DEFAULT 'local' COMMENT 'social,gravatar,local',
  `social_username` varchar(50) DEFAULT NULL COMMENT 'Username on facebook/twitter. Used to generate profile-img-url.',
  `social_user_id` varchar(50) DEFAULT NULL COMMENT 'ID from twitter, facebook,...',
  `gravatar_email` varchar(45) DEFAULT NULL COMMENT 'email, wich is connected to gravatar.',
  `facebook_username` varchar(45) DEFAULT NULL,
  `twitter_username` varchar(45) DEFAULT NULL,
  `link_facebook` varchar(300) DEFAULT NULL COMMENT 'Link to facebook',
  `link_twitter` varchar(300) DEFAULT NULL COMMENT 'Link to twitter',
  `link_website` varchar(300) DEFAULT NULL COMMENT 'Link to homepage',
  `link_google` varchar(300) DEFAULT NULL COMMENT 'Link to google',
  `link_github` varchar(300) DEFAULT NULL,
  `validated_at` datetime DEFAULT NULL,
  `validated` int(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `source_id` int(11) DEFAULT '0' COMMENT '0 = local, 1 = hive01',
  `source_pk` int(11) DEFAULT NULL COMMENT 'pk on the source',
  PRIMARY KEY (`member_id`),
  KEY `uuid` (`uuid`),
  KEY `idx_created` (`created_at`),
  KEY `idx_login` (`mail`,`username`,`password`,`is_active`,`is_deleted`,`login_method`),
  KEY `idx_mem_search` (`member_id`,`username`,`is_deleted`,`mail_checked`),
  KEY `idx_source` (`source_id`,`source_pk`),
  KEY `idx_username` (`username`),
  KEY `idx_id_active` (`member_id`,`is_active`,`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `member_created` BEFORE INSERT ON `member` FOR EACH ROW BEGIN
	IF NEW.created_at IS NULL THEN
		SET NEW.created_at = NOW();
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_dl_plings` (
  `yearmonth` int(6) DEFAULT NULL,
  `project_id` int(11) NOT NULL DEFAULT '0',
  `project_category_id` int(11) NOT NULL DEFAULT '0',
  `member_id` int(11) NOT NULL,
  `mail` varchar(255) DEFAULT NULL,
  `paypal_mail` varchar(255) DEFAULT NULL,
  `num_downloads` bigint(21) NOT NULL DEFAULT '0',
  `dl_pling_factor` decimal(3,2) NOT NULL DEFAULT '0.00',
  `probably_payout_amount` decimal(25,4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  UNIQUE KEY `uk_month_proj` (`yearmonth`,`member_id`,`project_id`),
  KEY `idx_member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_email` (
  `email_id` int(11) NOT NULL AUTO_INCREMENT,
  `email_member_id` int(11) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `email_primary` int(1) DEFAULT '0',
  `email_deleted` int(1) DEFAULT '0',
  `email_created` datetime DEFAULT NULL,
  `email_checked` datetime DEFAULT NULL,
  `email_verification_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`email_id`),
  KEY `idx_address` (`email_address`),
  KEY `idx_member` (`email_member_id`),
  KEY `idx_verification` (`email_verification_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER pling.member_email_BEFORE_INSERT BEFORE INSERT ON member_email FOR EACH ROW
BEGIN
IF NEW.email_created IS NULL THEN

  SET NEW.email_created = NOW();

END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_follower` (
  `member_follower_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `follower_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`member_follower_id`),
  KEY `follower_id` (`follower_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_payout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `yearmonth` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `mail` varchar(50) NOT NULL,
  `paypal_mail` varchar(50) DEFAULT NULL,
  `num_downloads` int(11) NOT NULL,
  `num_points` int(11) NOT NULL,
  `amount` double NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '0=new,1=start request,10=processed,100=completed,999=error',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `timestamp_masspay_start` timestamp NULL DEFAULT NULL,
  `timestamp_masspay_last_ipn` timestamp NULL DEFAULT NULL,
  `last_paypal_ipn` text,
  `last_paypal_status` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_PAYOUT` (`yearmonth`,`member_id`),
  KEY `idx_member` (`member_id`,`yearmonth`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Table for our monthly payouts';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_ref` (
  `member_ref_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`member_ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Wich items are interresting for a user. Used for the newsfee';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_role` (
  `member_role_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `shortname` varchar(50) NOT NULL,
  `is_active` int(1) NOT NULL DEFAULT '0',
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `changed_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`member_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_token` (
  `token_id` int(11) NOT NULL AUTO_INCREMENT,
  `token_member_id` int(11) NOT NULL,
  `token_provider_name` varchar(45) NOT NULL,
  `token_value` varchar(45) NOT NULL,
  `token_provider_username` varchar(45) DEFAULT NULL,
  `token_fingerprint` varchar(45) DEFAULT NULL,
  `token_created` datetime DEFAULT NULL,
  `token_changed` datetime DEFAULT NULL,
  `token_deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`token_id`),
  KEY `idx_token` (`token_member_id`,`token_provider_name`,`token_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
ALTER DATABASE `ocs-apiserver` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `ocs-apiserver`.`member_token_BEFORE_INSERT` BEFORE INSERT ON `member_token` FOR EACH ROW
  BEGIN
    IF NEW.token_created IS NULL THEN
      SET NEW.token_created = NOW();
    END IF;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `ocs-apiserver` CHARACTER SET latin1 COLLATE latin1_general_ci ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `package_types` (
  `package_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `order` int(11) DEFAULT NULL,
  `is_active` int(1) DEFAULT '1',
  PRIMARY KEY (`package_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_valid_status` (
  `id` int(11) NOT NULL,
  `title` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `description` text COLLATE latin1_general_ci,
  `color` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `is_active` int(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL COMMENT 'pling-Owner',
  `project_id` int(11) DEFAULT NULL COMMENT 'Witch project was plinged',
  `status_id` int(11) DEFAULT '0' COMMENT 'Stati des pling: 0 = inactive, 1 = active (plinged), 2 = payed successfull, 99 = deleted',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation-time',
  `pling_time` timestamp NULL DEFAULT NULL COMMENT 'When was a project plinged?',
  `active_time` timestamp NULL DEFAULT NULL COMMENT 'When did paypal say, that this pling was payed successfull',
  `delete_time` timestamp NULL DEFAULT NULL,
  `amount` double(10,2) DEFAULT '0.00' COMMENT 'Amount of money',
  `comment` varchar(140) DEFAULT NULL COMMENT 'Comment from the plinger',
  `payment_provider` varchar(45) DEFAULT NULL,
  `payment_reference_key` varchar(255) DEFAULT NULL COMMENT 'uniquely identifies the request',
  `payment_transaction_id` varchar(255) DEFAULT NULL COMMENT 'uniquely identify caller (developer, facilliator, marketplace) transaction',
  `payment_raw_message` varchar(2000) DEFAULT NULL COMMENT 'the raw text message ',
  `payment_raw_error` varchar(2000) DEFAULT NULL,
  `payment_status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `status_id` (`status_id`),
  KEY `member_id` (`member_id`),
  KEY `PLINGS_IX_01` (`status_id`,`project_id`,`member_id`,`active_time`,`amount`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `project_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL DEFAULT '0',
  `content_type` varchar(255) NOT NULL DEFAULT 'text',
  `project_category_id` int(11) NOT NULL DEFAULT '0',
  `hive_category_id` int(11) NOT NULL DEFAULT '0',
  `is_active` int(1) NOT NULL DEFAULT '0',
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `uuid` varchar(255) DEFAULT NULL,
  `pid` int(11) DEFAULT NULL COMMENT 'ParentId',
  `type_id` int(11) DEFAULT '0' COMMENT '0 = DummyProject, 1 = Project, 2 = Update',
  `title` varchar(100) DEFAULT NULL,
  `description` text,
  `version` varchar(50) DEFAULT NULL,
  `image_big` varchar(255) DEFAULT NULL,
  `image_small` varchar(255) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `content_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL COMMENT 'Member_id of the creator. Importent for groups.',
  `facebook_code` text,
  `github_code` text,
  `twitter_code` text,
  `google_code` text,
  `link_1` text,
  `embed_code` text,
  `ppload_collection_id` varchar(255) DEFAULT NULL,
  `validated` int(1) DEFAULT '0',
  `validated_at` datetime DEFAULT NULL,
  `featured` int(1) DEFAULT '0',
  `approved` int(1) DEFAULT '0',
  `spam_checked` int(1) NOT NULL DEFAULT '0',
  `amount` int(11) DEFAULT NULL,
  `amount_period` varchar(45) DEFAULT NULL,
  `claimable` int(1) DEFAULT NULL,
  `claimed_by_member` int(11) DEFAULT NULL,
  `count_likes` int(11) DEFAULT '0',
  `count_dislikes` int(11) DEFAULT '0',
  `count_comments` int(11) DEFAULT '0',
  `count_downloads_hive` int(11) DEFAULT '0',
  `source_id` int(11) DEFAULT '0',
  `source_pk` int(11) DEFAULT NULL,
  `source_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`project_id`),
  UNIQUE KEY `uk_source` (`source_id`,`source_pk`,`source_type`),
  KEY `idx_project_cat_id` (`project_category_id`),
  KEY `idx_uuid` (`uuid`),
  KEY `idx_member_id` (`member_id`),
  KEY `idx_pid` (`pid`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_title` (`title`),
  KEY `idx_source` (`source_id`,`source_pk`,`source_type`),
  KEY `idx_status` (`status`,`ppload_collection_id`,`project_category_id`,`project_id`),
  KEY `idx_type_status` (`type_id`,`status`,`project_category_id`,`project_id`),
  KEY `idx_ppload` (`ppload_collection_id`,`status`),
  KEY `idx_src_status` (`status`,`source_pk`,`source_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_category` (
  `project_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `lft` int(11) NOT NULL,
  `rgt` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `is_active` int(1) NOT NULL DEFAULT '0',
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `xdg_type` varchar(50) DEFAULT NULL,
  `name_legacy` varchar(50) DEFAULT NULL,
  `orderPos` int(11) DEFAULT NULL,
  `dl_pling_factor` double unsigned DEFAULT '1',
  `show_description` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`project_category_id`),
  KEY `idxLeft` (`project_category_id`,`lft`),
  KEY `idxRight` (`project_category_id`,`rgt`),
  KEY `idxPrimaryRgtLft` (`project_category_id`,`rgt`,`lft`,`is_active`,`is_deleted`),
  KEY `idxActive` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_cc_license` (
  `license_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `by` int(1) DEFAULT NULL,
  `nc` int(1) DEFAULT NULL,
  `nd` int(1) DEFAULT NULL,
  `sa` int(1) DEFAULT NULL,
  PRIMARY KEY (`license_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_follower` (
  `project_follower_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`project_follower_id`),
  KEY `FIND_FOLLOWER` (`project_id`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_gallery_picture` (
  `project_id` int(11) NOT NULL,
  `sequence` int(11) NOT NULL,
  `picture_src` varchar(255) NOT NULL,
  PRIMARY KEY (`project_id`,`sequence`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_package_type` (
  `project_id` int(11) NOT NULL,
  `file_id` int(11) NOT NULL,
  `package_type_id` int(11) NOT NULL,
  PRIMARY KEY (`project_id`,`file_id`),
  KEY `idx_type_id` (`package_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_rating` (
  `rating_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL DEFAULT '0',
  `project_id` int(11) NOT NULL DEFAULT '0',
  `user_like` int(1) DEFAULT '0',
  `user_dislike` int(1) DEFAULT '0',
  `comment_id` int(11) DEFAULT '0' COMMENT 'review for rating',
  `rating_active` int(1) DEFAULT '1' COMMENT 'active = 1, deleted = 0',
  `source_id` int(1) DEFAULT '0',
  `source_pk` int(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  KEY `idx_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_updates` (
  `project_update_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL DEFAULT '0',
  `member_id` int(11) NOT NULL DEFAULT '0',
  `public` int(1) NOT NULL DEFAULT '0',
  `title` varchar(200) DEFAULT NULL,
  `text` text,
  `created_at` datetime DEFAULT '0000-00-00 00:00:00',
  `changed_at` datetime DEFAULT '0000-00-00 00:00:00',
  `source_id` int(11) DEFAULT '0',
  `source_pk` int(11) DEFAULT NULL,
  PRIMARY KEY (`project_update_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_widget` (
  `widget_id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `config` text,
  PRIMARY KEY (`widget_id`),
  KEY `idxPROJECT` (`project_id`),
  KEY `idxUUID` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_widget_default` (
  `widget_id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `config` text,
  PRIMARY KEY (`widget_id`),
  KEY `idxPROJECT` (`project_id`),
  KEY `idxUuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue` (
  `queue_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(100) NOT NULL,
  `timeout` smallint(5) unsigned NOT NULL DEFAULT '30',
  PRIMARY KEY (`queue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue_message` (
  `message_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue_id` int(10) unsigned NOT NULL,
  `handle` char(32) DEFAULT NULL,
  `body` text NOT NULL,
  `md5` char(32) NOT NULL,
  `timeout` decimal(14,4) unsigned DEFAULT NULL,
  `created` int(10) unsigned NOT NULL,
  PRIMARY KEY (`message_id`),
  UNIQUE KEY `message_handle` (`handle`),
  KEY `message_queueid` (`queue_id`),
  CONSTRAINT `queue_message_ibfk_1` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`queue_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_comment` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `comment_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `is_deleted` int(1) DEFAULT NULL,
  `is_active` int(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idxComment` (`comment_id`),
  KEY `idxMember` (`reported_by`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `report_comment_created` BEFORE INSERT ON `reports_comment` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_member` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `is_deleted` int(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idxMemberId` (`member_id`),
  KEY `idxReportedBy` (`reported_by`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `reports_member_created` BEFORE INSERT ON `reports_member` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;

  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_project` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idxReport` (`project_id`,`reported_by`,`is_deleted`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `remember_me_id` varchar(255) NOT NULL,
  `expiry` datetime DEFAULT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `idx_remember` (`member_id`,`remember_me_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_cat_prod_count` (
  `project_category_id` int(11) NOT NULL,
  `package_type_id` int(11) DEFAULT NULL,
  `count_product` int(11) DEFAULT NULL,
  KEY `idx_package` (`project_category_id`,`package_type_id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_cat_tree` (
  `project_category_id` int(11) NOT NULL,
  `lft` int(11) NOT NULL,
  `rgt` int(11) NOT NULL,
  `title` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `name_legacy` varchar(50) COLLATE latin1_general_ci DEFAULT NULL,
  `is_active` int(1) DEFAULT NULL,
  `orderPos` int(11) DEFAULT NULL,
  `depth` int(11) NOT NULL,
  `ancestor_id_path` varchar(100) COLLATE latin1_general_ci DEFAULT NULL,
  `ancestor_path` varchar(256) COLLATE latin1_general_ci DEFAULT NULL,
  `ancestor_path_legacy` varchar(256) COLLATE latin1_general_ci DEFAULT NULL,
  `stores` varchar(256) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`project_category_id`,`lft`,`rgt`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_daily` (
  `daily_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `project_category_id` int(11) DEFAULT '0' COMMENT 'Category',
  `project_type_id` int(11) NOT NULL COMMENT 'type of the project',
  `count_views` int(11) DEFAULT '0',
  `count_plings` int(11) DEFAULT '0',
  `count_updates` int(11) DEFAULT NULL,
  `count_comments` int(11) DEFAULT NULL,
  `count_followers` int(11) DEFAULT NULL,
  `count_supporters` int(11) DEFAULT NULL,
  `count_money` float DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `year` int(11) DEFAULT NULL COMMENT 'z.B.: 1988',
  `month` int(11) DEFAULT NULL COMMENT 'z.b: 1-12',
  `day` int(11) DEFAULT NULL COMMENT 'z.B. 1-31',
  `year_week` int(11) DEFAULT NULL COMMENT 'z.b.: 201232',
  `ranking_value` float DEFAULT NULL,
  PRIMARY KEY (`daily_id`),
  KEY `indexKeys` (`project_id`,`project_category_id`,`project_type_id`),
  KEY `project_id` (`project_id`),
  KEY `project_category_id` (`project_category_id`),
  KEY `project_type_id` (`project_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Store daily statistic';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_daily_pageviews` (
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `cnt` int(11) DEFAULT NULL,
  `project_category_id` int(11) NOT NULL,
  `created_at` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_downloads_half_year` (
  `project_id` int(11) NOT NULL DEFAULT '0',
  `project_category_id` int(11) NOT NULL DEFAULT '0',
  `ppload_collection_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `amount` bigint(21) NOT NULL DEFAULT '0',
  `category_title` varchar(100) CHARACTER SET utf8 NOT NULL,
  KEY `idx_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_downloads_quarter_year` (
  `project_id` int(11) NOT NULL DEFAULT '0',
  `project_category_id` int(11) NOT NULL DEFAULT '0',
  `ppload_collection_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `amount` bigint(21) NOT NULL DEFAULT '0',
  `category_title` varchar(100) CHARACTER SET utf8 NOT NULL,
  KEY `idx_project_id` (`project_id`),
  KEY `idx_collection_id` (`ppload_collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stat_now` (
  `project_id` tinyint NOT NULL,
  `project_type_id` tinyint NOT NULL,
  `project_category_id` tinyint NOT NULL,
  `count_views` tinyint NOT NULL,
  `count_plings` tinyint NOT NULL,
  `count_updates` tinyint NOT NULL,
  `count_comments` tinyint NOT NULL,
  `count_followers` tinyint NOT NULL,
  `count_supporters` tinyint NOT NULL,
  `count_money` tinyint NOT NULL,
  `ranking_value` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `year` tinyint NOT NULL,
  `month` tinyint NOT NULL,
  `day` tinyint NOT NULL,
  `year_week` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_page_views` (
  `stat_page_views_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the view',
  `ip` varchar(45) NOT NULL COMMENT 'User-IP',
  `member_id` int(11) DEFAULT NULL COMMENT 'ID of the member, if possible',
  PRIMARY KEY (`stat_page_views_id`),
  KEY `idx_created` (`created_at`,`project_id`),
  KEY `project_id` (`project_id`),
  KEY `idx_member` (`member_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=16232 DEFAULT CHARSET=utf8 COMMENT='Counter of project-page views';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_page_views_mv` (
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `count_views` bigint(21) NOT NULL DEFAULT '0',
  `count_visitor` bigint(21) NOT NULL DEFAULT '0',
  `last_view` timestamp NULL DEFAULT NULL COMMENT 'Timestamp of the view',
  KEY `idx_project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_page_views_today_mv` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `count_views` int(11) DEFAULT '0',
  `count_visitor` int(11) DEFAULT '0',
  `last_view` datetime DEFAULT NULL COMMENT 'Timestamp of the view',
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stat_plings` (
  `project_id` tinyint NOT NULL,
  `amount_received` tinyint NOT NULL,
  `count_plings` tinyint NOT NULL,
  `count_plingers` tinyint NOT NULL,
  `latest_pling` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_projects` (
  `project_id` int(11) NOT NULL DEFAULT '0',
  `member_id` int(11) NOT NULL DEFAULT '0',
  `content_type` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT 'text',
  `project_category_id` int(11) NOT NULL DEFAULT '0',
  `hive_category_id` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `uuid` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `pid` int(11) DEFAULT NULL COMMENT 'ParentId',
  `type_id` int(11) DEFAULT '0' COMMENT '0 = DummyProject, 1 = Project, 2 = Update',
  `title` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `description` text CHARACTER SET utf8,
  `version` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `image_big` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `image_small` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `content_url` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL COMMENT 'Member_id of the creator. Importent for groups.',
  `facebook_code` text CHARACTER SET utf8,
  `github_code` text CHARACTER SET utf8,
  `twitter_code` text CHARACTER SET utf8,
  `google_code` text CHARACTER SET utf8,
  `link_1` text CHARACTER SET utf8,
  `embed_code` text CHARACTER SET utf8,
  `ppload_collection_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `validated` int(1) DEFAULT '0',
  `validated_at` datetime DEFAULT NULL,
  `featured` int(1) DEFAULT '0',
  `approved` int(1) DEFAULT '0',
  `amount` int(11) DEFAULT NULL,
  `amount_period` varchar(45) CHARACTER SET utf8 DEFAULT NULL,
  `claimable` int(1) DEFAULT NULL,
  `claimed_by_member` int(11) DEFAULT NULL,
  `count_likes` int(11) DEFAULT '0',
  `count_dislikes` int(11) DEFAULT '0',
  `count_comments` int(11) DEFAULT '0',
  `count_downloads_hive` int(11) DEFAULT '0',
  `source_id` int(11) DEFAULT '0',
  `source_pk` int(11) DEFAULT NULL,
  `source_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `project_validated` int(1) DEFAULT '0',
  `project_uuid` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `project_status` int(11) NOT NULL DEFAULT '0',
  `project_created_at` datetime DEFAULT NULL,
  `project_changed_at` datetime DEFAULT NULL,
  `laplace_score` int(11) DEFAULT NULL,
  `member_type` int(1) NOT NULL DEFAULT '0' COMMENT 'Type: 0 = Member, 1 = group',
  `project_member_id` int(10) NOT NULL DEFAULT '0',
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `profile_image_url` varchar(355) CHARACTER SET utf8 DEFAULT '/images/system/default-profile.png' COMMENT 'URL to the profile-image',
  `city` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `member_created_at` datetime DEFAULT NULL,
  `paypal_mail` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `cat_title` varchar(100) CHARACTER SET utf8 NOT NULL,
  `cat_xdg_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `cat_name_legacy` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `cat_show_description` int(1) NOT NULL DEFAULT '0',
  `amount_received` double(19,2) DEFAULT NULL,
  `count_plings` bigint(21) DEFAULT '0',
  `count_plingers` bigint(21) DEFAULT '0',
  `latest_pling` timestamp NULL DEFAULT NULL COMMENT 'When did paypal say, that this pling was payed successfull',
  `amount_reports` bigint(21) DEFAULT '0',
  `package_types` text CHARACTER SET utf8,
  `package_names` text CHARACTER SET latin1,
  `tags` text COLLATE latin1_general_ci,
  PRIMARY KEY (`project_id`),
  KEY `idx_cat` (`project_category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stat_projects_v` (
  `project_id` tinyint NOT NULL,
  `member_id` tinyint NOT NULL,
  `content_type` tinyint NOT NULL,
  `project_category_id` tinyint NOT NULL,
  `hive_category_id` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `pid` tinyint NOT NULL,
  `type_id` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `image_big` tinyint NOT NULL,
  `image_small` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `content_url` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `changed_at` tinyint NOT NULL,
  `deleted_at` tinyint NOT NULL,
  `creator_id` tinyint NOT NULL,
  `facebook_code` tinyint NOT NULL,
  `github_code` tinyint NOT NULL,
  `twitter_code` tinyint NOT NULL,
  `google_code` tinyint NOT NULL,
  `link_1` tinyint NOT NULL,
  `embed_code` tinyint NOT NULL,
  `ppload_collection_id` tinyint NOT NULL,
  `validated` tinyint NOT NULL,
  `validated_at` tinyint NOT NULL,
  `featured` tinyint NOT NULL,
  `approved` tinyint NOT NULL,
  `amount` tinyint NOT NULL,
  `amount_period` tinyint NOT NULL,
  `claimable` tinyint NOT NULL,
  `claimed_by_member` tinyint NOT NULL,
  `count_likes` tinyint NOT NULL,
  `count_dislikes` tinyint NOT NULL,
  `count_comments` tinyint NOT NULL,
  `count_downloads_hive` tinyint NOT NULL,
  `source_id` tinyint NOT NULL,
  `source_pk` tinyint NOT NULL,
  `source_type` tinyint NOT NULL,
  `project_validated` tinyint NOT NULL,
  `project_uuid` tinyint NOT NULL,
  `project_status` tinyint NOT NULL,
  `project_created_at` tinyint NOT NULL,
  `member_type` tinyint NOT NULL,
  `project_member_id` tinyint NOT NULL,
  `project_changed_at` tinyint NOT NULL,
  `laplace_score` tinyint NOT NULL,
  `username` tinyint NOT NULL,
  `profile_image_url` tinyint NOT NULL,
  `city` tinyint NOT NULL,
  `country` tinyint NOT NULL,
  `member_created_at` tinyint NOT NULL,
  `paypal_mail` tinyint NOT NULL,
  `cat_title` tinyint NOT NULL,
  `cat_xdg_type` tinyint NOT NULL,
  `cat_name_legacy` tinyint NOT NULL,
  `cat_show_description` tinyint NOT NULL,
  `amount_received` tinyint NOT NULL,
  `count_plings` tinyint NOT NULL,
  `count_plingers` tinyint NOT NULL,
  `latest_pling` tinyint NOT NULL,
  `amount_reports` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_ranking_history` (
  `ranking_history_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `project_id` int(11) NOT NULL COMMENT 'ID of the project',
  `type_id` int(11) DEFAULT NULL,
  `project_category_id` int(11) DEFAULT '0' COMMENT 'Kategorie',
  `count_plings` int(11) DEFAULT '0',
  `count_views` int(11) DEFAULT '0',
  `count_comments` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `year` int(11) DEFAULT NULL COMMENT 'z.B.: 1988',
  `month` int(11) DEFAULT NULL COMMENT 'z.b: 1-12',
  `day` int(11) DEFAULT NULL COMMENT 'z.B. 1-31',
  `year_week` int(11) DEFAULT NULL COMMENT 'z.b.: 201232',
  `ranking` int(11) DEFAULT NULL,
  PRIMARY KEY (`ranking_history_id`)
) ENGINE=InnoDB AUTO_INCREMENT=739 DEFAULT CHARSET=utf8 COMMENT='Statistic of the ranking-values';
/*!40101 SET character_set_client = @saved_cs_client */;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stat_ratings` (
  `project_id` tinyint NOT NULL,
  `count_likes` tinyint NOT NULL,
  `count_dislikes` tinyint NOT NULL,
  `laplace_score` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stat_views` (
  `project_id` tinyint NOT NULL,
  `count_views` tinyint NOT NULL,
  `count_visitor` tinyint NOT NULL,
  `last_view` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `support` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL COMMENT 'Supporter',
  `status_id` int(11) DEFAULT '0' COMMENT 'Stati der donation: 0 = inactive, 1 = active (donated), 2 = payed successfull, 99 = deleted',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation-time',
  `donation_time` timestamp NULL DEFAULT NULL COMMENT 'When was a project plinged?',
  `active_time` timestamp NULL DEFAULT NULL COMMENT 'When did paypal say, that this donation was payed successfull',
  `delete_time` timestamp NULL DEFAULT NULL,
  `amount` double(10,2) DEFAULT '0.00' COMMENT 'Amount of money',
  `comment` varchar(140) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'Comment from the supporter',
  `payment_provider` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  `payment_reference_key` varchar(255) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'uniquely identifies the request',
  `payment_transaction_id` varchar(255) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'uniquely identify caller (developer, facilliator, marketplace) transaction',
  `payment_raw_message` varchar(2000) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'the raw text message ',
  `payment_raw_error` varchar(2000) COLLATE latin1_general_ci DEFAULT NULL,
  `payment_status` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status_id` (`status_id`),
  KEY `member_id` (`member_id`),
  KEY `DONATION_IX_01` (`status_id`,`member_id`,`active_time`,`amount`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(45) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `idx_name` (`tag_name`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_group` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(45) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_group_item` (
  `tag_group_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_group_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_group_item_id`),
  KEY `tag_group_idx` (`tag_group_id`),
  KEY `tag_idx` (`tag_id`),
  CONSTRAINT `tag` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`tag_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `tag_group` FOREIGN KEY (`tag_group_id`) REFERENCES `tag_group` (`group_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_object` (
  `tag_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `tag_type_id` int(11) NOT NULL,
  `tag_object_id` int(11) NOT NULL,
  `tag_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tag_changed` datetime DEFAULT NULL,
  PRIMARY KEY (`tag_item_id`),
  UNIQUE KEY `tags_unique` (`tag_id`,`tag_type_id`,`tag_object_id`),
  KEY `tags_idx` (`tag_id`),
  KEY `types_idx` (`tag_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=CURRENT_USER*/ /*!50003 TRIGGER `ocs-apiserver`.`tag_object_BEFORE_INSERT` BEFORE INSERT ON `tag_object` FOR EACH ROW
BEGIN
	IF NEW.tag_changed IS NULL THEN
		SET NEW.tag_changed = NOW();
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_type` (
  `tag_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_type_name` varchar(45) COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`tag_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_reported_projects` (
  `project_id` tinyint NOT NULL,
  `amount_reports` tinyint NOT NULL,
  `latest_report` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=CURRENT_USER*/ /*!50106 EVENT `e_generate_page_views_today` ON SCHEDULE EVERY 30 MINUTE STARTS '2017-06-30 05:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Regenerates page views counter for projects on every hour' DO CALL pling.generate_stat_views_today() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=CURRENT_USER*/ /*!50106 EVENT `e_generate_stat_cat_prod_count` ON SCHEDULE EVERY 2 MINUTE STARTS '2017-08-11 05:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Regenerates generate_stat_cat_prod_count table' DO CALL pling.generate_stat_cat_prod_count() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=CURRENT_USER*/ /*!50106 EVENT `e_generate_stat_cat_tree` ON SCHEDULE EVERY 60 MINUTE STARTS '2017-08-17 05:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Regenerates generate_stat_cat_tree table' DO CALL pling.generate_stat_cat_tree() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=CURRENT_USER*/ /*!50106 EVENT `e_generate_stat_projects` ON SCHEDULE EVERY 5 MINUTE STARTS '2017-08-08 05:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Regenerates stat_projects table' DO CALL pling.generate_stat_project() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER FUNCTION `get_stores`(category_id INT) RETURNS text CHARSET utf8
    READS SQL DATA
BEGIN

DECLARE _stores text DEFAULT '';

SELECT 
    GROUP_CONCAT(csc.store_id) AS store_id_list
INTO _stores
FROM
    config_store_category AS csc
WHERE
    csc.project_category_id IN (SELECT 
            pc2.project_category_id AS ancestor_id
        FROM
            project_category AS pc,
            project_category AS pc2
        WHERE
            (pc.lft BETWEEN pc2.lft AND pc2.rgt)
                AND pc.project_category_id = category_id
        GROUP BY pc2.lft
        ORDER BY pc2.lft)
;

RETURN _stores;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER FUNCTION `laplace_score`(upvotes INT, downvotes INT) RETURNS int(11)
BEGIN
	DECLARE score INT(10);
    SET score = (round(((upvotes + 6) / ((upvotes + downvotes) + 12)),2) * 100);
	RETURN score;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `create_stat_ranking_categroy`(IN `project_category_id` INT)
BEGIN


	IF(project_category_id = 0 || project_category_id IS NULL) THEN
	
		#ALL
		DELETE FROM pling.stat_ranking_category WHERE project_category_id = 0;
	
		SET @i=0;
		insert into stat_ranking_category (
			SELECT null,0,project_id, title, (round(((p.count_likes + 6) / ((p.count_likes + p.count_dislikes) + 12)),2) * 100) as score, @i:=@i+1 AS rank 
			 FROM pling.project p 
			 WHERE p.status = 100
			 ORDER BY (round(((p.count_likes + 6) / ((p.count_likes + p.count_dislikes) + 12)),2) * 100) DESC
		);
	ELSE
		#CATEGORY
		DELETE FROM pling.stat_ranking_category WHERE project_category_id = project_category_id;
	
		SET @i=0;
		insert into stat_ranking_category (
			SELECT null,project_category_id,project_id, title, (round(((p.count_likes + 6) / ((p.count_likes + p.count_dislikes) + 12)),2) * 100) as score, @i:=@i+1 AS rank 
			 FROM pling.project p 
			 WHERE p.status = 100
			 AND p.project_category_id = project_category_id
			 ORDER BY (round(((p.count_likes + 6) / ((p.count_likes + p.count_dislikes) + 12)),2) * 100) DESC
		);
	
	END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `generate_stat_cat_prod_count`()
BEGIN

    DROP TABLE IF EXISTS tmp_stat_cat_prod_count;
    CREATE TABLE tmp_stat_cat_prod_count
    (
      `project_category_id` int(11) NOT NULL,
      `package_type_id` int(11) NULL,
      `count_product` int(11) NULL,
      INDEX `idx_package` (`project_category_id`,`package_type_id`)
    )
      ENGINE Memory
      AS
		SELECT 
			sct2.project_category_id,
			NULL as package_type_id,
			count(distinct p.project_id) as count_product
		FROM stat_cat_tree as sct1
		JOIN stat_cat_tree as sct2 ON sct1.lft between sct2.lft AND sct2.rgt
		LEFT JOIN stat_projects as p ON p.project_category_id = sct1.project_category_id
		GROUP BY sct2.project_category_id

		UNION

		SELECT 
			sct2.project_category_id, 
			ppt.package_type_id,
			count(distinct p.project_id) as count_product
		FROM stat_cat_tree as sct1
		JOIN stat_cat_tree as sct2 ON sct1.lft between sct2.lft AND sct2.rgt
		JOIN stat_projects as p ON p.project_category_id = sct1.project_category_id
		JOIN project_package_type AS ppt ON ppt.project_id = p.project_id
		GROUP BY sct2.lft, ppt.package_type_id
	;
        
    IF EXISTS(SELECT table_name
              FROM INFORMATION_SCHEMA.TABLES
              WHERE table_schema = DATABASE()
                    AND table_name = 'stat_cat_prod_count')

    THEN

      RENAME TABLE stat_cat_prod_count TO old_stat_cat_prod_count, tmp_stat_cat_prod_count TO stat_cat_prod_count;

    ELSE

      RENAME TABLE tmp_stat_cat_prod_count TO stat_cat_prod_count;

    END IF;


    DROP TABLE IF EXISTS old_stat_cat_prod_count;

  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `generate_stat_cat_tree`()
BEGIN

	DROP TABLE IF EXISTS tmp_stat_cat_tree;
	CREATE TABLE tmp_stat_cat_tree 
	(
      `project_category_id` int(11) NOT NULL,
      `lft` int(11) NOT NULL,
      `rgt` int(11) NOT NULL,
	  `title` varchar(100) NOT NULL,
      `name_legacy` varchar(50) NULL,
      `is_active` int(1),
      `orderPos` int(11) NULL,
      `depth` int(11) NOT NULL,
      `ancestor_id_path` varchar(100),
      `ancestor_path` varchar(256),
      `ancestor_path_legacy` varchar(256),
      PRIMARY KEY `primary` (project_category_id, lft, rgt)
    )
    ENGINE Memory
	AS
	  SELECT
		pc.project_category_id,
		pc.lft,
		pc.rgt,
		pc.title,
		pc.name_legacy,
		pc.is_active,
		pc.orderPos,
		count(pc.lft) - 1                                        AS depth,
		GROUP_CONCAT(pc2.project_category_id ORDER BY pc2.lft)   AS ancestor_id_path,
		GROUP_CONCAT(pc2.title ORDER BY pc2.lft SEPARATOR ' | ') AS ancestor_path,
		GROUP_CONCAT(IF(LENGTH(TRIM(pc2.name_legacy))>0,pc2.name_legacy,pc2.title) ORDER BY pc2.lft SEPARATOR ' | ') AS ancestor_path_legacy
	  FROM project_category AS pc, project_category AS pc2
	  WHERE (pc.lft BETWEEN pc2.lft AND pc2.rgt) AND pc.is_active = 1 and pc2.is_active = 1
	  GROUP BY pc.lft -- HAVING depth >= 1
	  ORDER BY pc.lft, pc.orderPos
      ;
      
	DROP TABLE IF EXISTS tmp_stat_cat;
	CREATE TABLE tmp_stat_cat 
	(
      `project_category_id` int(11) NOT NULL,
      `lft` int(11) NOT NULL,
      `rgt` int(11) NOT NULL,
	  `title` varchar(100) NOT NULL,
      `name_legacy` varchar(50) NULL,
      `is_active` int(1),
      `orderPos` int(11) NULL,
      `depth` int(11) NOT NULL,
      `ancestor_id_path` varchar(100),
      `ancestor_path` varchar(256),
      `ancestor_path_legacy` varchar(256),
      `stores` varchar(256),
      PRIMARY KEY `primary` (project_category_id, lft, rgt)
    )
    ENGINE Memory
    AS
    SELECT 
		sct.*,
		GROUP_CONCAT(csc.store_id ORDER BY csc.store_id) AS stores
	FROM
		tmp_stat_cat_tree AS sct
	LEFT JOIN
		config_store_category AS csc ON FIND_IN_SET(csc.project_category_id,sct.ancestor_id_path)
	GROUP BY sct.project_category_id
	ORDER BY sct.lft
    ;

    IF EXISTS(SELECT table_name
              FROM INFORMATION_SCHEMA.TABLES
              WHERE table_schema = DATABASE()
                    AND table_name = 'stat_cat_tree')
    
    THEN

		RENAME TABLE stat_cat_tree TO old_stat_cat_tree, tmp_stat_cat TO stat_cat_tree;
	
    ELSE
    
		RENAME TABLE tmp_stat_cat TO stat_cat_tree;

    END IF;


    DROP TABLE IF EXISTS old_stat_cat_tree;
    DROP TABLE IF EXISTS tmp_stat_cat_tree;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `generate_stat_project`()
BEGIN
    DROP TABLE IF EXISTS tmp_reported_projects;
    CREATE TEMPORARY TABLE tmp_reported_projects
    (PRIMARY KEY `primary` (project_id) )
      AS
        SELECT
          `reports_project`.`project_id` AS `project_id`,
          COUNT(`reports_project`.`project_id`) AS `amount_reports`,
          MAX(`reports_project`.`created_at`) AS `latest_report`
        FROM
          `reports_project`
        WHERE
          (`reports_project`.`is_deleted` = 0)
        GROUP BY `reports_project`.`project_id`
    ;

    DROP TABLE IF EXISTS tmp_project_package_types;
    CREATE TEMPORARY TABLE tmp_project_package_types
    (PRIMARY KEY `primary` (project_id))
      ENGINE MyISAM
      AS
        SELECT
          project_id,
          GROUP_CONCAT(DISTINCT project_package_type.package_type_id) AS package_type_id_list,
          GROUP_CONCAT(DISTINCT package_types.`name`) AS `package_name_list`
        FROM
          project_package_type
          JOIN
          package_types ON project_package_type.package_type_id = package_types.package_type_id
        WHERE
          package_types.is_active = 1
        GROUP BY project_id
    ;

    DROP TABLE IF EXISTS tmp_project_tags;
    CREATE TEMPORARY TABLE tmp_project_tags
    (PRIMARY KEY `primary` (tag_project_id))
      ENGINE MyISAM
    AS
      SELECT GROUP_CONCAT(tag.tag_name) AS tag_names, tgo.tag_object_id AS tag_project_id
      FROM tag_object AS tgo
        JOIN tag ON tag.tag_id = tgo.tag_id
      WHERE tag_type_id = 1
      GROUP BY tgo.tag_object_id
      ORDER BY tgo.tag_object_id;

--    DROP TABLE IF EXISTS tmp_project_tags;
--    CREATE TEMPORARY TABLE tmp_project_tags
--    (PRIMARY KEY `primary` (tag_project_id))
--      ENGINE MyISAM
--    AS
--      SELECT GROUP_CONCAT(concat(tg.group_name, '##', tag.tag_name)) AS tag_names, tgo.tag_object_id AS tag_project_id
--      FROM tag_object AS tgo
--        JOIN tag ON tag.tag_id = tgo.tag_id
--        JOIN tag_group_item as tgi ON tgi.tag_id = tgo.tag_id
--        JOIN tag_group as tg ON tg.group_id = tgi.tag_group_id
--      WHERE tag_type_id = 1
--      GROUP BY tgo.tag_object_id
--      ORDER BY tgo.tag_object_id;


    DROP TABLE IF EXISTS tmp_stat_projects;
    CREATE TABLE tmp_stat_projects
    (PRIMARY KEY `primary` (`project_id`), INDEX `idx_cat` (`project_category_id`))
      ENGINE MyISAM
      AS
        SELECT
          `project`.`project_id` AS `project_id`,
          `project`.`member_id` AS `member_id`,
          `project`.`content_type` AS `content_type`,
          `project`.`project_category_id` AS `project_category_id`,
          `project`.`hive_category_id` AS `hive_category_id`,
          `project`.`status` AS `status`,
          `project`.`uuid` AS `uuid`,
          `project`.`pid` AS `pid`,
          `project`.`type_id` AS `type_id`,
          `project`.`title` AS `title`,
          `project`.`description` AS `description`,
          `project`.`version` AS `version`,
          `project`.`image_big` AS `image_big`,
          `project`.`image_small` AS `image_small`,
          `project`.`start_date` AS `start_date`,
          `project`.`content_url` AS `content_url`,
          `project`.`created_at` AS `created_at`,
          `project`.`changed_at` AS `changed_at`,
          `project`.`deleted_at` AS `deleted_at`,
          `project`.`creator_id` AS `creator_id`,
          `project`.`facebook_code` AS `facebook_code`,
          `project`.`github_code` AS `github_code`,
          `project`.`twitter_code` AS `twitter_code`,
          `project`.`google_code` AS `google_code`,
          `project`.`link_1` AS `link_1`,
          `project`.`embed_code` AS `embed_code`,
          `project`.`ppload_collection_id` AS `ppload_collection_id`,
          `project`.`validated` AS `validated`,
          `project`.`validated_at` AS `validated_at`,
          `project`.`featured` AS `featured`,
          `project`.`approved` AS `approved`,
          `project`.`amount` AS `amount`,
          `project`.`amount_period` AS `amount_period`,
          `project`.`claimable` AS `claimable`,
          `project`.`claimed_by_member` AS `claimed_by_member`,
          `project`.`count_likes` AS `count_likes`,
          `project`.`count_dislikes` AS `count_dislikes`,
          `project`.`count_comments` AS `count_comments`,
          `project`.`count_downloads_hive` AS `count_downloads_hive`,
          `project`.`source_id` AS `source_id`,
          `project`.`source_pk` AS `source_pk`,
          `project`.`source_type` AS `source_type`,
          `project`.`validated` AS `project_validated`,
          `project`.`uuid` AS `project_uuid`,
          `project`.`status` AS `project_status`,
          `project`.`created_at` AS `project_created_at`,
          `project`.`changed_at` AS `project_changed_at`,
          laplace_score(`project`.`count_likes`, `project`.`count_dislikes`) AS `laplace_score`,
          `member`.`type` AS `member_type`,
          `member`.`member_id` AS `project_member_id`,
          `member`.`username` AS `username`,
          `member`.`profile_image_url` AS `profile_image_url`,
          `member`.`city` AS `city`,
          `member`.`country` AS `country`,
          `member`.`created_at` AS `member_created_at`,
          `member`.`paypal_mail` AS `paypal_mail`,
          `project_category`.`title` AS `cat_title`,
          `project_category`.`xdg_type` AS `cat_xdg_type`,
          `project_category`.`name_legacy` AS `cat_name_legacy`,
          `project_category`.`show_description` AS `cat_show_description`,
          `stat_plings`.`amount_received` AS `amount_received`,
          `stat_plings`.`count_plings` AS `count_plings`,
          `stat_plings`.`count_plingers` AS `count_plingers`,
          `stat_plings`.`latest_pling` AS `latest_pling`,
          `trp`.`amount_reports` AS `amount_reports`,
          `tppt`.`package_type_id_list` AS `package_types`,
          `tppt`.`package_name_list` AS `package_names`,
           `t`.`tag_names` AS `tags`
        FROM
          `project`
          JOIN `member` ON `member`.`member_id` = `project`.`member_id`
          JOIN `project_category` ON `project`.`project_category_id` = `project_category`.`project_category_id`
          LEFT JOIN `stat_plings` ON `stat_plings`.`project_id` = `project`.`project_id`
          LEFT JOIN `tmp_reported_projects` AS trp ON `trp`.`project_id` = `project`.`project_id`
          LEFT JOIN `tmp_project_package_types` AS tppt ON tppt.project_id = `project`.project_id
          LEFT JOIN `tmp_project_tags` AS t ON t.`tag_project_id` = project.`project_id`
        WHERE
          `member`.`is_deleted` = 0
          AND `member`.`is_active` = 1
          AND `project`.`type_id` = 1
          AND `project`.`status` = 100
          AND `project_category`.`is_active` = 1
    ;

    RENAME TABLE stat_projects TO old_stat_projects, tmp_stat_projects TO stat_projects;

    DROP TABLE IF EXISTS old_stat_projects;
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `generate_stat_views_today`()
BEGIN

    DROP TABLE IF EXISTS `temp_stat_views_today`;

    CREATE TABLE `temp_stat_views_today` (
      `id`            INT      NOT NULL AUTO_INCREMENT,
      `project_id`    INT(11)  NOT NULL,
      `count_views`   INT(11)  NULL     DEFAULT 0,
      `count_visitor` INT(11)  NULL     DEFAULT 0,
      `last_view`     DATETIME NULL     DEFAULT NULL,
      PRIMARY KEY (`id`),
      INDEX `idx_project` (`project_id` ASC)
    )
      ENGINE = MyISAM
    AS
      SELECT
        project_id,
        COUNT(*) AS count_views,
        COUNT(DISTINCT `stat_page_views`.`ip`) AS `count_visitor`,
        MAX(`stat_page_views`.`created_at`) AS `last_view`
      FROM stat_page_views
      WHERE (stat_page_views.`created_at`
      BETWEEN DATE_FORMAT(NOW(), '%Y-%m-%d 00:00') AND DATE_FORMAT(NOW(), '%Y-%m-%d 23:59')
      )
      GROUP BY project_id;

    IF EXISTS(SELECT table_name
              FROM INFORMATION_SCHEMA.TABLES
              WHERE table_schema = DATABASE()
                    AND table_name = 'stat_page_views_today_mv'
    )

    THEN

    ALTER TABLE `stat_page_views_today_mv`
      RENAME TO  `old_stat_views_today_mv` ;
      
    END IF;

    ALTER TABLE `temp_stat_views_today`
      RENAME TO  `stat_page_views_today_mv` ;

    DROP TABLE IF EXISTS `old_stat_views_today_mv`;

  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `solr_query_deleted_pk`(IN lastIndexed VARCHAR(255))
BEGIN
    SELECT project_id
    FROM project
      JOIN member ON member.member_id = project.member_id
      JOIN project_category AS pc ON pc.project_category_id = project.project_category_id
    WHERE project.deleted_at > lastIndexed OR member.deleted_at > lastIndexed OR
          (project.changed_at > lastIndexed AND project.status < 100);
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `solr_query_delta`(IN lastIndexed varchar(255))
BEGIN
    SELECT DISTINCT project_id
    FROM project
      JOIN member ON member.member_id = project.member_id
      JOIN project_category AS pc ON pc.project_category_id = project.project_category_id
      LEFT JOIN tag_object AS tgo ON tgo.tag_object_id = project.project_id AND tgo.tag_type_id = 1
    WHERE (project.`status` = 100 AND project.`type_id` = 1 AND member.`is_active` = 1 AND pc.`is_active` = 1 AND project.changed_at > lastIndexed)
    OR (project.`status` = 100 AND project.`type_id` = 1 AND member.`is_active` = 1 AND pc.`is_active` = 1 AND (tgo.tag_created > lastIndexed OR tgo.tag_changed > lastIndexed))
    ;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `solr_query_delta_import`(IN projectID INT(11))
BEGIN
    DROP TABLE IF EXISTS tmp_project_tags;
    CREATE TEMPORARY TABLE tmp_project_tags AS
      SELECT GROUP_CONCAT(tag.tag_name) AS tag_names, tgo.tag_object_id AS tag_project_id 
		FROM tag_object AS tgo
		JOIN tag ON tag.tag_id = tgo.tag_id
		WHERE tag_type_id = 1 
		GROUP BY tgo.tag_object_id
        ORDER BY tgo.tag_object_id;
    
    DROP TABLE IF EXISTS tmp_cat_tree;
    CREATE TEMPORARY TABLE tmp_cat_tree AS
      SELECT
        pc.project_category_id,
        pc.title,
        pc.is_active,
        count(pc.lft)                                            AS depth,
        GROUP_CONCAT(pc2.project_category_id ORDER BY pc2.lft)   AS ancestor_id_path,
        GROUP_CONCAT(pc2.title ORDER BY pc2.lft SEPARATOR ' | ') AS ancestor_path
      FROM project_category AS pc, project_category AS pc2
      WHERE (pc.lft BETWEEN pc2.lft AND pc2.rgt)
      GROUP BY pc.lft
      ORDER BY pc.lft;

    DROP TABLE IF EXISTS tmp_cat_store;
    CREATE TEMPORARY TABLE tmp_cat_store AS
      SELECT
        tct.project_category_id,
        tct.ancestor_id_path,
        tct.title,
        tct.is_active,
        group_concat(store_id) AS stores
      FROM tmp_cat_tree AS tct, config_store_category AS csc
      WHERE FIND_IN_SET(csc.project_category_id, tct.ancestor_id_path) > 0
      GROUP BY tct.project_category_id
      ORDER BY tct.project_category_id;

    DROP TABLE IF EXISTS solr_project_package_types;
    CREATE TEMPORARY TABLE solr_project_package_types
    (PRIMARY KEY `primary` (package_project_id))
    ENGINE MyISAM
    AS
    SELECT 
		project_id as package_project_id,
		GROUP_CONCAT(DISTINCT project_package_type.package_type_id) AS package_type_id_list,
		GROUP_CONCAT(DISTINCT package_types.`name`) AS `package_name_list`
	FROM
		project_package_type
	JOIN
		package_types ON project_package_type.package_type_id = package_types.package_type_id
	WHERE 
		package_types.is_active = 1
	GROUP BY project_id
	;

    SELECT
      project_id,
      project.member_id           AS project_member_id,
      project.project_category_id AS project_category_id,
      project.title               AS project_title,
      description,
      image_small,
      member.username,
      member.firstname,
      member.lastname,
      tcs.title                   AS cat_title,
      `project`.`count_likes`     AS `count_likes`,
      `project`.`count_dislikes`  AS `count_dislikes`,
      laplace_score(project.count_likes, project.count_dislikes) AS `laplace_score`,
      project.created_at,
      project.changed_at,
      tcs.stores,
      tcs.ancestor_id_path        AS `cat_id_ancestor_path`,
      sppt.package_type_id_list   AS `package_ids`,
      sppt.package_name_list      AS `package_names`,
      t.tag_names                 AS `tags`
    FROM project
      JOIN member ON member.member_id = project.member_id
      JOIN tmp_cat_store AS tcs ON project.project_category_id = tcs.project_category_id
      LEFT JOIN solr_project_package_types AS sppt ON sppt.package_project_id = project.project_id
      LEFT JOIN tmp_project_tags AS t ON t.tag_project_id = project.project_id
    WHERE project_id = projectID;
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_ALL_TABLES' */ ;
DELIMITER ;;
CREATE DEFINER=CURRENT_USER PROCEDURE `solr_query_import`()
BEGIN
    DROP TABLE IF EXISTS tmp_project_tags;
    CREATE TEMPORARY TABLE tmp_project_tags AS
      SELECT GROUP_CONCAT(tag.tag_name) AS tag_names, tgo.tag_object_id AS tag_project_id 
		FROM tag_object AS tgo
		JOIN tag ON tag.tag_id = tgo.tag_id
		WHERE tag_type_id = 1 
		GROUP BY tgo.tag_object_id
        ORDER BY tgo.tag_object_id;
    
    DROP TABLE IF EXISTS tmp_cat_tree;
    CREATE TEMPORARY TABLE tmp_cat_tree AS
      SELECT
        pc.project_category_id,
        pc.title,
        pc.is_active,
        count(pc.lft)                                            AS depth,
        GROUP_CONCAT(pc2.project_category_id ORDER BY pc2.lft)   AS ancestor_id_path,
        GROUP_CONCAT(pc2.title ORDER BY pc2.lft SEPARATOR ' | ') AS ancestor_path
      FROM project_category AS pc, project_category AS pc2
      WHERE (pc.lft BETWEEN pc2.lft AND pc2.rgt)
      GROUP BY pc.lft
      ORDER BY pc.lft;

    DROP TABLE IF EXISTS tmp_cat_store;
    CREATE TEMPORARY TABLE tmp_cat_store AS
      SELECT
        tct.project_category_id,
        tct.ancestor_id_path,
        tct.title,
        tct.is_active,
        group_concat(store_id) AS stores
      FROM tmp_cat_tree AS tct, config_store_category AS csc
      WHERE FIND_IN_SET(csc.project_category_id, tct.ancestor_id_path) > 0
      GROUP BY tct.project_category_id
      ORDER BY tct.project_category_id;

    DROP TABLE IF EXISTS solr_project_package_types;
    CREATE TEMPORARY TABLE solr_project_package_types
    (PRIMARY KEY `primary` (package_project_id))
    ENGINE MyISAM
    AS
    SELECT 
		project_id as package_project_id,
		GROUP_CONCAT(DISTINCT project_package_type.package_type_id) AS package_type_id_list,
		GROUP_CONCAT(DISTINCT package_types.`name`) AS `package_name_list`
	FROM
		project_package_type
	JOIN
		package_types ON project_package_type.package_type_id = package_types.package_type_id
	WHERE 
		package_types.is_active = 1
	GROUP BY project_id
	;

    SELECT
      project_id,
      project.member_id           AS project_member_id,
      project.project_category_id AS project_category_id,
      project.title               AS project_title,
      description,
      image_small,
      member.username,
      member.firstname,
      member.lastname,
      tcs.title                   AS cat_title,
      `project`.`count_likes`     AS `count_likes`,
      `project`.`count_dislikes`  AS `count_dislikes`,
      laplace_score(project.count_likes, project.count_dislikes) AS `laplace_score`,
      project.created_at,
      project.changed_at,
      tcs.stores,
      tcs.ancestor_id_path        AS `cat_id_ancestor_path`,
      sppt.package_type_id_list   AS `package_ids`,
      sppt.package_name_list      AS `package_names`,
      t.tag_names                 AS `tags`
    FROM project
      JOIN member ON member.member_id = project.member_id
      JOIN tmp_cat_store AS tcs ON project.project_category_id = tcs.project_category_id
      LEFT JOIN solr_project_package_types AS sppt ON sppt.package_project_id = project.project_id
      LEFT JOIN tmp_project_tags AS t ON t.tag_project_id = project.project_id
    WHERE project.`status` = 100 AND project.`type_id` = 1 AND member.`is_active` = 1 AND tcs.`is_active` = 1;
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

USE `ocs-apiserver`;
/*!50001 DROP TABLE IF EXISTS `stat_now`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `stat_now` AS select `prj`.`project_id` AS `project_id`,`prj`.`type_id` AS `project_type_id`,`prj`.`project_category_id` AS `project_category_id`,(select count(1) from `stat_page_views` `pv` where ((`pv`.`project_id` = `prj`.`project_id`) and (`pv`.`created_at` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59'))) group by `pv`.`project_id`) AS `count_views`,(select count(1) from `plings` `p` where ((`p`.`project_id` = `prj`.`project_id`) and (`p`.`pling_time` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`p`.`status_id` in (2,3,4))) group by `p`.`project_id`) AS `count_plings`,(select count(1) from `project` `pu` where ((`pu`.`project_id` = `prj`.`project_id`) and (`pu`.`created_at` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`pu`.`type_id` = 2)) group by `pu`.`project_id`) AS `count_updates`,(select count(1) from `comments` `c` where ((`c`.`comment_target_id` = `prj`.`project_id`) and (`c`.`comment_created_at` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59'))) group by `c`.`comment_target_id`) AS `count_comments`,(select count(1) from `project_follower` `pf` where (`pf`.`project_id` = `prj`.`project_id`)) AS `count_followers`,(select count(distinct `p`.`member_id`) from `plings` `p` where ((`p`.`project_id` = 40) and (`p`.`status_id` in (2,3,4))) group by `p`.`project_id`) AS `count_supporters`,(select format(sum(`pt`.`amount`),2) from `plings` `pt` where ((`pt`.`project_id` = `prj`.`project_id`) and (`pt`.`active_time` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`pt`.`status_id` = 2)) group by `pt`.`project_id`) AS `count_money`,((((((ifnull((select count(1) from `stat_page_views` `pv` where ((`pv`.`project_id` = `prj`.`project_id`) and (`pv`.`created_at` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59'))) group by `pv`.`project_id`),0) * 0.05) + (ifnull((select count(1) from `plings` `p` where ((`p`.`project_id` = `prj`.`project_id`) and (`p`.`pling_time` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`p`.`status_id` in (2,3,4))) group by `p`.`project_id`),0) * 0.5)) + (ifnull((select count(1) from `project` `pu` where ((`pu`.`project_id` = `prj`.`project_id`) and (`pu`.`created_at` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`pu`.`type_id` = 2)) group by `pu`.`project_id`),0) * 0.2)) + (ifnull((select count(1) from `project_follower` `pf` where (`pf`.`project_id` = `prj`.`project_id`)),0) * 0.1)) + (ifnull((select format(sum(`pt`.`amount`),2) from `plings` `pt` where ((`pt`.`project_id` = `prj`.`project_id`) and (`pt`.`active_time` between date_format(now(),'%Y-%m-%d %H:00') and date_format(now(),'%Y-%m-%d %H:59')) and (`pt`.`status_id` = 2)) group by `pt`.`project_id`),0) * 0.2)) / 1.05) AS `ranking_value`,now() AS `created_at`,date_format(now(),'%Y') AS `year`,date_format(now(),'%m') AS `month`,date_format(now(),'%d') AS `day`,yearweek(now(),1) AS `year_week` from `project` `prj` where ((`prj`.`is_deleted` = 0) and (`prj`.`is_active` = 1) and (`prj`.`type_id` = 1)) group by `prj`.`project_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `stat_plings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `stat_plings` AS select `plings`.`project_id` AS `project_id`,sum(`plings`.`amount`) AS `amount_received`,count(1) AS `count_plings`,count(distinct `plings`.`member_id`) AS `count_plingers`,max(`plings`.`active_time`) AS `latest_pling` from `plings` where (`plings`.`status_id` = 2) group by `plings`.`project_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `stat_projects_v`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `stat_projects_v` AS select `project`.`project_id` AS `project_id`,`project`.`member_id` AS `member_id`,`project`.`content_type` AS `content_type`,`project`.`project_category_id` AS `project_category_id`,`project`.`hive_category_id` AS `hive_category_id`,`project`.`status` AS `status`,`project`.`uuid` AS `uuid`,`project`.`pid` AS `pid`,`project`.`type_id` AS `type_id`,`project`.`title` AS `title`,`project`.`description` AS `description`,`project`.`version` AS `version`,`project`.`image_big` AS `image_big`,`project`.`image_small` AS `image_small`,`project`.`start_date` AS `start_date`,`project`.`content_url` AS `content_url`,`project`.`created_at` AS `created_at`,`project`.`changed_at` AS `changed_at`,`project`.`deleted_at` AS `deleted_at`,`project`.`creator_id` AS `creator_id`,`project`.`facebook_code` AS `facebook_code`,`project`.`github_code` AS `github_code`,`project`.`twitter_code` AS `twitter_code`,`project`.`google_code` AS `google_code`,`project`.`link_1` AS `link_1`,`project`.`embed_code` AS `embed_code`,`project`.`ppload_collection_id` AS `ppload_collection_id`,`project`.`validated` AS `validated`,`project`.`validated_at` AS `validated_at`,`project`.`featured` AS `featured`,`project`.`approved` AS `approved`,`project`.`amount` AS `amount`,`project`.`amount_period` AS `amount_period`,`project`.`claimable` AS `claimable`,`project`.`claimed_by_member` AS `claimed_by_member`,`project`.`count_likes` AS `count_likes`,`project`.`count_dislikes` AS `count_dislikes`,`project`.`count_comments` AS `count_comments`,`project`.`count_downloads_hive` AS `count_downloads_hive`,`project`.`source_id` AS `source_id`,`project`.`source_pk` AS `source_pk`,`project`.`source_type` AS `source_type`,`project`.`validated` AS `project_validated`,`project`.`uuid` AS `project_uuid`,`project`.`status` AS `project_status`,`project`.`created_at` AS `project_created_at`,`member`.`type` AS `member_type`,`member`.`member_id` AS `project_member_id`,`project`.`changed_at` AS `project_changed_at`,`laplace_score`(`project`.`count_likes`,`project`.`count_dislikes`) AS `laplace_score`,`member`.`username` AS `username`,`member`.`profile_image_url` AS `profile_image_url`,`member`.`city` AS `city`,`member`.`country` AS `country`,`member`.`created_at` AS `member_created_at`,`member`.`paypal_mail` AS `paypal_mail`,`project_category`.`title` AS `cat_title`,`project_category`.`xdg_type` AS `cat_xdg_type`,`project_category`.`name_legacy` AS `cat_name_legacy`,`project_category`.`show_description` AS `cat_show_description`,`stat_plings`.`amount_received` AS `amount_received`,`stat_plings`.`count_plings` AS `count_plings`,`stat_plings`.`count_plingers` AS `count_plingers`,`stat_plings`.`latest_pling` AS `latest_pling`,`view_reported_projects`.`amount_reports` AS `amount_reports` from ((((`project` join `member` on((`member`.`member_id` = `project`.`member_id`))) join `project_category` on((`project`.`project_category_id` = `project_category`.`project_category_id`))) left join `stat_plings` on((`stat_plings`.`project_id` = `project`.`project_id`))) left join `view_reported_projects` on((`view_reported_projects`.`project_id` = `project`.`project_id`))) where ((`member`.`is_deleted` = 0) and (`member`.`is_active` = 1) and (`project`.`type_id` = 1) and (`project`.`status` = 100)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `stat_ratings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `stat_ratings` AS select `r`.`project_id` AS `project_id`,sum(`r`.`user_like`) AS `count_likes`,sum(`r`.`user_dislike`) AS `count_dislikes`,(round(((sum(`r`.`user_like`) + 6) / ((sum(`r`.`user_like`) + sum(`r`.`user_dislike`)) + 12)),2) * 100) AS `laplace_score` from `project_rating` `r` group by `r`.`project_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `stat_views`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=TEMPTABLE */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `stat_views` AS select `stat_page_views`.`project_id` AS `project_id`,count(1) AS `count_views`,count(distinct `stat_page_views`.`ip`) AS `count_visitor`,max(`stat_page_views`.`created_at`) AS `last_view` from `stat_page_views` group by `stat_page_views`.`project_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_reported_projects`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `view_reported_projects` AS select `reports_project`.`project_id` AS `project_id`,count(`reports_project`.`project_id`) AS `amount_reports`,max(`reports_project`.`created_at`) AS `latest_report` from `reports_project` where (`reports_project`.`is_deleted` <> 1) group by `reports_project`.`project_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
