CREATE DATABASE IF NOT EXISTS `ocs` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

USE `ocs`;

CREATE TABLE IF NOT EXISTS `activity_log` (
  `activity_log_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL COMMENT 'Log action of this member',
  `project_id` int(11) DEFAULT NULL,
  `object_id` int(11) NOT NULL COMMENT 'Key to the action (add comment, pling, ...)',
  `object_ref` varchar(45) NOT NULL COMMENT 'Reference to the object table (plings, project, project_comment,...)',
  `object_title` varchar(90) DEFAULT NULL COMMENT 'Title to show',
  `object_text` varchar(150) DEFAULT NULL COMMENT 'Short text of this object (first 150 characters)',
  `object_img` varchar(255) DEFAULT NULL,
  `activity_type_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Wich ENGINE of activity: create, update,delete.',
  `time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`activity_log_id`),
  KEY `member_id` (`member_id`),
  KEY `project_id` (`project_id`),
  KEY `object_id` (`object_id`),
  KEY `activity_log_id` (`activity_log_id`,`member_id`,`project_id`,`object_id`),
  KEY `idx_time` (`member_id`,`time`)
) ENGINE=InnoDB COMMENT='Log all actions of a user. Wen can then generate a newsfeed ';

CREATE TABLE IF NOT EXISTS `activity_log_types` (
  `activity_log_type_id` int(11) NOT NULL,
  `type_text` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`activity_log_type_id`)
) ENGINE=InnoDB COMMENT='Type of activities';
TRUNCATE `activity_log_types`;
ALTER TABLE `activity_log_types` DISABLE KEYS ;
INSERT INTO `activity_log_types` VALUES (0,'ProjectCreated'),(1,'ProjectUpdated'),(2,'ProjectDeleted'),(3,'ProjectStopped'),(4,'ProjectRestarted'),(7,'ProjectEdited'),(8,'ProjectPublished'),(9,'ProjectUnpublished'),(10,'ProjectItemCreated'),(11,'ProjectItemUpdated'),(12,'ProjectItemDeleted'),(13,'ProjectItemStopped'),(14,'ProjectItemRestarted'),(17,'ProjectItemEdited'),(18,'ProjectItemPublished'),(19,'ProjectItemUnpublished'),(20,'ProjectPlinged'),(21,'ProjectDisplinged'),(30,'ProjectItemPlinged'),(31,'ProjectItemDisplinged'),(40,'ProjectCommentCreated'),(41,'ProjectCommentUpdated'),(42,'ProjectCommentDeleted'),(43,'ProjectCommentReply'),(50,'ProjectFollowed'),(51,'ProjectUnfollowed'),(52,'ProjectShared'),(60,'ProjectRatedHigher'),(61,'ProjectRatedLower'),(100,'MemberJoined'),(101,'MemberUpdated'),(102,'MemberDeleted'),(107,'MemberEdited'),(150,'MemberFollowed'),(151,'MemberUnfollowed'),(152,'MemberShared'),(200,'ProjectFilesCreated'),(210,'ProjectFilesUpdated'),(220,'ProjectFilesDeleted'),(302,'BackendLogin'),(304,'BackendLogout'),(310,'BackendProjectDelete'),(312,'BackendProjectFeature'),(314,'BackendProjectApproved'),(316,'BackendProjectCatChanged'),(318,'BackendProjectPlingExcluded'),(320,'BackendUserDeleted');
ALTER TABLE `activity_log_types` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `comment_types` (
  `comment_type_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  KEY `pk` (`comment_type_id`)
) ENGINE=InnoDB;
TRUNCATE `comment_types`;
ALTER TABLE `comment_types` DISABLE KEYS ;
INSERT INTO `comment_types` VALUES (0,'project');
ALTER TABLE `comment_types` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `comments` (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `config_store` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `config_store_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER `config_store_BEFORE_INSERT` BEFORE INSERT ON `config_store` FOR EACH ROW BEGIN

  IF NEW.created_at IS NULL THEN

    SET NEW.created_at = NOW();

  END IF;

END ;;
DELIMITER ;
TRUNCATE `config_store`;
ALTER TABLE `config_store` DISABLE KEYS ;
INSERT INTO `config_store` VALUES (1,'localhost','localhost-develop','default',NULL,1,1,0,'',NULL,1,'2016-05-23 05:57:08',NULL,NULL);
ALTER TABLE `config_store` ENABLE KEYS ;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

CREATE TABLE IF NOT EXISTS `config_store_category` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `config_store_category_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER `config_store_category_BEFORE_INSERT` BEFORE INSERT ON `config_store_category` FOR EACH ROW BEGIN

  IF NEW.created_at IS NULL THEN

    SET NEW.created_at = NOW();

  END IF;

END ;;
DELIMITER ;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;

CREATE TABLE IF NOT EXISTS `mail_template` (
  `mail_template_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `subject` varchar(250) NOT NULL,
  `text` text NOT NULL,
  `created_at` datetime NOT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`mail_template_id`),
  UNIQUE KEY `unique_name` (`name`)
) ENGINE=InnoDB;
TRUNCATE `mail_template`;
ALTER TABLE `mail_template` DISABLE KEYS ;
INSERT INTO `mail_template` VALUES (5,'tpl_verify_user','%servername%: Please verify your email address','<h2>Hey %username%,</h2>\r\n<p><br />Thank you for signing up to %servername%.</p>\r\n<p><br />Please click the button below to verify this email address:</p>\r\n<div><!-- [if mso]>\r\n    <v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:w=\"urn:schemas-microsoft-com:office:word\"\r\n                 href=\"%verificationurl%\" style=\"height:40px;v-text-anchor:middle;width:300px;\" arcsize=\"10%\"\r\n                 stroke=\"f\" fillcolor=\"#34495C\">\r\n        <w:anchorlock/>\r\n        <center style=\"color:#ffffff;font-family:sans-serif;font-size:16px;font-weight:bold;\">\r\n            Verify your e-mail address\r\n        </center>\r\n    </v:roundrect>\r\n    <![endif]--> <!-- [if !mso]> <!-->\r\n<table cellspacing=\"0\" cellpadding=\"0\">\r\n<tbody>\r\n<tr>\r\n<td style=\"-webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; color: #ffffff; display: block;\" align=\"center\" bgcolor=\"#34495C\" width=\"300\" height=\"40\"><a style=\"color: #ffffff; font-size: 16px; font-weight: bold; font-family: sans-serif; text-decoration: none; line-height: 40px; width: 100%; display: inline-block;\" href=\"%verificationurl%\"> Verify your e-mail address </a></td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n<!-- <![endif]--></div>\r\n<p><br />If the button doesn&rsquo;t work, you can copy and paste the following link to your browser:<br /><br />%verificationlink%&nbsp;</p>\r\n<p><br />If you have any problems, feel free to contact us at any time!</p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2011-11-07 10:28:43','2015-12-09 16:27:02',NULL),(7,'tpl_social_mail','<%sender%> sent you a recommendation','<p>&lt;%sender%&gt; has suggested that you could be interested in this member</p>\r\n<h2>%username%.</h2>\r\n<p>%permalinktext%</p>\r\n<p><br />If the link doesn&rsquo;t work, you can copy and paste the following link to your browser:</p>\r\n<h4>%permalink%</h4>\r\n<p><br />Kind regards,<br />\r\n    Team Pling</p>','2011-11-07 10:36:48','2013-11-08 11:51:44',NULL),(8,'tpl_user_message','opendesktop.org - Du hast eine Nachricht erhalten','Hallo %username%,<br/><br/>%sender% hat dir eine Nachricht geschickt.<br/><br/><div style=\'width: 500px; background-color: #F2F2F2; border: 1px solid #C1C1C1; padding: 10px;\'>%message_text%</div>','2011-11-07 10:40:06','2011-11-28 16:18:48',NULL),(9,'tpl_newuser_notification','opendesktop.org - Neue Memberanmeldung','Jemand hat sich angemeldet: <strong>%username%</strong> angemeldet.<br/><br/><br/>Grüße das pling-System :)','2011-11-28 15:50:59',NULL,NULL),(10,'tpl_user_newpass','opendesktop.org - your new password','<p>Hello %username%,<br /><br />We created this new password for your opendesktop.org account: <b>%newpass%</b><br /><br /><p><br />If you have any problems, feel free to contact us at any time!</p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2011-11-28 15:55:38','2015-12-09 16:26:10',NULL),(11,'tpl_newproject_notification','opendesktop.org - Neue Projektanmeldung','Ein neues Projekt wurde von <strong>%username%</strong> angemeldet.<br/>Mehr dazu im Backend hier: http://opendesktop.org/backend/project/apply<br/>Grüße das opendesktop.org-System :)','2011-11-28 16:41:00',NULL,NULL),(12,'tpl_verify_button_user','%servername%: Please verify your email address','<h2>Hey %username%,</h2>\r\n<p><br />thank you for signing up to opendesktop.org</p>\r\n<p>We have generated a new password for you. We recommend you to change this password as soon as possible in your settings.<br /><br />Your password: %password%</p>\r\n<p><br />Before you&nbsp;can use your button and&nbsp;receive loads of plings or love and pling other products, please klick the link below&nbsp;to verify your email address.</p>\r\n<p><br />If the link doesn&rsquo;t work, you can copy and paste the following link to your browser:<br /><br />%verificationlinktext%&nbsp;</p>\r\n<p><br />In case the problem still occurs, feel free to contact us at any time!</p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2014-04-24 08:40:27','2015-12-09 17:29:18',NULL),(13,'tpl_social_mail_product','<%sender%> sent you a recommendation','<p>&lt;%sender%&gt; has suggested that you could be interested in this product</p>\r\n<h2>%title%</h2>\r\n<p>from our opendesktop.org member <em>%username%</em>.\r\n</p>\r\n<p>%permalinktext%</p>\r\n<p><br />If the link doesn&rsquo;t work, you can copy and paste the following link to your browser:</p>\r\n<h4>%permalinktext%</h4>\r\n<p><br />Kind regards,<br />\r\n    Team opendesktop.org</p>','2013-11-08 10:46:42','2013-11-08 11:52:04',NULL),(14,'tpl_mail_claim_product','User wants to claim a product','<p>The opendesktop.org-system received a request from a user</p>\r <p>%userid% :: %username% :: %usermail%</p>\r <p>who wants to claim the following product:</p>\r <p>%productid% :: %producttitle%&nbsp;</p>\r <p>&nbsp;</p>\r <p>Greetings from the opendesktop.org-system</p>','2014-05-14 10:15:22','2014-05-14 10:43:21',NULL),(15,'tpl_mail_claim_confirm','opendesktop.org: We received your inquiry','<h2>Hello %username%,</h2>\r\n<p>you want to claim the following product:</p>\r\n<p><a href=\"%productlink%\">%producttitle%</a></p>\r\n<p>We try to process your request as quickly as possible.<br />You will receive a notice shortly if your claim has been approved.</p>\r\n<p><br /><br />Kind regards,<br />Team opendesktop.org&nbsp;<br /><a href=\"mailto:contact@opendesktop.org\">contact@opendesktop.org</a></p>','2014-05-14 10:39:59','2015-12-09 17:29:52',NULL),(16,'tpl_user_comment_note','opendesktop.org - You Received A New Comment','<h2>Hey %username%,</h2>\r\n<p><br />you received a new comment on <b>%product_title%</b></p>\r\n<p><br />Here is what the user wrote:</p>\r\n<div><br />%comment_text%</div>\r\n<p><br /><br />Please do not reply to the email, but use the comment system for this product instead:<br />\r\n<a href=\"https://www.opendesktop.org/p/%product_id%\">%product_title%</a></p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2016-09-15 08:16:00','2016-09-15 08:31:07',NULL),(17,'tpl_verify_email','%servername% - Please verify your email address','<h2>Hey %username%,</h2>\r\n<p>\r\n  Help us secure your account by verifying your email address\r\n  (<a href=\"mailto:%email_address%\">%email_address%</a>).\r\n    This will let you receive notifications and password resets from our system.\r\n</p>\r\n<div><!-- [if mso]>\r\n    <v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:w=\"urn:schemas-microsoft-com:office:word\"\r\n                 href=\"%verificationurl%\" style=\"height:40px;v-text-anchor:middle;width:300px;\" arcsize=\"10%\"\r\n                 stroke=\"f\" fillcolor=\"#34495C\">\r\n        <w:anchorlock/>\r\n        <center style=\"color:#ffffff;font-family:sans-serif;font-size:16px;font-weight:bold;\">\r\n            Verify your e-mail address here\r\n        </center>\r\n    </v:roundrect>\r\n    <![endif]--> <!-- [if !mso]> <!-->\r\n<table cellspacing=\"0\" cellpadding=\"0\">\r\n<tbody>\r\n<tr>\r\n<td style=\"-webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; color: #ffffff; display: block;\" align=\"center\" bgcolor=\"#34495C\" width=\"300\" height=\"40\"><a style=\"color: #ffffff; font-size: 16px; font-weight: bold; font-family: sans-serif; text-decoration: none; line-height: 40px; width: 100%; display: inline-block;\" href=\"%verificationurl%\"> Verify your e-mail address </a></td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n<!-- <![endif]--></div>\r\n<p><br />If the button doesn&rsquo;t work, you can copy and paste the following link to your browser:<br /><br />%verificationlink%&nbsp;</p>\r\n<p><br />If you have any problems, feel free to contact us at any time!</p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2016-09-23 07:16:31','2016-09-23 07:16:31',NULL),(18,'tpl_user_comment_reply_note','opendesktop.org - You received a new reply to your comment','<h2>Hey %username%,</h2>\r\n<p><br />you received a new reply to your comment on <b>%product_title%</b></p>\r\n<p><br />Here is what the user wrote:</p>\r\n<div><br />%comment_text%</div>\r\n<p><br /><br />Please do not reply to the email, but use the comment system for this product instead:<br />\r\n<a href=\"https://www.opendesktop.org/p/%product_id%\">%product_title%</a></p>\r\n<p><br /><br />Kind regards,<br />Your openDesktop Team <br /><a href=\"mailto:contact@opendesktop.org\" target=\"_blank\">contact@opendesktop.org</a><br /><br /></p>','2016-10-07 10:49:15','2016-10-07 10:49:15',NULL);
ALTER TABLE `mail_template` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `member` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `member_created`;;
CREATE DEFINER=CURRENT_USER TRIGGER `member_created` BEFORE INSERT ON `member` FOR EACH ROW BEGIN

  IF NEW.created_at IS NULL THEN

    SET NEW.created_at = NOW();

  END IF;

END ;;
DROP TRIGGER IF EXISTS `member_BEFORE_UPDATE`;;
CREATE DEFINER=CURRENT_USER TRIGGER `member_BEFORE_UPDATE` BEFORE UPDATE ON `member` FOR EACH ROW
  BEGIN
    SET NEW.changed_at = NOW();
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `member_email` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `member_email_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER member_email_BEFORE_INSERT BEFORE INSERT ON member_email FOR EACH ROW

  BEGIN
    IF NEW.email_created IS NULL THEN
      SET NEW.email_created = NOW();
    END IF;

  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `member_dl_plings` (
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
  KEY `idx_yearmonth` (`yearmonth`)
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `member_dl_plings_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER member_dl_plings_BEFORE_INSERT BEFORE INSERT ON member_dl_plings FOR EACH ROW

  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `member_follower` (
  `member_follower_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `follower_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`member_follower_id`),
  KEY `follower_id` (`follower_id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `member_group` (
  `member_group_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT '1' COMMENT 'Role of the rgoup-member. 1 = User, 2 = admin. See table member_group_role.',
  `is_active` int(11) NOT NULL DEFAULT '0' COMMENT 'Group-Member active?',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`member_group_id`)
) ENGINE=InnoDB COMMENT='Connection between members ans groups. ';

CREATE TABLE IF NOT EXISTS `member_group_role` (
  `member_group_role_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` varchar(45) DEFAULT NULL,
  `short_text` varchar(45) DEFAULT NULL,
  `is_active` int(11) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`member_group_role_id`)
) ENGINE=InnoDB;
TRUNCATE `member_group_role`;
INSERT INTO `member_group_role` VALUES (1,'user','normal user',1,'2012-11-13 15:54:27',NULL),(2,'admin','super admin',1,'2012-11-13 15:54:27',NULL);

CREATE TABLE IF NOT EXISTS `member_payout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `yearmonth` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `mail` varchar(50) DEFAULT NULL,
  `paypal_mail` varchar(50) DEFAULT NULL,
  `num_downloads` int(11) DEFAULT NULL,
  `num_points` int(11) DEFAULT NULL,
  `amount` double DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '0=new,1=start request,10=processed,100=completed,999=error',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `timestamp_masspay_start` timestamp NULL DEFAULT NULL,
  `timestamp_masspay_last_ipn` timestamp NULL DEFAULT NULL,
  `last_paypal_ipn` text,
  `last_paypal_status` text,
  `payment_reference_key` varchar(255) DEFAULT NULL COMMENT 'uniquely identifies the request',
  `payment_transaction_id` varchar(255) DEFAULT NULL COMMENT 'uniquely identify caller (developer, facilliator, marketplace) transaction',
  `payment_raw_message` varchar(2000) DEFAULT NULL COMMENT 'the raw text message ',
  `payment_raw_error` varchar(2000) DEFAULT NULL,
  `payment_status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_PAYOUT` (`yearmonth`,`member_id`)
) ENGINE=InnoDB COMMENT='Table for our monthly payouts';
DELIMITER ;;
DROP TRIGGER IF EXISTS `member_payout_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER member_payout_BEFORE_INSERT BEFORE INSERT ON member_payout FOR EACH ROW

  BEGIN
   IF NEW.created_at IS NULL THEN
     SET NEW.created_at = NOW();
   END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `member_paypal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) DEFAULT NULL,
  `paypal_address` varchar(150) DEFAULT NULL,
  `is_active` int(1) unsigned DEFAULT '1',
  `name` varchar(150) DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL,
  `currency` varchar(150) DEFAULT NULL,
  `country_code` varchar(150) DEFAULT NULL,
  `last_payment_status` varchar(150) DEFAULT NULL,
  `last_payment_amount` double DEFAULT NULL,
  `last_transaction_id` varchar(50) DEFAULT NULL,
  `last_transaction_event_code` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_paypal_address` (`paypal_address`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `member_role` (
  `member_role_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `shortname` varchar(50) NOT NULL,
  `is_active` int(1) NOT NULL DEFAULT '0',
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`member_role_id`)
) ENGINE=InnoDB;
TRUNCATE `member_role`;
ALTER TABLE `member_role` DISABLE KEYS;
INSERT INTO `member_role` VALUES (100,'Administrator','admin',1,0,NULL,NULL,NULL),(200,'Mitarbeiter','staff',1,0,NULL,NULL,NULL),(300,'FrontendBenutzer','feuser',1,0,NULL,NULL,NULL);
ALTER TABLE `member_role` ENABLE KEYS;

CREATE TABLE IF NOT EXISTS `member_token` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `member_token_before_insert`;;
CREATE DEFINER=CURRENT_USER TRIGGER `member_token_before_insert` BEFORE INSERT ON `member_token` FOR EACH ROW BEGIN

  IF NEW.token_created IS NULL THEN
    SET NEW.token_created = NOW();
  END IF;

END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `payout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `yearmonth` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `timestamp_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `timestamp_success` timestamp NULL DEFAULT NULL,
  `paypal_ipn` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_PAYOUT` (`yearmonth`,`member_id`)
) ENGINE=InnoDB COMMENT='Table for our monthly payouts';

CREATE TABLE IF NOT EXISTS `payout_status` (
  `id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'info',
  `title` varchar(50) DEFAULT NULL,
  `description` text,
  `color` varchar(50) DEFAULT NULL,
  `icon` varchar(50) DEFAULT 'glyphicon-info-sign',
  `is_active` int(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
TRUNCATE `payout_status`;
ALTER TABLE `payout_status` DISABLE KEYS ;
INSERT INTO `payout_status` VALUES (1,'info','Status: Requested','We send your payout. The actual status is: Requested.','#31708f;','glyphicon-info-sign',0),(10,'info','Status: Processed','We send your payout. The actual status is: Processed.','#31708f;','glyphicon-info-sign',0),(50,'info','Status: Pending','We send your payout. The actual status is: Pending.','#31708f;','glyphicon-info-sign',1),(99,'info','Status: Refund','We tried to payout your plings, but your payment was refund.','#112c8b;','glyphicon-info-sign',0),(100,'success','Status: Completed','For this month we has successfully paid you.','#3c763d;','glyphicon-ok-sign',1),(900,'info','Status: Refunded','We send you the payment, but you refunded it. ','#0f2573','glyphicon-exclamation-sign',1),(901,'info','Status: Refunded by Paypal','Your Mailadress is not signed up for a PayPal account or you did not complete the registration process.','#112c8b','glyphicon-info-sign',1),(910,'warning','Status: Not allowed','PayPal denies our payment because you only can receive website payments. Please change your settings on PayPal.','#bd8614','glyphicon-exclamation-sign',1),(920,'warning','Status: Personal Payments','We tried to send you money, but the PayPal message was: Sorry, this recipient can’t accept personal payments.','#bd8614','glyphicon-exclamation-sign',1),(930,'danger','Status: currently unable','We tried to send you money, but Paypal denied this with the following message: This recipient is currently unable to receive money.','#a94442;','glyphicon-exclamation-sign',1),(940,'danger','Status: Denied','We tried to send you money, but Paypal denied this with the following message: We can’t send your payment right now. If you keep running into this issue, please contact.','#a94442;','glyphicon-exclamation-sign',1),(950,'danger','Status: Failed','Our Payment failed','#a94442;','glyphicon-exclamation-sign',1),(999,'danger','API Error','We tried to send the money automatically via the Paypal-API, but we temporarily got an error.  We will try the payout again, so please stay tuned.','#f71f1f','glyphicon-info-sign',1);
ALTER TABLE `payout_status` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `paypal_ipn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `txn_type` varchar(50) DEFAULT NULL,
  `ipn_track_id` varchar(50) DEFAULT NULL,
  `txn_id` varchar(50) DEFAULT NULL,
  `payer_email` varchar(50) DEFAULT NULL,
  `payer_id` varchar(50) DEFAULT NULL,
  `auth_amount` varchar(50) DEFAULT NULL,
  `mc_currency` varchar(50) DEFAULT NULL,
  `mc_fee` varchar(50) DEFAULT NULL,
  `mc_gross` varchar(50) DEFAULT NULL,
  `memo` varchar(50) DEFAULT NULL,
  `payer_status` varchar(50) DEFAULT NULL,
  `payment_date` varchar(50) DEFAULT NULL,
  `payment_fee` varchar(50) DEFAULT NULL,
  `payment_status` varchar(50) DEFAULT NULL,
  `payment_type` varchar(50) DEFAULT NULL,
  `pending_reason` varchar(50) DEFAULT NULL,
  `reason_code` varchar(50) DEFAULT NULL,
  `custom` varchar(50) DEFAULT NULL,
  `raw` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='Save all PayPal IPNs here';

CREATE TABLE IF NOT EXISTS `paypal_valid_status` (
  `id` int(11) NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  `description` text,
  `color` varchar(50) DEFAULT NULL,
  `is_active` int(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `plings` (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `project` (
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
  `pling_excluded` int(1) NOT NULL DEFAULT '0' COMMENT 'Project was excluded from pling payout',
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
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE IF NOT EXISTS `project_category` (
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
) ENGINE=InnoDB;
ALTER TABLE `project_category` DISABLE KEYS ;
TRUNCATE `project_category`;
INSERT INTO `project_category` VALUES (1,0,1,'root',1,0,NULL,NULL,0,1,0,'2015-01-14 13:06:56','2017-10-25 03:23:11',NULL);
ALTER TABLE `project_category` ENABLE KEYS ;
DELIMITER ;;
DROP TRIGGER IF EXISTS `project_category_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER `project_category_BEFORE_INSERT` BEFORE INSERT ON `project_category` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END ;;
DROP TRIGGER IF EXISTS `project_category_BEFORE_UPDATE`;;
CREATE DEFINER=CURRENT_USER TRIGGER `project_category_BEFORE_UPDATE` BEFORE UPDATE ON `project_category` FOR EACH ROW
  BEGIN
    SET NEW.changed_at = NOW();
  END ;;
DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE IF NOT EXISTS `project_gallery_picture` (
  `project_id` int(11) NOT NULL,
  `sequence` int(11) NOT NULL,
  `picture_src` varchar(255) NOT NULL,
  PRIMARY KEY (`project_id`,`sequence`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `project_package_type` (
  `project_id` int(11) NOT NULL,
  `file_id` int(11) NOT NULL,
  `package_type_id` int(11) NOT NULL,
  PRIMARY KEY (`project_id`,`file_id`),
  KEY `idx_type_id` (`package_type_id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `project_rating` (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `project_updates` (
  `project_update_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL DEFAULT '0',
  `member_id` int(11) NOT NULL DEFAULT '0',
  `public` int(1) NOT NULL DEFAULT '0',
  `title` varchar(200) DEFAULT NULL,
  `text` text,
  `created_at` datetime DEFAULT NULL,
  `changed_at` datetime DEFAULT NULL,
  `source_id` int(11) DEFAULT '0',
  `source_pk` int(11) DEFAULT NULL,
  PRIMARY KEY (`project_update_id`)
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS `project_widget` (
  `widget_id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `config` text,
  PRIMARY KEY (`widget_id`),
  KEY `idxPROJECT` (`project_id`),
  KEY `idxUUID` (`uuid`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `project_widget_default` (
  `widget_id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `config` text,
  PRIMARY KEY (`widget_id`),
  KEY `idxPROJECT` (`project_id`),
  KEY `idxUuid` (`uuid`)
) ENGINE=InnoDB;
TRUNCATE `project_widget_default`;
ALTER TABLE `project_widget_default` DISABLE KEYS;
INSERT INTO `project_widget_default` VALUES (1,'95b1a84890153c9852c4019778c27639',659,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"Churches\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(2,'c5079dc902feb85c9570f4afda705079',683,'{\"text\":{\"content\":\"HELP!!!\",\"headline\":\"Ronald\'s Music\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"10\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2e3e5e\",\"widgetContent\":\"#ff0000\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"orange\"}'),(3,'e33d4e2932c29031a17d9a0587f72ab0',200,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"Netrunner Enigma 2 (13.12) - 32bit RC\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"23\",\"goal\":\"50\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(4,'5cb3b4e7998d9ceef02622f648fa367a',42,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"wums plattform\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"21.75\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(5,'d2bace2e8c3dea33ba776f5c5a20d313',83,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"Makkes2\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0.75\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(6,'5215736d456c2cafe71c61712f8e8b0e',204,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"Video2\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(7,'4e557eb9f8fb030ec83f8404b21a7d63',727,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!\",\"headline\":\"wert\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"5\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(8,'b4b1ee0a037b90016a738781469cfa3a',703,'{\"text\":{\"content\":\"Discover more about my product on Pling.it.\",\"headline\":\"Wallpaper Test\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(9,'2e5aef93a4a6acdffafde1aa2f4b765e',723,'{\"text\":{\"content\":\"Discover more about my product on Pling.it.\",\"headline\":\"heinzi\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"2000\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"icon\"}'),(10,'b6f2f8683a8d90f55f7498922de307ea',745,'{\"text\":{\"content\":\"Discover more about my product on Pling.it.\",\"headline\":\"sebas product\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"10000\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"icon\"}'),(11,'8cff689cb9a96005c07127afa42d5359',1099990,'{\"text\":{\"content\":\"I\'m currently raising money through Pling it. Click the Pling it button to help!dsafds\",\"headline\":\"dsafdsafds\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#b0264f\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#785555\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(12,'0fbfdb7be17403e774a01a44bd12ab94',1176780,'{\"text\":{\"content\":\"I\'m currently raising money through opendesktop.org . Click the donate button to help!\",\"headline\":\"sheep\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}'),(13,'4cdb50c0d931251e08dc920da2af93fe',1170226,'{\"text\":{\"content\":\"I\'m currently raising money through opendesktop.org . Click the donate button to help!\",\"headline\":\"KAtomic Snap\",\"button\":\"Pling it!\"},\"amounts\":{\"donation\":\"10\",\"showDonationAmount\":true,\"current\":\"0\",\"goal\":\"\"},\"colors\":{\"widgetBg\":\"#2673B0\",\"widgetContent\":\"#ffffff\",\"headline\":\"#ffffff\",\"text\":\"#000000\",\"button\":\"#428bca\",\"buttonText\":\"#ffffff\"},\"showSupporters\":true,\"showComments\":true,\"logo\":\"grey\"}');
ALTER TABLE `project_widget_default` ENABLE KEYS;

SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE IF NOT EXISTS `queue` (
  `queue_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(100) NOT NULL,
  `timeout` smallint(5) unsigned NOT NULL DEFAULT '30',
  PRIMARY KEY (`queue_id`)
) ENGINE=InnoDB;
ALTER TABLE `queue` DISABLE KEYS;
TRUNCATE `queue`;
INSERT INTO `queue` VALUES (1,'website_validate',30),(2,'search',30),(3,'ocs_jobs',30);
ALTER TABLE `queue` ENABLE KEYS;

CREATE TABLE IF NOT EXISTS `queue_message` (
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
) ENGINE=InnoDB;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE IF NOT EXISTS `reports_comment` (
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
) ENGINE=InnoDB;

DELIMITER ;;
DROP TRIGGER IF EXISTS `report_comment_created`;;
CREATE DEFINER=CURRENT_USER TRIGGER `report_comment_created` BEFORE INSERT ON `reports_comment` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `reports_member` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `is_deleted` int(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idxMemberId` (`member_id`),
  KEY `idxReportedBy` (`reported_by`)
) ENGINE=InnoDB;

DELIMITER ;;
DROP TRIGGER IF EXISTS `reports_member_created`;;
CREATE DEFINER=CURRENT_USER TRIGGER `reports_member_created` BEFORE INSERT ON `reports_member` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `reports_project` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `reported_by` int(11) NOT NULL,
  `is_deleted` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idxReport` (`project_id`,`reported_by`,`is_deleted`,`created_at`)
) ENGINE=InnoDB;

DELIMITER ;;
DROP TRIGGER IF EXISTS `report_project_created`;;
CREATE DEFINER=CURRENT_USER TRIGGER `report_project_created` BEFORE INSERT ON `reports_project` FOR EACH ROW
  BEGIN
    IF NEW.created_at IS NULL THEN
      SET NEW.created_at = NOW();
    END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `session` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `remember_me_id` varchar(255) NOT NULL,
  `expiry` datetime NOT NULL,
  `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `idx_remember` (`member_id`,`remember_me_id`,`expiry`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `support` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL COMMENT 'Supporter',
  `status_id` int(11) DEFAULT '0' COMMENT 'Stati der donation: 0 = inactive, 1 = active (donated), 2 = payed successfull, 99 = deleted',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation-time',
  `donation_time` timestamp NULL DEFAULT NULL COMMENT 'When was a project plinged?',
  `active_time` timestamp NULL DEFAULT NULL COMMENT 'When did paypal say, that this donation was payed successfull',
  `delete_time` timestamp NULL DEFAULT NULL,
  `amount` double(10,2) DEFAULT '0.00' COMMENT 'Amount of money',
  `comment` varchar(140) DEFAULT NULL COMMENT 'Comment from the supporter',
  `payment_provider` varchar(45) DEFAULT NULL,
  `payment_reference_key` varchar(255) DEFAULT NULL COMMENT 'uniquely identifies the request',
  `payment_transaction_id` varchar(255) DEFAULT NULL COMMENT 'uniquely identify caller (developer, facilliator, marketplace) transaction',
  `payment_raw_message` varchar(2000) DEFAULT NULL COMMENT 'the raw text message ',
  `payment_raw_error` varchar(2000) DEFAULT NULL,
  `payment_status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status_id` (`status_id`),
  KEY `member_id` (`member_id`),
  KEY `DONATION_IX_01` (`status_id`,`member_id`,`active_time`,`amount`)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE IF NOT EXISTS `tag` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(45) NOT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `idx_name` (`tag_name`)
) ENGINE=InnoDB;
ALTER TABLE `tag` DISABLE KEYS ;
TRUNCATE `tag`;
INSERT INTO `tag` VALUES (13,''),(1,'1024x768'),(3,'1600x900'),(2,'800x600'),(9,'abstract'),(7,'background'),(8,'building'),(12,'Debian'),(6,'flowers'),(5,'gnome'),(4,'kde'),(10,'Linux'),(11,'Windows');
ALTER TABLE `tag` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `tag_group` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(45) NOT NULL,
  PRIMARY KEY (`group_id`)
) ENGINE=InnoDB;
ALTER TABLE `tag_group` DISABLE KEYS;
TRUNCATE `tag_group`;
INSERT INTO `tag_group` VALUES (1,'resolution'),(2,'badge'),(3,'usertag'),(4,'OS');
ALTER TABLE `tag_group` ENABLE KEYS ;

CREATE TABLE IF NOT EXISTS `tag_group_item` (
  `tag_group_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_group_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_group_item_id`),
  KEY `tag_group_idx` (`tag_group_id`),
  KEY `tag_idx` (`tag_id`),
  CONSTRAINT `tag` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`tag_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `tag_group` FOREIGN KEY (`tag_group_id`) REFERENCES `tag_group` (`group_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB;
ALTER TABLE `tag_group_item` DISABLE KEYS ;
TRUNCATE `tag_group_item`;
INSERT INTO `tag_group_item` VALUES (1,1,1),(2,1,2),(3,1,3),(4,2,4),(5,2,5),(6,3,6),(7,3,7),(8,3,8),(9,3,9),(10,4,10),(11,4,11),(12,4,12);
ALTER TABLE `tag_group_item` ENABLE KEYS ;

SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE IF NOT EXISTS `tag_object` (
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
) ENGINE=InnoDB;
DELIMITER ;;
DROP TRIGGER IF EXISTS `tag_object_BEFORE_INSERT`;;
CREATE DEFINER=CURRENT_USER TRIGGER `tag_object_BEFORE_INSERT` BEFORE INSERT ON `tag_object` FOR EACH ROW
  BEGIN
    IF NEW.tag_changed IS NULL THEN
      SET NEW.tag_changed = NOW();
    END IF;
  END ;;
DELIMITER ;

CREATE TABLE IF NOT EXISTS `tag_type` (
  `tag_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_type_name` varchar(45) NOT NULL,
  PRIMARY KEY (`tag_type_id`)
) ENGINE=InnoDB;
ALTER TABLE `tag_type` DISABLE KEYS ;
TRUNCATE `tag_type`;
INSERT INTO `tag_type` VALUES (1,'project'),(2,'member'),(3,'file'),(4,'download'),(5,'image'),(6,'video'),(7,'comment'),(8,'activity');
ALTER TABLE `tag_type` ENABLE KEYS ;

DELIMITER $$
DROP FUNCTION IF EXISTS `laplace_score`$$
CREATE DEFINER=CURRENT_USER FUNCTION `laplace_score`(upvotes INT, downvotes INT) RETURNS int(11)
DETERMINISTIC
  BEGIN
    DECLARE score INT(10);
    SET score = (round(((upvotes + 6) / ((upvotes + downvotes) + 12)),2) * 100);
    RETURN score;
  END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `generate_stat_views_today`$$
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
          COUNT(*)                               AS count_views,
          COUNT(DISTINCT `stat_page_views`.`ip`) AS `count_visitor`,
          MAX(`stat_page_views`.`created_at`)    AS `last_view`
        FROM stat_page_views
        WHERE (stat_page_views.`created_at`
        BETWEEN DATE_FORMAT(NOW(), '%Y-%m-%d 00:00') AND DATE_FORMAT(NOW(), '%Y-%m-%d 23:59')
        )
        GROUP BY project_id;

    IF EXISTS(SELECT table_name
              FROM INFORMATION_SCHEMA.TABLES
              WHERE table_schema = DATABASE()
                    AND table_name = 'stat_page_views_today_mv')

    THEN

      ALTER TABLE `stat_page_views_today_mv`
      RENAME TO `old_stat_views_today_mv`;

    END IF;

    ALTER TABLE `temp_stat_views_today`
    RENAME TO `stat_page_views_today_mv`;

    DROP TABLE IF EXISTS `old_stat_views_today_mv`;

  END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `generate_stat_project`$$
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
          `tppt`.`package_type_id_list` as `package_types`,
          `tppt`.`package_name_list` as `package_names`,
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
  END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `generate_stat_cat_tree`$$
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

    IF EXISTS(SELECT table_name
              FROM INFORMATION_SCHEMA.TABLES
              WHERE table_schema = DATABASE()
                    AND table_name = 'stat_cat_tree')

    THEN

      RENAME TABLE stat_cat_tree TO old_stat_cat_tree, tmp_stat_cat_tree TO stat_cat_tree;

    ELSE

      RENAME TABLE tmp_stat_cat_tree TO stat_cat_tree;

    END IF;


    DROP TABLE IF EXISTS old_stat_cat_tree;

  END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `generate_stat_cat_prod_count`$$
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
          LEFT JOIN stat_projects as p ON p.project_category_id = sct1.project_category_id AND p.amount_reports is null
        GROUP BY sct2.project_category_id

        UNION

        SELECT
          sct2.project_category_id,
          ppt.package_type_id,
          count(distinct p.project_id) as count_product
        FROM stat_cat_tree as sct1
          JOIN stat_cat_tree as sct2 ON sct1.lft between sct2.lft AND sct2.rgt
          JOIN stat_projects as p ON p.project_category_id = sct1.project_category_id AND p.amount_reports is null
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

  END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `create_stat_ranking_categroy`$$
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

  END$$
DELIMITER ;
