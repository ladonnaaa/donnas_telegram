CREATE TABLE IF NOT EXISTS `donnas_telegrams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_citizenid` varchar(50) NOT NULL,
  `sender_name` varchar(100) NOT NULL,
  `receiver_citizenid` varchar(50) NOT NULL,
  `office_origin` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `status` varchar(20) DEFAULT 'Delivered',
  `sent_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `receiver_citizenid` (`receiver_citizenid`),
  KEY `sender_citizenid` (`sender_citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `donnas_telegram_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL COMMENT 'Contact Owner',
  `contact_name` varchar(100) NOT NULL,
  `contact_citizenid` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;