PRAGMA foreign_keys=ON;

BEGIN TRANSACTION;

PRAGMA defer_foreign_keys=ON;

CREATE TABLE "portal_quest" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(120) NOT NULL UNIQUE, "summary" varchar(300) NOT NULL, "active" bool NOT NULL);

CREATE TABLE "portal_member" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "login" varchar(64) NOT NULL UNIQUE, "password" varchar(128) NOT NULL, "full_name" varchar(150) NOT NULL, "phone" varchar(16) NOT NULL, "email" varchar(254) NOT NULL, "is_admin" bool NOT NULL);

CREATE TABLE "portal_review" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "body" varchar(600) NOT NULL, "created_at" datetime NOT NULL, "submission_id" bigint NOT NULL UNIQUE REFERENCES "portal_submission" ("id") DEFERRABLE INITIALLY DEFERRED);

CREATE TABLE "portal_slot" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "day" date NOT NULL, "time" time NOT NULL, "quest_id" bigint NOT NULL REFERENCES "portal_quest" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "unique_quest_time" UNIQUE ("quest_id", "day", "time"));

CREATE TABLE "portal_variation" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(80) NOT NULL, "active" bool NOT NULL, "quest_id" bigint NOT NULL REFERENCES "portal_quest" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "unique_variation_name" UNIQUE ("quest_id", "name"));

CREATE TABLE "portal_submission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "status" varchar(16) NOT NULL, "created_at" datetime NOT NULL, "participants" integer unsigned NOT NULL CHECK ("participants" >= 0), "payment" varchar(8) NOT NULL, "reason" varchar(500) NOT NULL, "owner_id" bigint NOT NULL REFERENCES "portal_member" ("id") DEFERRABLE INITIALLY DEFERRED, "slot_id" bigint NOT NULL REFERENCES "portal_slot" ("id") DEFERRABLE INITIALLY DEFERRED, "variation_id" bigint NOT NULL REFERENCES "portal_variation" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "valid_quest_status" CHECK ("status" IN ('pending', 'confirmed', 'cancelled', 'finished')), CONSTRAINT "reason_only_for_cancellation" CHECK ((("status" = 'cancelled' AND NOT ("reason" = '')) OR (NOT ("status" = 'cancelled') AND "reason" = ''))), CONSTRAINT "valid_team_size" CHECK (("participants" >= 1 AND "participants" <= 30)));

INSERT INTO "portal_member" VALUES(1,'admin','pbkdf2_sha256$1000000$moo9Vl0jz1dM6VGY7hJrcU$UuaE8TauO6Ic2VQHweXoEZSPTQKSyVnkGhGWnHQ2AUg=','Администратор Портала','8(900)000-00-01','quest@example.ru',1);

INSERT INTO "portal_member" VALUES(2,'demo2026','pbkdf2_sha256$1000000$szE6XGuOBoVK6cgCyGT6Hu$CmmyndGhE0w3vRlqrRIA8XsBn9AGxilsACTqXVmI2JU=','Иванова Марина Олеговна','8(916)440-26-30','client0@example.ru',0);

INSERT INTO "portal_member" VALUES(3,'client126','pbkdf2_sha256$1000000$4WwYEy1mAyv6Q8eLeSXpvJ$1eWbW2VtlR9CpVBpvpDrPNYdcHPFMXubAuVCepbHHFM=','Смирнов Артём Ильич','8(916)440-26-31','client1@example.ru',0);

INSERT INTO "portal_member" VALUES(4,'client226','pbkdf2_sha256$1000000$IcgGrLeAU6hYw9X0kK4Lbw$oTQgAlZWMNGaLLw9u9MlfEQS8MIG+7rNCsgItpdnEGE=','Орлова Елена Сергеевна','8(916)440-26-32','client2@example.ru',0);

INSERT INTO "portal_member" VALUES(5,'client326','pbkdf2_sha256$1000000$PahEkK1DZQ3Omz0RX9oHCw$bpds2/WJB5LfEjh43fXoCdvlPIGJRLCLvrZN559KoVw=','Кузнецов Павел Андреевич','8(916)440-26-33','client3@example.ru',0);

INSERT INTO "portal_member" VALUES(6,'client426','pbkdf2_sha256$1000000$GIbovk8WXCfD7K8NpR57Fm$uDCNmfLVykzqF6tXbqLhIM6NRUeVKcPASPx+9nd98bA=','Соколова Дарья Викторовна','8(916)440-26-34','client4@example.ru',0);

INSERT INTO "portal_member" VALUES(7,'client526','pbkdf2_sha256$1000000$03KsFlKOyo2TBi6p8nAtw7$kgnSO76tWSb597UGPjPgA7k05KSYxg3GwaVYA8XGm08=','Попов Михаил Юрьевич','8(916)440-26-35','client5@example.ru',0);

INSERT INTO "portal_quest" VALUES(1,'Тайна заброшенного бункера','Исследуйте заброшенный объект и расшифруйте сигналы из подземелья.',1);

INSERT INTO "portal_quest" VALUES(2,'Побег из лаборатории','Найдите выход из секретного комплекса раньше, чем завершится эксперимент.',1);

INSERT INTO "portal_quest" VALUES(3,'Проклятие старого особняка','Разгадайте историю дома, в котором каждый предмет хранит тайну.',1);

INSERT INTO "portal_quest" VALUES(4,'Код полярной станции','Сезонная игра о восстановлении связи с экспедицией.',0);

INSERT INTO "portal_quest" VALUES(5,'Последний рейс','Временный сценарий о поиске пропавшего багажа.',0);

INSERT INTO "portal_quest" VALUES(6,'Архив часовщика','Закрытая выставочная игра с механическими головоломками.',0);

INSERT INTO "portal_review" VALUES(1,'Отличная атмосфера. Подсказки появлялись в нужный момент.','2026-11-08 22:25:21.424187',1);

INSERT INTO "portal_review" VALUES(2,'Локация понравилась всей команде, обязательно вернёмся.','2026-11-08 22:25:21.425197',2);

INSERT INTO "portal_review" VALUES(3,'Отличная атмосфера. Подсказки появлялись в нужный момент.','2026-11-08 22:25:21.426214',3);

INSERT INTO "portal_review" VALUES(4,'Локация понравилась всей команде, обязательно вернёмся.','2026-11-08 22:25:21.427222',4);

INSERT INTO "portal_review" VALUES(5,'Отличная атмосфера. Подсказки появлялись в нужный момент.','2026-11-08 22:25:21.428229',5);

INSERT INTO "portal_review" VALUES(6,'Локация понравилась всей команде, обязательно вернёмся.','2026-11-08 22:25:21.429236',6);

INSERT INTO "portal_slot" VALUES(1,'2026-10-24','12:00:00',1);

INSERT INTO "portal_slot" VALUES(2,'2026-10-24','15:00:00',1);

INSERT INTO "portal_slot" VALUES(3,'2026-10-24','18:00:00',1);

INSERT INTO "portal_slot" VALUES(4,'2026-10-24','21:00:00',1);

INSERT INTO "portal_slot" VALUES(5,'2026-10-25','12:00:00',1);

INSERT INTO "portal_slot" VALUES(6,'2026-10-25','15:00:00',1);

INSERT INTO "portal_slot" VALUES(7,'2026-10-25','18:00:00',1);

INSERT INTO "portal_slot" VALUES(8,'2026-10-25','21:00:00',1);

INSERT INTO "portal_slot" VALUES(9,'2026-10-26','12:00:00',1);

INSERT INTO "portal_slot" VALUES(10,'2026-10-26','15:00:00',1);

INSERT INTO "portal_slot" VALUES(11,'2026-10-26','18:00:00',1);

INSERT INTO "portal_slot" VALUES(12,'2026-10-26','21:00:00',1);

INSERT INTO "portal_slot" VALUES(13,'2026-10-27','12:00:00',1);

INSERT INTO "portal_slot" VALUES(14,'2026-10-27','15:00:00',1);

INSERT INTO "portal_slot" VALUES(15,'2026-10-27','18:00:00',1);

INSERT INTO "portal_slot" VALUES(16,'2026-10-27','21:00:00',1);

INSERT INTO "portal_slot" VALUES(17,'2026-10-28','12:00:00',1);

INSERT INTO "portal_slot" VALUES(18,'2026-10-28','15:00:00',1);

INSERT INTO "portal_slot" VALUES(19,'2026-10-28','18:00:00',1);

INSERT INTO "portal_slot" VALUES(20,'2026-10-28','21:00:00',1);

INSERT INTO "portal_slot" VALUES(21,'2026-10-29','12:00:00',1);

INSERT INTO "portal_slot" VALUES(22,'2026-10-29','15:00:00',1);

INSERT INTO "portal_slot" VALUES(23,'2026-10-29','18:00:00',1);

INSERT INTO "portal_slot" VALUES(24,'2026-10-29','21:00:00',1);

INSERT INTO "portal_slot" VALUES(25,'2026-10-30','12:00:00',1);

INSERT INTO "portal_slot" VALUES(26,'2026-10-30','15:00:00',1);

INSERT INTO "portal_slot" VALUES(27,'2026-10-30','18:00:00',1);

INSERT INTO "portal_slot" VALUES(28,'2026-10-30','21:00:00',1);

INSERT INTO "portal_slot" VALUES(29,'2026-10-31','12:00:00',1);

INSERT INTO "portal_slot" VALUES(30,'2026-10-31','15:00:00',1);

INSERT INTO "portal_slot" VALUES(31,'2026-10-31','18:00:00',1);

INSERT INTO "portal_slot" VALUES(32,'2026-10-31','21:00:00',1);

INSERT INTO "portal_slot" VALUES(33,'2026-11-01','12:00:00',1);

INSERT INTO "portal_slot" VALUES(34,'2026-11-01','15:00:00',1);

INSERT INTO "portal_slot" VALUES(35,'2026-11-01','18:00:00',1);

INSERT INTO "portal_slot" VALUES(36,'2026-11-01','21:00:00',1);

INSERT INTO "portal_slot" VALUES(37,'2026-11-02','12:00:00',1);

INSERT INTO "portal_slot" VALUES(38,'2026-11-02','15:00:00',1);

INSERT INTO "portal_slot" VALUES(39,'2026-11-02','18:00:00',1);

INSERT INTO "portal_slot" VALUES(40,'2026-11-02','21:00:00',1);

INSERT INTO "portal_slot" VALUES(41,'2026-11-03','12:00:00',1);

INSERT INTO "portal_slot" VALUES(42,'2026-11-03','15:00:00',1);

INSERT INTO "portal_slot" VALUES(43,'2026-11-03','18:00:00',1);

INSERT INTO "portal_slot" VALUES(44,'2026-11-03','21:00:00',1);

INSERT INTO "portal_slot" VALUES(45,'2026-11-04','12:00:00',1);

INSERT INTO "portal_slot" VALUES(46,'2026-11-04','15:00:00',1);

INSERT INTO "portal_slot" VALUES(47,'2026-11-04','18:00:00',1);

INSERT INTO "portal_slot" VALUES(48,'2026-11-04','21:00:00',1);

INSERT INTO "portal_slot" VALUES(49,'2026-11-05','12:00:00',1);

INSERT INTO "portal_slot" VALUES(50,'2026-11-05','15:00:00',1);

INSERT INTO "portal_slot" VALUES(51,'2026-11-05','18:00:00',1);

INSERT INTO "portal_slot" VALUES(52,'2026-11-05','21:00:00',1);

INSERT INTO "portal_slot" VALUES(53,'2026-11-06','12:00:00',1);

INSERT INTO "portal_slot" VALUES(54,'2026-11-06','15:00:00',1);

INSERT INTO "portal_slot" VALUES(55,'2026-11-06','18:00:00',1);

INSERT INTO "portal_slot" VALUES(56,'2026-11-06','21:00:00',1);

INSERT INTO "portal_slot" VALUES(57,'2026-11-07','12:00:00',1);

INSERT INTO "portal_slot" VALUES(58,'2026-11-07','15:00:00',1);

INSERT INTO "portal_slot" VALUES(59,'2026-11-07','18:00:00',1);

INSERT INTO "portal_slot" VALUES(60,'2026-11-07','21:00:00',1);

INSERT INTO "portal_slot" VALUES(61,'2026-11-08','12:00:00',1);

INSERT INTO "portal_slot" VALUES(62,'2026-11-08','15:00:00',1);

INSERT INTO "portal_slot" VALUES(63,'2026-11-08','18:00:00',1);

INSERT INTO "portal_slot" VALUES(64,'2026-11-08','21:00:00',1);

INSERT INTO "portal_slot" VALUES(65,'2026-11-09','12:00:00',1);

INSERT INTO "portal_slot" VALUES(66,'2026-11-09','15:00:00',1);

INSERT INTO "portal_slot" VALUES(67,'2026-11-09','18:00:00',1);

INSERT INTO "portal_slot" VALUES(68,'2026-11-09','21:00:00',1);

INSERT INTO "portal_slot" VALUES(69,'2026-11-10','12:00:00',1);

INSERT INTO "portal_slot" VALUES(70,'2026-11-10','15:00:00',1);

INSERT INTO "portal_slot" VALUES(71,'2026-11-10','18:00:00',1);

INSERT INTO "portal_slot" VALUES(72,'2026-11-10','21:00:00',1);

INSERT INTO "portal_slot" VALUES(73,'2026-11-11','12:00:00',1);

INSERT INTO "portal_slot" VALUES(74,'2026-11-11','15:00:00',1);

INSERT INTO "portal_slot" VALUES(75,'2026-11-11','18:00:00',1);

INSERT INTO "portal_slot" VALUES(76,'2026-11-11','21:00:00',1);

INSERT INTO "portal_slot" VALUES(77,'2026-11-12','12:00:00',1);

INSERT INTO "portal_slot" VALUES(78,'2026-11-12','15:00:00',1);

INSERT INTO "portal_slot" VALUES(79,'2026-11-12','18:00:00',1);

INSERT INTO "portal_slot" VALUES(80,'2026-11-12','21:00:00',1);

INSERT INTO "portal_slot" VALUES(81,'2026-11-13','12:00:00',1);

INSERT INTO "portal_slot" VALUES(82,'2026-11-13','15:00:00',1);

INSERT INTO "portal_slot" VALUES(83,'2026-11-13','18:00:00',1);

INSERT INTO "portal_slot" VALUES(84,'2026-11-13','21:00:00',1);

INSERT INTO "portal_slot" VALUES(85,'2026-11-14','12:00:00',1);

INSERT INTO "portal_slot" VALUES(86,'2026-11-14','15:00:00',1);

INSERT INTO "portal_slot" VALUES(87,'2026-11-14','18:00:00',1);

INSERT INTO "portal_slot" VALUES(88,'2026-11-14','21:00:00',1);

INSERT INTO "portal_slot" VALUES(89,'2026-11-15','12:00:00',1);

INSERT INTO "portal_slot" VALUES(90,'2026-11-15','15:00:00',1);

INSERT INTO "portal_slot" VALUES(91,'2026-11-15','18:00:00',1);

INSERT INTO "portal_slot" VALUES(92,'2026-11-15','21:00:00',1);

INSERT INTO "portal_slot" VALUES(93,'2026-11-16','12:00:00',1);

INSERT INTO "portal_slot" VALUES(94,'2026-11-16','15:00:00',1);

INSERT INTO "portal_slot" VALUES(95,'2026-11-16','18:00:00',1);

INSERT INTO "portal_slot" VALUES(96,'2026-11-16','21:00:00',1);

INSERT INTO "portal_slot" VALUES(97,'2026-11-17','12:00:00',1);

INSERT INTO "portal_slot" VALUES(98,'2026-11-17','15:00:00',1);

INSERT INTO "portal_slot" VALUES(99,'2026-11-17','18:00:00',1);

INSERT INTO "portal_slot" VALUES(100,'2026-11-17','21:00:00',1);

INSERT INTO "portal_slot" VALUES(101,'2026-11-18','12:00:00',1);

INSERT INTO "portal_slot" VALUES(102,'2026-11-18','15:00:00',1);

INSERT INTO "portal_slot" VALUES(103,'2026-11-18','18:00:00',1);

INSERT INTO "portal_slot" VALUES(104,'2026-11-18','21:00:00',1);

INSERT INTO "portal_slot" VALUES(105,'2026-11-19','12:00:00',1);

INSERT INTO "portal_slot" VALUES(106,'2026-11-19','15:00:00',1);

INSERT INTO "portal_slot" VALUES(107,'2026-11-19','18:00:00',1);

INSERT INTO "portal_slot" VALUES(108,'2026-11-19','21:00:00',1);

INSERT INTO "portal_slot" VALUES(109,'2026-11-20','12:00:00',1);

INSERT INTO "portal_slot" VALUES(110,'2026-11-20','15:00:00',1);

INSERT INTO "portal_slot" VALUES(111,'2026-11-20','18:00:00',1);

INSERT INTO "portal_slot" VALUES(112,'2026-11-20','21:00:00',1);

INSERT INTO "portal_slot" VALUES(113,'2026-11-21','12:00:00',1);

INSERT INTO "portal_slot" VALUES(114,'2026-11-21','15:00:00',1);

INSERT INTO "portal_slot" VALUES(115,'2026-11-21','18:00:00',1);

INSERT INTO "portal_slot" VALUES(116,'2026-11-21','21:00:00',1);

INSERT INTO "portal_slot" VALUES(117,'2026-11-22','12:00:00',1);

INSERT INTO "portal_slot" VALUES(118,'2026-11-22','15:00:00',1);

INSERT INTO "portal_slot" VALUES(119,'2026-11-22','18:00:00',1);

INSERT INTO "portal_slot" VALUES(120,'2026-11-22','21:00:00',1);

INSERT INTO "portal_slot" VALUES(121,'2026-11-23','12:00:00',1);

INSERT INTO "portal_slot" VALUES(122,'2026-11-23','15:00:00',1);

INSERT INTO "portal_slot" VALUES(123,'2026-11-23','18:00:00',1);

INSERT INTO "portal_slot" VALUES(124,'2026-11-23','21:00:00',1);

INSERT INTO "portal_slot" VALUES(125,'2026-11-24','12:00:00',1);

INSERT INTO "portal_slot" VALUES(126,'2026-11-24','15:00:00',1);

INSERT INTO "portal_slot" VALUES(127,'2026-11-24','18:00:00',1);

INSERT INTO "portal_slot" VALUES(128,'2026-11-24','21:00:00',1);

INSERT INTO "portal_slot" VALUES(129,'2026-11-25','12:00:00',1);

INSERT INTO "portal_slot" VALUES(130,'2026-11-25','15:00:00',1);

INSERT INTO "portal_slot" VALUES(131,'2026-11-25','18:00:00',1);

INSERT INTO "portal_slot" VALUES(132,'2026-11-25','21:00:00',1);

INSERT INTO "portal_slot" VALUES(133,'2026-11-26','12:00:00',1);

INSERT INTO "portal_slot" VALUES(134,'2026-11-26','15:00:00',1);

INSERT INTO "portal_slot" VALUES(135,'2026-11-26','18:00:00',1);

INSERT INTO "portal_slot" VALUES(136,'2026-11-26','21:00:00',1);

INSERT INTO "portal_slot" VALUES(137,'2026-11-27','12:00:00',1);

INSERT INTO "portal_slot" VALUES(138,'2026-11-27','15:00:00',1);

INSERT INTO "portal_slot" VALUES(139,'2026-11-27','18:00:00',1);

INSERT INTO "portal_slot" VALUES(140,'2026-11-27','21:00:00',1);

INSERT INTO "portal_slot" VALUES(141,'2026-11-28','12:00:00',1);

INSERT INTO "portal_slot" VALUES(142,'2026-11-28','15:00:00',1);

INSERT INTO "portal_slot" VALUES(143,'2026-11-28','18:00:00',1);

INSERT INTO "portal_slot" VALUES(144,'2026-11-28','21:00:00',1);

INSERT INTO "portal_slot" VALUES(145,'2026-11-29','12:00:00',1);

INSERT INTO "portal_slot" VALUES(146,'2026-11-29','15:00:00',1);

INSERT INTO "portal_slot" VALUES(147,'2026-11-29','18:00:00',1);

INSERT INTO "portal_slot" VALUES(148,'2026-11-29','21:00:00',1);

INSERT INTO "portal_slot" VALUES(149,'2026-11-30','12:00:00',1);

INSERT INTO "portal_slot" VALUES(150,'2026-11-30','15:00:00',1);

INSERT INTO "portal_slot" VALUES(151,'2026-11-30','18:00:00',1);

INSERT INTO "portal_slot" VALUES(152,'2026-11-30','21:00:00',1);

INSERT INTO "portal_slot" VALUES(153,'2026-12-01','12:00:00',1);

INSERT INTO "portal_slot" VALUES(154,'2026-12-01','15:00:00',1);

INSERT INTO "portal_slot" VALUES(155,'2026-12-01','18:00:00',1);

INSERT INTO "portal_slot" VALUES(156,'2026-12-01','21:00:00',1);

INSERT INTO "portal_slot" VALUES(157,'2026-12-02','12:00:00',1);

INSERT INTO "portal_slot" VALUES(158,'2026-12-02','15:00:00',1);

INSERT INTO "portal_slot" VALUES(159,'2026-12-02','18:00:00',1);

INSERT INTO "portal_slot" VALUES(160,'2026-12-02','21:00:00',1);

INSERT INTO "portal_slot" VALUES(161,'2026-12-03','12:00:00',1);

INSERT INTO "portal_slot" VALUES(162,'2026-12-03','15:00:00',1);

INSERT INTO "portal_slot" VALUES(163,'2026-12-03','18:00:00',1);

INSERT INTO "portal_slot" VALUES(164,'2026-12-03','21:00:00',1);

INSERT INTO "portal_slot" VALUES(165,'2026-12-04','12:00:00',1);

INSERT INTO "portal_slot" VALUES(166,'2026-12-04','15:00:00',1);

INSERT INTO "portal_slot" VALUES(167,'2026-12-04','18:00:00',1);

INSERT INTO "portal_slot" VALUES(168,'2026-12-04','21:00:00',1);

INSERT INTO "portal_slot" VALUES(169,'2026-12-05','12:00:00',1);

INSERT INTO "portal_slot" VALUES(170,'2026-12-05','15:00:00',1);

INSERT INTO "portal_slot" VALUES(171,'2026-12-05','18:00:00',1);

INSERT INTO "portal_slot" VALUES(172,'2026-12-05','21:00:00',1);

INSERT INTO "portal_slot" VALUES(173,'2026-12-06','12:00:00',1);

INSERT INTO "portal_slot" VALUES(174,'2026-12-06','15:00:00',1);

INSERT INTO "portal_slot" VALUES(175,'2026-12-06','18:00:00',1);

INSERT INTO "portal_slot" VALUES(176,'2026-12-06','21:00:00',1);

INSERT INTO "portal_slot" VALUES(177,'2026-12-07','12:00:00',1);

INSERT INTO "portal_slot" VALUES(178,'2026-12-07','15:00:00',1);

INSERT INTO "portal_slot" VALUES(179,'2026-12-07','18:00:00',1);

INSERT INTO "portal_slot" VALUES(180,'2026-12-07','21:00:00',1);

INSERT INTO "portal_slot" VALUES(181,'2026-12-08','12:00:00',1);

INSERT INTO "portal_slot" VALUES(182,'2026-12-08','15:00:00',1);

INSERT INTO "portal_slot" VALUES(183,'2026-12-08','18:00:00',1);

INSERT INTO "portal_slot" VALUES(184,'2026-12-08','21:00:00',1);

INSERT INTO "portal_slot" VALUES(185,'2026-12-09','12:00:00',1);

INSERT INTO "portal_slot" VALUES(186,'2026-12-09','15:00:00',1);

INSERT INTO "portal_slot" VALUES(187,'2026-12-09','18:00:00',1);

INSERT INTO "portal_slot" VALUES(188,'2026-12-09','21:00:00',1);

INSERT INTO "portal_slot" VALUES(189,'2026-12-10','12:00:00',1);

INSERT INTO "portal_slot" VALUES(190,'2026-12-10','15:00:00',1);

INSERT INTO "portal_slot" VALUES(191,'2026-12-10','18:00:00',1);

INSERT INTO "portal_slot" VALUES(192,'2026-12-10','21:00:00',1);

INSERT INTO "portal_slot" VALUES(193,'2026-12-11','12:00:00',1);

INSERT INTO "portal_slot" VALUES(194,'2026-12-11','15:00:00',1);

INSERT INTO "portal_slot" VALUES(195,'2026-12-11','18:00:00',1);

INSERT INTO "portal_slot" VALUES(196,'2026-12-11','21:00:00',1);

INSERT INTO "portal_slot" VALUES(197,'2026-12-12','12:00:00',1);

INSERT INTO "portal_slot" VALUES(198,'2026-12-12','15:00:00',1);

INSERT INTO "portal_slot" VALUES(199,'2026-12-12','18:00:00',1);

INSERT INTO "portal_slot" VALUES(200,'2026-12-12','21:00:00',1);

INSERT INTO "portal_slot" VALUES(201,'2026-12-13','12:00:00',1);

INSERT INTO "portal_slot" VALUES(202,'2026-12-13','15:00:00',1);

INSERT INTO "portal_slot" VALUES(203,'2026-12-13','18:00:00',1);

INSERT INTO "portal_slot" VALUES(204,'2026-12-13','21:00:00',1);

INSERT INTO "portal_slot" VALUES(205,'2026-12-14','12:00:00',1);

INSERT INTO "portal_slot" VALUES(206,'2026-12-14','15:00:00',1);

INSERT INTO "portal_slot" VALUES(207,'2026-12-14','18:00:00',1);

INSERT INTO "portal_slot" VALUES(208,'2026-12-14','21:00:00',1);

INSERT INTO "portal_slot" VALUES(209,'2026-12-15','12:00:00',1);

INSERT INTO "portal_slot" VALUES(210,'2026-12-15','15:00:00',1);

INSERT INTO "portal_slot" VALUES(211,'2026-12-15','18:00:00',1);

INSERT INTO "portal_slot" VALUES(212,'2026-12-15','21:00:00',1);

INSERT INTO "portal_slot" VALUES(213,'2026-12-16','12:00:00',1);

INSERT INTO "portal_slot" VALUES(214,'2026-12-16','15:00:00',1);

INSERT INTO "portal_slot" VALUES(215,'2026-12-16','18:00:00',1);

INSERT INTO "portal_slot" VALUES(216,'2026-12-16','21:00:00',1);

INSERT INTO "portal_slot" VALUES(217,'2026-12-17','12:00:00',1);

INSERT INTO "portal_slot" VALUES(218,'2026-12-17','15:00:00',1);

INSERT INTO "portal_slot" VALUES(219,'2026-12-17','18:00:00',1);

INSERT INTO "portal_slot" VALUES(220,'2026-12-17','21:00:00',1);

INSERT INTO "portal_slot" VALUES(221,'2026-12-18','12:00:00',1);

INSERT INTO "portal_slot" VALUES(222,'2026-12-18','15:00:00',1);

INSERT INTO "portal_slot" VALUES(223,'2026-12-18','18:00:00',1);

INSERT INTO "portal_slot" VALUES(224,'2026-12-18','21:00:00',1);

INSERT INTO "portal_slot" VALUES(225,'2026-12-19','12:00:00',1);

INSERT INTO "portal_slot" VALUES(226,'2026-12-19','15:00:00',1);

INSERT INTO "portal_slot" VALUES(227,'2026-12-19','18:00:00',1);

INSERT INTO "portal_slot" VALUES(228,'2026-12-19','21:00:00',1);

INSERT INTO "portal_slot" VALUES(229,'2026-12-20','12:00:00',1);

INSERT INTO "portal_slot" VALUES(230,'2026-12-20','15:00:00',1);

INSERT INTO "portal_slot" VALUES(231,'2026-12-20','18:00:00',1);

INSERT INTO "portal_slot" VALUES(232,'2026-12-20','21:00:00',1);

INSERT INTO "portal_slot" VALUES(233,'2026-12-21','12:00:00',1);

INSERT INTO "portal_slot" VALUES(234,'2026-12-21','15:00:00',1);

INSERT INTO "portal_slot" VALUES(235,'2026-12-21','18:00:00',1);

INSERT INTO "portal_slot" VALUES(236,'2026-12-21','21:00:00',1);

INSERT INTO "portal_slot" VALUES(237,'2026-12-22','12:00:00',1);

INSERT INTO "portal_slot" VALUES(238,'2026-12-22','15:00:00',1);

INSERT INTO "portal_slot" VALUES(239,'2026-12-22','18:00:00',1);

INSERT INTO "portal_slot" VALUES(240,'2026-12-22','21:00:00',1);

INSERT INTO "portal_slot" VALUES(241,'2026-12-23','12:00:00',1);

INSERT INTO "portal_slot" VALUES(242,'2026-12-23','15:00:00',1);

INSERT INTO "portal_slot" VALUES(243,'2026-12-23','18:00:00',1);

INSERT INTO "portal_slot" VALUES(244,'2026-12-23','21:00:00',1);

INSERT INTO "portal_slot" VALUES(245,'2026-12-24','12:00:00',1);

INSERT INTO "portal_slot" VALUES(246,'2026-12-24','15:00:00',1);

INSERT INTO "portal_slot" VALUES(247,'2026-12-24','18:00:00',1);

INSERT INTO "portal_slot" VALUES(248,'2026-12-24','21:00:00',1);

INSERT INTO "portal_slot" VALUES(249,'2026-12-25','12:00:00',1);

INSERT INTO "portal_slot" VALUES(250,'2026-12-25','15:00:00',1);

INSERT INTO "portal_slot" VALUES(251,'2026-12-25','18:00:00',1);

INSERT INTO "portal_slot" VALUES(252,'2026-12-25','21:00:00',1);

INSERT INTO "portal_slot" VALUES(253,'2026-12-26','12:00:00',1);

INSERT INTO "portal_slot" VALUES(254,'2026-12-26','15:00:00',1);

INSERT INTO "portal_slot" VALUES(255,'2026-12-26','18:00:00',1);

INSERT INTO "portal_slot" VALUES(256,'2026-12-26','21:00:00',1);

INSERT INTO "portal_slot" VALUES(257,'2026-12-27','12:00:00',1);

INSERT INTO "portal_slot" VALUES(258,'2026-12-27','15:00:00',1);

INSERT INTO "portal_slot" VALUES(259,'2026-12-27','18:00:00',1);

INSERT INTO "portal_slot" VALUES(260,'2026-12-27','21:00:00',1);

INSERT INTO "portal_slot" VALUES(261,'2026-12-28','12:00:00',1);

INSERT INTO "portal_slot" VALUES(262,'2026-12-28','15:00:00',1);

INSERT INTO "portal_slot" VALUES(263,'2026-12-28','18:00:00',1);

INSERT INTO "portal_slot" VALUES(264,'2026-12-28','21:00:00',1);

INSERT INTO "portal_slot" VALUES(265,'2026-12-29','12:00:00',1);

INSERT INTO "portal_slot" VALUES(266,'2026-12-29','15:00:00',1);

INSERT INTO "portal_slot" VALUES(267,'2026-12-29','18:00:00',1);

INSERT INTO "portal_slot" VALUES(268,'2026-12-29','21:00:00',1);

INSERT INTO "portal_slot" VALUES(269,'2026-12-30','12:00:00',1);

INSERT INTO "portal_slot" VALUES(270,'2026-12-30','15:00:00',1);

INSERT INTO "portal_slot" VALUES(271,'2026-12-30','18:00:00',1);

INSERT INTO "portal_slot" VALUES(272,'2026-12-30','21:00:00',1);

INSERT INTO "portal_slot" VALUES(273,'2026-12-31','12:00:00',1);

INSERT INTO "portal_slot" VALUES(274,'2026-12-31','15:00:00',1);

INSERT INTO "portal_slot" VALUES(275,'2026-12-31','18:00:00',1);

INSERT INTO "portal_slot" VALUES(276,'2026-12-31','21:00:00',1);

INSERT INTO "portal_slot" VALUES(277,'2027-01-01','12:00:00',1);

INSERT INTO "portal_slot" VALUES(278,'2027-01-01','15:00:00',1);

INSERT INTO "portal_slot" VALUES(279,'2027-01-01','18:00:00',1);

INSERT INTO "portal_slot" VALUES(280,'2027-01-01','21:00:00',1);

INSERT INTO "portal_slot" VALUES(281,'2027-01-02','12:00:00',1);

INSERT INTO "portal_slot" VALUES(282,'2027-01-02','15:00:00',1);

INSERT INTO "portal_slot" VALUES(283,'2027-01-02','18:00:00',1);

INSERT INTO "portal_slot" VALUES(284,'2027-01-02','21:00:00',1);

INSERT INTO "portal_slot" VALUES(285,'2027-01-03','12:00:00',1);

INSERT INTO "portal_slot" VALUES(286,'2027-01-03','15:00:00',1);

INSERT INTO "portal_slot" VALUES(287,'2027-01-03','18:00:00',1);

INSERT INTO "portal_slot" VALUES(288,'2027-01-03','21:00:00',1);

INSERT INTO "portal_slot" VALUES(289,'2027-01-04','12:00:00',1);

INSERT INTO "portal_slot" VALUES(290,'2027-01-04','15:00:00',1);

INSERT INTO "portal_slot" VALUES(291,'2027-01-04','18:00:00',1);

INSERT INTO "portal_slot" VALUES(292,'2027-01-04','21:00:00',1);

INSERT INTO "portal_slot" VALUES(293,'2027-01-05','12:00:00',1);

INSERT INTO "portal_slot" VALUES(294,'2027-01-05','15:00:00',1);

INSERT INTO "portal_slot" VALUES(295,'2027-01-05','18:00:00',1);

INSERT INTO "portal_slot" VALUES(296,'2027-01-05','21:00:00',1);

INSERT INTO "portal_slot" VALUES(297,'2027-01-06','12:00:00',1);

INSERT INTO "portal_slot" VALUES(298,'2027-01-06','15:00:00',1);

INSERT INTO "portal_slot" VALUES(299,'2027-01-06','18:00:00',1);

INSERT INTO "portal_slot" VALUES(300,'2027-01-06','21:00:00',1);

INSERT INTO "portal_slot" VALUES(301,'2027-01-07','12:00:00',1);

INSERT INTO "portal_slot" VALUES(302,'2027-01-07','15:00:00',1);

INSERT INTO "portal_slot" VALUES(303,'2027-01-07','18:00:00',1);

INSERT INTO "portal_slot" VALUES(304,'2027-01-07','21:00:00',1);

INSERT INTO "portal_slot" VALUES(305,'2027-01-08','12:00:00',1);

INSERT INTO "portal_slot" VALUES(306,'2027-01-08','15:00:00',1);

INSERT INTO "portal_slot" VALUES(307,'2027-01-08','18:00:00',1);

INSERT INTO "portal_slot" VALUES(308,'2027-01-08','21:00:00',1);

INSERT INTO "portal_slot" VALUES(309,'2026-10-24','12:00:00',2);

INSERT INTO "portal_slot" VALUES(310,'2026-10-24','15:00:00',2);

INSERT INTO "portal_slot" VALUES(311,'2026-10-24','18:00:00',2);

INSERT INTO "portal_slot" VALUES(312,'2026-10-24','21:00:00',2);

INSERT INTO "portal_slot" VALUES(313,'2026-10-25','12:00:00',2);

INSERT INTO "portal_slot" VALUES(314,'2026-10-25','15:00:00',2);

INSERT INTO "portal_slot" VALUES(315,'2026-10-25','18:00:00',2);

INSERT INTO "portal_slot" VALUES(316,'2026-10-25','21:00:00',2);

INSERT INTO "portal_slot" VALUES(317,'2026-10-26','12:00:00',2);

INSERT INTO "portal_slot" VALUES(318,'2026-10-26','15:00:00',2);

INSERT INTO "portal_slot" VALUES(319,'2026-10-26','18:00:00',2);

INSERT INTO "portal_slot" VALUES(320,'2026-10-26','21:00:00',2);

INSERT INTO "portal_slot" VALUES(321,'2026-10-27','12:00:00',2);

INSERT INTO "portal_slot" VALUES(322,'2026-10-27','15:00:00',2);

INSERT INTO "portal_slot" VALUES(323,'2026-10-27','18:00:00',2);

INSERT INTO "portal_slot" VALUES(324,'2026-10-27','21:00:00',2);

INSERT INTO "portal_slot" VALUES(325,'2026-10-28','12:00:00',2);

INSERT INTO "portal_slot" VALUES(326,'2026-10-28','15:00:00',2);

INSERT INTO "portal_slot" VALUES(327,'2026-10-28','18:00:00',2);

INSERT INTO "portal_slot" VALUES(328,'2026-10-28','21:00:00',2);

INSERT INTO "portal_slot" VALUES(329,'2026-10-29','12:00:00',2);

INSERT INTO "portal_slot" VALUES(330,'2026-10-29','15:00:00',2);

INSERT INTO "portal_slot" VALUES(331,'2026-10-29','18:00:00',2);

INSERT INTO "portal_slot" VALUES(332,'2026-10-29','21:00:00',2);

INSERT INTO "portal_slot" VALUES(333,'2026-10-30','12:00:00',2);

INSERT INTO "portal_slot" VALUES(334,'2026-10-30','15:00:00',2);

INSERT INTO "portal_slot" VALUES(335,'2026-10-30','18:00:00',2);

INSERT INTO "portal_slot" VALUES(336,'2026-10-30','21:00:00',2);

INSERT INTO "portal_slot" VALUES(337,'2026-10-31','12:00:00',2);

INSERT INTO "portal_slot" VALUES(338,'2026-10-31','15:00:00',2);

INSERT INTO "portal_slot" VALUES(339,'2026-10-31','18:00:00',2);

INSERT INTO "portal_slot" VALUES(340,'2026-10-31','21:00:00',2);

INSERT INTO "portal_slot" VALUES(341,'2026-11-01','12:00:00',2);

INSERT INTO "portal_slot" VALUES(342,'2026-11-01','15:00:00',2);

INSERT INTO "portal_slot" VALUES(343,'2026-11-01','18:00:00',2);

INSERT INTO "portal_slot" VALUES(344,'2026-11-01','21:00:00',2);

INSERT INTO "portal_slot" VALUES(345,'2026-11-02','12:00:00',2);

INSERT INTO "portal_slot" VALUES(346,'2026-11-02','15:00:00',2);

INSERT INTO "portal_slot" VALUES(347,'2026-11-02','18:00:00',2);

INSERT INTO "portal_slot" VALUES(348,'2026-11-02','21:00:00',2);

INSERT INTO "portal_slot" VALUES(349,'2026-11-03','12:00:00',2);

INSERT INTO "portal_slot" VALUES(350,'2026-11-03','15:00:00',2);

INSERT INTO "portal_slot" VALUES(351,'2026-11-03','18:00:00',2);

INSERT INTO "portal_slot" VALUES(352,'2026-11-03','21:00:00',2);

INSERT INTO "portal_slot" VALUES(353,'2026-11-04','12:00:00',2);

INSERT INTO "portal_slot" VALUES(354,'2026-11-04','15:00:00',2);

INSERT INTO "portal_slot" VALUES(355,'2026-11-04','18:00:00',2);

INSERT INTO "portal_slot" VALUES(356,'2026-11-04','21:00:00',2);

INSERT INTO "portal_slot" VALUES(357,'2026-11-05','12:00:00',2);

INSERT INTO "portal_slot" VALUES(358,'2026-11-05','15:00:00',2);

INSERT INTO "portal_slot" VALUES(359,'2026-11-05','18:00:00',2);

INSERT INTO "portal_slot" VALUES(360,'2026-11-05','21:00:00',2);

INSERT INTO "portal_slot" VALUES(361,'2026-11-06','12:00:00',2);

INSERT INTO "portal_slot" VALUES(362,'2026-11-06','15:00:00',2);

INSERT INTO "portal_slot" VALUES(363,'2026-11-06','18:00:00',2);

INSERT INTO "portal_slot" VALUES(364,'2026-11-06','21:00:00',2);

INSERT INTO "portal_slot" VALUES(365,'2026-11-07','12:00:00',2);

INSERT INTO "portal_slot" VALUES(366,'2026-11-07','15:00:00',2);

INSERT INTO "portal_slot" VALUES(367,'2026-11-07','18:00:00',2);

INSERT INTO "portal_slot" VALUES(368,'2026-11-07','21:00:00',2);

INSERT INTO "portal_slot" VALUES(369,'2026-11-08','12:00:00',2);

INSERT INTO "portal_slot" VALUES(370,'2026-11-08','15:00:00',2);

INSERT INTO "portal_slot" VALUES(371,'2026-11-08','18:00:00',2);

INSERT INTO "portal_slot" VALUES(372,'2026-11-08','21:00:00',2);

INSERT INTO "portal_slot" VALUES(373,'2026-11-09','12:00:00',2);

INSERT INTO "portal_slot" VALUES(374,'2026-11-09','15:00:00',2);

INSERT INTO "portal_slot" VALUES(375,'2026-11-09','18:00:00',2);

INSERT INTO "portal_slot" VALUES(376,'2026-11-09','21:00:00',2);

INSERT INTO "portal_slot" VALUES(377,'2026-11-10','12:00:00',2);

INSERT INTO "portal_slot" VALUES(378,'2026-11-10','15:00:00',2);

INSERT INTO "portal_slot" VALUES(379,'2026-11-10','18:00:00',2);

INSERT INTO "portal_slot" VALUES(380,'2026-11-10','21:00:00',2);

INSERT INTO "portal_slot" VALUES(381,'2026-11-11','12:00:00',2);

INSERT INTO "portal_slot" VALUES(382,'2026-11-11','15:00:00',2);

INSERT INTO "portal_slot" VALUES(383,'2026-11-11','18:00:00',2);

INSERT INTO "portal_slot" VALUES(384,'2026-11-11','21:00:00',2);

INSERT INTO "portal_slot" VALUES(385,'2026-11-12','12:00:00',2);

INSERT INTO "portal_slot" VALUES(386,'2026-11-12','15:00:00',2);

INSERT INTO "portal_slot" VALUES(387,'2026-11-12','18:00:00',2);

INSERT INTO "portal_slot" VALUES(388,'2026-11-12','21:00:00',2);

INSERT INTO "portal_slot" VALUES(389,'2026-11-13','12:00:00',2);

INSERT INTO "portal_slot" VALUES(390,'2026-11-13','15:00:00',2);

INSERT INTO "portal_slot" VALUES(391,'2026-11-13','18:00:00',2);

INSERT INTO "portal_slot" VALUES(392,'2026-11-13','21:00:00',2);

INSERT INTO "portal_slot" VALUES(393,'2026-11-14','12:00:00',2);

INSERT INTO "portal_slot" VALUES(394,'2026-11-14','15:00:00',2);

INSERT INTO "portal_slot" VALUES(395,'2026-11-14','18:00:00',2);

INSERT INTO "portal_slot" VALUES(396,'2026-11-14','21:00:00',2);

INSERT INTO "portal_slot" VALUES(397,'2026-11-15','12:00:00',2);

INSERT INTO "portal_slot" VALUES(398,'2026-11-15','15:00:00',2);

INSERT INTO "portal_slot" VALUES(399,'2026-11-15','18:00:00',2);

INSERT INTO "portal_slot" VALUES(400,'2026-11-15','21:00:00',2);

INSERT INTO "portal_slot" VALUES(401,'2026-11-16','12:00:00',2);

INSERT INTO "portal_slot" VALUES(402,'2026-11-16','15:00:00',2);

INSERT INTO "portal_slot" VALUES(403,'2026-11-16','18:00:00',2);

INSERT INTO "portal_slot" VALUES(404,'2026-11-16','21:00:00',2);

INSERT INTO "portal_slot" VALUES(405,'2026-11-17','12:00:00',2);

INSERT INTO "portal_slot" VALUES(406,'2026-11-17','15:00:00',2);

INSERT INTO "portal_slot" VALUES(407,'2026-11-17','18:00:00',2);

INSERT INTO "portal_slot" VALUES(408,'2026-11-17','21:00:00',2);

INSERT INTO "portal_slot" VALUES(409,'2026-11-18','12:00:00',2);

INSERT INTO "portal_slot" VALUES(410,'2026-11-18','15:00:00',2);

INSERT INTO "portal_slot" VALUES(411,'2026-11-18','18:00:00',2);

INSERT INTO "portal_slot" VALUES(412,'2026-11-18','21:00:00',2);

INSERT INTO "portal_slot" VALUES(413,'2026-11-19','12:00:00',2);

INSERT INTO "portal_slot" VALUES(414,'2026-11-19','15:00:00',2);

INSERT INTO "portal_slot" VALUES(415,'2026-11-19','18:00:00',2);

INSERT INTO "portal_slot" VALUES(416,'2026-11-19','21:00:00',2);

INSERT INTO "portal_slot" VALUES(417,'2026-11-20','12:00:00',2);

INSERT INTO "portal_slot" VALUES(418,'2026-11-20','15:00:00',2);

INSERT INTO "portal_slot" VALUES(419,'2026-11-20','18:00:00',2);

INSERT INTO "portal_slot" VALUES(420,'2026-11-20','21:00:00',2);

INSERT INTO "portal_slot" VALUES(421,'2026-11-21','12:00:00',2);

INSERT INTO "portal_slot" VALUES(422,'2026-11-21','15:00:00',2);

INSERT INTO "portal_slot" VALUES(423,'2026-11-21','18:00:00',2);

INSERT INTO "portal_slot" VALUES(424,'2026-11-21','21:00:00',2);

INSERT INTO "portal_slot" VALUES(425,'2026-11-22','12:00:00',2);

INSERT INTO "portal_slot" VALUES(426,'2026-11-22','15:00:00',2);

INSERT INTO "portal_slot" VALUES(427,'2026-11-22','18:00:00',2);

INSERT INTO "portal_slot" VALUES(428,'2026-11-22','21:00:00',2);

INSERT INTO "portal_slot" VALUES(429,'2026-11-23','12:00:00',2);

INSERT INTO "portal_slot" VALUES(430,'2026-11-23','15:00:00',2);

INSERT INTO "portal_slot" VALUES(431,'2026-11-23','18:00:00',2);

INSERT INTO "portal_slot" VALUES(432,'2026-11-23','21:00:00',2);

INSERT INTO "portal_slot" VALUES(433,'2026-11-24','12:00:00',2);

INSERT INTO "portal_slot" VALUES(434,'2026-11-24','15:00:00',2);

INSERT INTO "portal_slot" VALUES(435,'2026-11-24','18:00:00',2);

INSERT INTO "portal_slot" VALUES(436,'2026-11-24','21:00:00',2);

INSERT INTO "portal_slot" VALUES(437,'2026-11-25','12:00:00',2);

INSERT INTO "portal_slot" VALUES(438,'2026-11-25','15:00:00',2);

INSERT INTO "portal_slot" VALUES(439,'2026-11-25','18:00:00',2);

INSERT INTO "portal_slot" VALUES(440,'2026-11-25','21:00:00',2);

INSERT INTO "portal_slot" VALUES(441,'2026-11-26','12:00:00',2);

INSERT INTO "portal_slot" VALUES(442,'2026-11-26','15:00:00',2);

INSERT INTO "portal_slot" VALUES(443,'2026-11-26','18:00:00',2);

INSERT INTO "portal_slot" VALUES(444,'2026-11-26','21:00:00',2);

INSERT INTO "portal_slot" VALUES(445,'2026-11-27','12:00:00',2);

INSERT INTO "portal_slot" VALUES(446,'2026-11-27','15:00:00',2);

INSERT INTO "portal_slot" VALUES(447,'2026-11-27','18:00:00',2);

INSERT INTO "portal_slot" VALUES(448,'2026-11-27','21:00:00',2);

INSERT INTO "portal_slot" VALUES(449,'2026-11-28','12:00:00',2);

INSERT INTO "portal_slot" VALUES(450,'2026-11-28','15:00:00',2);

INSERT INTO "portal_slot" VALUES(451,'2026-11-28','18:00:00',2);

INSERT INTO "portal_slot" VALUES(452,'2026-11-28','21:00:00',2);

INSERT INTO "portal_slot" VALUES(453,'2026-11-29','12:00:00',2);

INSERT INTO "portal_slot" VALUES(454,'2026-11-29','15:00:00',2);

INSERT INTO "portal_slot" VALUES(455,'2026-11-29','18:00:00',2);

INSERT INTO "portal_slot" VALUES(456,'2026-11-29','21:00:00',2);

INSERT INTO "portal_slot" VALUES(457,'2026-11-30','12:00:00',2);

INSERT INTO "portal_slot" VALUES(458,'2026-11-30','15:00:00',2);

INSERT INTO "portal_slot" VALUES(459,'2026-11-30','18:00:00',2);

INSERT INTO "portal_slot" VALUES(460,'2026-11-30','21:00:00',2);

INSERT INTO "portal_slot" VALUES(461,'2026-12-01','12:00:00',2);

INSERT INTO "portal_slot" VALUES(462,'2026-12-01','15:00:00',2);

INSERT INTO "portal_slot" VALUES(463,'2026-12-01','18:00:00',2);

INSERT INTO "portal_slot" VALUES(464,'2026-12-01','21:00:00',2);

INSERT INTO "portal_slot" VALUES(465,'2026-12-02','12:00:00',2);

INSERT INTO "portal_slot" VALUES(466,'2026-12-02','15:00:00',2);

INSERT INTO "portal_slot" VALUES(467,'2026-12-02','18:00:00',2);

INSERT INTO "portal_slot" VALUES(468,'2026-12-02','21:00:00',2);

INSERT INTO "portal_slot" VALUES(469,'2026-12-03','12:00:00',2);

INSERT INTO "portal_slot" VALUES(470,'2026-12-03','15:00:00',2);

INSERT INTO "portal_slot" VALUES(471,'2026-12-03','18:00:00',2);

INSERT INTO "portal_slot" VALUES(472,'2026-12-03','21:00:00',2);

INSERT INTO "portal_slot" VALUES(473,'2026-12-04','12:00:00',2);

INSERT INTO "portal_slot" VALUES(474,'2026-12-04','15:00:00',2);

INSERT INTO "portal_slot" VALUES(475,'2026-12-04','18:00:00',2);

INSERT INTO "portal_slot" VALUES(476,'2026-12-04','21:00:00',2);

INSERT INTO "portal_slot" VALUES(477,'2026-12-05','12:00:00',2);

INSERT INTO "portal_slot" VALUES(478,'2026-12-05','15:00:00',2);

INSERT INTO "portal_slot" VALUES(479,'2026-12-05','18:00:00',2);

INSERT INTO "portal_slot" VALUES(480,'2026-12-05','21:00:00',2);

INSERT INTO "portal_slot" VALUES(481,'2026-12-06','12:00:00',2);

INSERT INTO "portal_slot" VALUES(482,'2026-12-06','15:00:00',2);

INSERT INTO "portal_slot" VALUES(483,'2026-12-06','18:00:00',2);

INSERT INTO "portal_slot" VALUES(484,'2026-12-06','21:00:00',2);

INSERT INTO "portal_slot" VALUES(485,'2026-12-07','12:00:00',2);

INSERT INTO "portal_slot" VALUES(486,'2026-12-07','15:00:00',2);

INSERT INTO "portal_slot" VALUES(487,'2026-12-07','18:00:00',2);

INSERT INTO "portal_slot" VALUES(488,'2026-12-07','21:00:00',2);

INSERT INTO "portal_slot" VALUES(489,'2026-12-08','12:00:00',2);

INSERT INTO "portal_slot" VALUES(490,'2026-12-08','15:00:00',2);

INSERT INTO "portal_slot" VALUES(491,'2026-12-08','18:00:00',2);

INSERT INTO "portal_slot" VALUES(492,'2026-12-08','21:00:00',2);

INSERT INTO "portal_slot" VALUES(493,'2026-12-09','12:00:00',2);

INSERT INTO "portal_slot" VALUES(494,'2026-12-09','15:00:00',2);

INSERT INTO "portal_slot" VALUES(495,'2026-12-09','18:00:00',2);

INSERT INTO "portal_slot" VALUES(496,'2026-12-09','21:00:00',2);

INSERT INTO "portal_slot" VALUES(497,'2026-12-10','12:00:00',2);

INSERT INTO "portal_slot" VALUES(498,'2026-12-10','15:00:00',2);

INSERT INTO "portal_slot" VALUES(499,'2026-12-10','18:00:00',2);

INSERT INTO "portal_slot" VALUES(500,'2026-12-10','21:00:00',2);

INSERT INTO "portal_slot" VALUES(501,'2026-12-11','12:00:00',2);

INSERT INTO "portal_slot" VALUES(502,'2026-12-11','15:00:00',2);

INSERT INTO "portal_slot" VALUES(503,'2026-12-11','18:00:00',2);

INSERT INTO "portal_slot" VALUES(504,'2026-12-11','21:00:00',2);

INSERT INTO "portal_slot" VALUES(505,'2026-12-12','12:00:00',2);

INSERT INTO "portal_slot" VALUES(506,'2026-12-12','15:00:00',2);

INSERT INTO "portal_slot" VALUES(507,'2026-12-12','18:00:00',2);

INSERT INTO "portal_slot" VALUES(508,'2026-12-12','21:00:00',2);

INSERT INTO "portal_slot" VALUES(509,'2026-12-13','12:00:00',2);

INSERT INTO "portal_slot" VALUES(510,'2026-12-13','15:00:00',2);

INSERT INTO "portal_slot" VALUES(511,'2026-12-13','18:00:00',2);

INSERT INTO "portal_slot" VALUES(512,'2026-12-13','21:00:00',2);

INSERT INTO "portal_slot" VALUES(513,'2026-12-14','12:00:00',2);

INSERT INTO "portal_slot" VALUES(514,'2026-12-14','15:00:00',2);

INSERT INTO "portal_slot" VALUES(515,'2026-12-14','18:00:00',2);

INSERT INTO "portal_slot" VALUES(516,'2026-12-14','21:00:00',2);

INSERT INTO "portal_slot" VALUES(517,'2026-12-15','12:00:00',2);

INSERT INTO "portal_slot" VALUES(518,'2026-12-15','15:00:00',2);

INSERT INTO "portal_slot" VALUES(519,'2026-12-15','18:00:00',2);

INSERT INTO "portal_slot" VALUES(520,'2026-12-15','21:00:00',2);

INSERT INTO "portal_slot" VALUES(521,'2026-12-16','12:00:00',2);

INSERT INTO "portal_slot" VALUES(522,'2026-12-16','15:00:00',2);

INSERT INTO "portal_slot" VALUES(523,'2026-12-16','18:00:00',2);

INSERT INTO "portal_slot" VALUES(524,'2026-12-16','21:00:00',2);

INSERT INTO "portal_slot" VALUES(525,'2026-12-17','12:00:00',2);

INSERT INTO "portal_slot" VALUES(526,'2026-12-17','15:00:00',2);

INSERT INTO "portal_slot" VALUES(527,'2026-12-17','18:00:00',2);

INSERT INTO "portal_slot" VALUES(528,'2026-12-17','21:00:00',2);

INSERT INTO "portal_slot" VALUES(529,'2026-12-18','12:00:00',2);

INSERT INTO "portal_slot" VALUES(530,'2026-12-18','15:00:00',2);

INSERT INTO "portal_slot" VALUES(531,'2026-12-18','18:00:00',2);

INSERT INTO "portal_slot" VALUES(532,'2026-12-18','21:00:00',2);

INSERT INTO "portal_slot" VALUES(533,'2026-12-19','12:00:00',2);

INSERT INTO "portal_slot" VALUES(534,'2026-12-19','15:00:00',2);

INSERT INTO "portal_slot" VALUES(535,'2026-12-19','18:00:00',2);

INSERT INTO "portal_slot" VALUES(536,'2026-12-19','21:00:00',2);

INSERT INTO "portal_slot" VALUES(537,'2026-12-20','12:00:00',2);

INSERT INTO "portal_slot" VALUES(538,'2026-12-20','15:00:00',2);

INSERT INTO "portal_slot" VALUES(539,'2026-12-20','18:00:00',2);

INSERT INTO "portal_slot" VALUES(540,'2026-12-20','21:00:00',2);

INSERT INTO "portal_slot" VALUES(541,'2026-12-21','12:00:00',2);

INSERT INTO "portal_slot" VALUES(542,'2026-12-21','15:00:00',2);

INSERT INTO "portal_slot" VALUES(543,'2026-12-21','18:00:00',2);

INSERT INTO "portal_slot" VALUES(544,'2026-12-21','21:00:00',2);

INSERT INTO "portal_slot" VALUES(545,'2026-12-22','12:00:00',2);

INSERT INTO "portal_slot" VALUES(546,'2026-12-22','15:00:00',2);

INSERT INTO "portal_slot" VALUES(547,'2026-12-22','18:00:00',2);

INSERT INTO "portal_slot" VALUES(548,'2026-12-22','21:00:00',2);

INSERT INTO "portal_slot" VALUES(549,'2026-12-23','12:00:00',2);

INSERT INTO "portal_slot" VALUES(550,'2026-12-23','15:00:00',2);

INSERT INTO "portal_slot" VALUES(551,'2026-12-23','18:00:00',2);

INSERT INTO "portal_slot" VALUES(552,'2026-12-23','21:00:00',2);

INSERT INTO "portal_slot" VALUES(553,'2026-12-24','12:00:00',2);

INSERT INTO "portal_slot" VALUES(554,'2026-12-24','15:00:00',2);

INSERT INTO "portal_slot" VALUES(555,'2026-12-24','18:00:00',2);

INSERT INTO "portal_slot" VALUES(556,'2026-12-24','21:00:00',2);

INSERT INTO "portal_slot" VALUES(557,'2026-12-25','12:00:00',2);

INSERT INTO "portal_slot" VALUES(558,'2026-12-25','15:00:00',2);

INSERT INTO "portal_slot" VALUES(559,'2026-12-25','18:00:00',2);

INSERT INTO "portal_slot" VALUES(560,'2026-12-25','21:00:00',2);

INSERT INTO "portal_slot" VALUES(561,'2026-12-26','12:00:00',2);

INSERT INTO "portal_slot" VALUES(562,'2026-12-26','15:00:00',2);

INSERT INTO "portal_slot" VALUES(563,'2026-12-26','18:00:00',2);

INSERT INTO "portal_slot" VALUES(564,'2026-12-26','21:00:00',2);

INSERT INTO "portal_slot" VALUES(565,'2026-12-27','12:00:00',2);

INSERT INTO "portal_slot" VALUES(566,'2026-12-27','15:00:00',2);

INSERT INTO "portal_slot" VALUES(567,'2026-12-27','18:00:00',2);

INSERT INTO "portal_slot" VALUES(568,'2026-12-27','21:00:00',2);

INSERT INTO "portal_slot" VALUES(569,'2026-12-28','12:00:00',2);

INSERT INTO "portal_slot" VALUES(570,'2026-12-28','15:00:00',2);

INSERT INTO "portal_slot" VALUES(571,'2026-12-28','18:00:00',2);

INSERT INTO "portal_slot" VALUES(572,'2026-12-28','21:00:00',2);

INSERT INTO "portal_slot" VALUES(573,'2026-12-29','12:00:00',2);

INSERT INTO "portal_slot" VALUES(574,'2026-12-29','15:00:00',2);

INSERT INTO "portal_slot" VALUES(575,'2026-12-29','18:00:00',2);

INSERT INTO "portal_slot" VALUES(576,'2026-12-29','21:00:00',2);

INSERT INTO "portal_slot" VALUES(577,'2026-12-30','12:00:00',2);

INSERT INTO "portal_slot" VALUES(578,'2026-12-30','15:00:00',2);

INSERT INTO "portal_slot" VALUES(579,'2026-12-30','18:00:00',2);

INSERT INTO "portal_slot" VALUES(580,'2026-12-30','21:00:00',2);

INSERT INTO "portal_slot" VALUES(581,'2026-12-31','12:00:00',2);

INSERT INTO "portal_slot" VALUES(582,'2026-12-31','15:00:00',2);

INSERT INTO "portal_slot" VALUES(583,'2026-12-31','18:00:00',2);

INSERT INTO "portal_slot" VALUES(584,'2026-12-31','21:00:00',2);

INSERT INTO "portal_slot" VALUES(585,'2027-01-01','12:00:00',2);

INSERT INTO "portal_slot" VALUES(586,'2027-01-01','15:00:00',2);

INSERT INTO "portal_slot" VALUES(587,'2027-01-01','18:00:00',2);

INSERT INTO "portal_slot" VALUES(588,'2027-01-01','21:00:00',2);

INSERT INTO "portal_slot" VALUES(589,'2027-01-02','12:00:00',2);

INSERT INTO "portal_slot" VALUES(590,'2027-01-02','15:00:00',2);

INSERT INTO "portal_slot" VALUES(591,'2027-01-02','18:00:00',2);

INSERT INTO "portal_slot" VALUES(592,'2027-01-02','21:00:00',2);

INSERT INTO "portal_slot" VALUES(593,'2027-01-03','12:00:00',2);

INSERT INTO "portal_slot" VALUES(594,'2027-01-03','15:00:00',2);

INSERT INTO "portal_slot" VALUES(595,'2027-01-03','18:00:00',2);

INSERT INTO "portal_slot" VALUES(596,'2027-01-03','21:00:00',2);

INSERT INTO "portal_slot" VALUES(597,'2027-01-04','12:00:00',2);

INSERT INTO "portal_slot" VALUES(598,'2027-01-04','15:00:00',2);

INSERT INTO "portal_slot" VALUES(599,'2027-01-04','18:00:00',2);

INSERT INTO "portal_slot" VALUES(600,'2027-01-04','21:00:00',2);

INSERT INTO "portal_slot" VALUES(601,'2027-01-05','12:00:00',2);

INSERT INTO "portal_slot" VALUES(602,'2027-01-05','15:00:00',2);

INSERT INTO "portal_slot" VALUES(603,'2027-01-05','18:00:00',2);

INSERT INTO "portal_slot" VALUES(604,'2027-01-05','21:00:00',2);

INSERT INTO "portal_slot" VALUES(605,'2027-01-06','12:00:00',2);

INSERT INTO "portal_slot" VALUES(606,'2027-01-06','15:00:00',2);

INSERT INTO "portal_slot" VALUES(607,'2027-01-06','18:00:00',2);

INSERT INTO "portal_slot" VALUES(608,'2027-01-06','21:00:00',2);

INSERT INTO "portal_slot" VALUES(609,'2027-01-07','12:00:00',2);

INSERT INTO "portal_slot" VALUES(610,'2027-01-07','15:00:00',2);

INSERT INTO "portal_slot" VALUES(611,'2027-01-07','18:00:00',2);

INSERT INTO "portal_slot" VALUES(612,'2027-01-07','21:00:00',2);

INSERT INTO "portal_slot" VALUES(613,'2027-01-08','12:00:00',2);

INSERT INTO "portal_slot" VALUES(614,'2027-01-08','15:00:00',2);

INSERT INTO "portal_slot" VALUES(615,'2027-01-08','18:00:00',2);

INSERT INTO "portal_slot" VALUES(616,'2027-01-08','21:00:00',2);

INSERT INTO "portal_slot" VALUES(617,'2026-10-24','12:00:00',3);

INSERT INTO "portal_slot" VALUES(618,'2026-10-24','15:00:00',3);

INSERT INTO "portal_slot" VALUES(619,'2026-10-24','18:00:00',3);

INSERT INTO "portal_slot" VALUES(620,'2026-10-24','21:00:00',3);

INSERT INTO "portal_slot" VALUES(621,'2026-10-25','12:00:00',3);

INSERT INTO "portal_slot" VALUES(622,'2026-10-25','15:00:00',3);

INSERT INTO "portal_slot" VALUES(623,'2026-10-25','18:00:00',3);

INSERT INTO "portal_slot" VALUES(624,'2026-10-25','21:00:00',3);

INSERT INTO "portal_slot" VALUES(625,'2026-10-26','12:00:00',3);

INSERT INTO "portal_slot" VALUES(626,'2026-10-26','15:00:00',3);

INSERT INTO "portal_slot" VALUES(627,'2026-10-26','18:00:00',3);

INSERT INTO "portal_slot" VALUES(628,'2026-10-26','21:00:00',3);

INSERT INTO "portal_slot" VALUES(629,'2026-10-27','12:00:00',3);

INSERT INTO "portal_slot" VALUES(630,'2026-10-27','15:00:00',3);

INSERT INTO "portal_slot" VALUES(631,'2026-10-27','18:00:00',3);

INSERT INTO "portal_slot" VALUES(632,'2026-10-27','21:00:00',3);

INSERT INTO "portal_slot" VALUES(633,'2026-10-28','12:00:00',3);

INSERT INTO "portal_slot" VALUES(634,'2026-10-28','15:00:00',3);

INSERT INTO "portal_slot" VALUES(635,'2026-10-28','18:00:00',3);

INSERT INTO "portal_slot" VALUES(636,'2026-10-28','21:00:00',3);

INSERT INTO "portal_slot" VALUES(637,'2026-10-29','12:00:00',3);

INSERT INTO "portal_slot" VALUES(638,'2026-10-29','15:00:00',3);

INSERT INTO "portal_slot" VALUES(639,'2026-10-29','18:00:00',3);

INSERT INTO "portal_slot" VALUES(640,'2026-10-29','21:00:00',3);

INSERT INTO "portal_slot" VALUES(641,'2026-10-30','12:00:00',3);

INSERT INTO "portal_slot" VALUES(642,'2026-10-30','15:00:00',3);

INSERT INTO "portal_slot" VALUES(643,'2026-10-30','18:00:00',3);

INSERT INTO "portal_slot" VALUES(644,'2026-10-30','21:00:00',3);

INSERT INTO "portal_slot" VALUES(645,'2026-10-31','12:00:00',3);

INSERT INTO "portal_slot" VALUES(646,'2026-10-31','15:00:00',3);

INSERT INTO "portal_slot" VALUES(647,'2026-10-31','18:00:00',3);

INSERT INTO "portal_slot" VALUES(648,'2026-10-31','21:00:00',3);

INSERT INTO "portal_slot" VALUES(649,'2026-11-01','12:00:00',3);

INSERT INTO "portal_slot" VALUES(650,'2026-11-01','15:00:00',3);

INSERT INTO "portal_slot" VALUES(651,'2026-11-01','18:00:00',3);

INSERT INTO "portal_slot" VALUES(652,'2026-11-01','21:00:00',3);

INSERT INTO "portal_slot" VALUES(653,'2026-11-02','12:00:00',3);

INSERT INTO "portal_slot" VALUES(654,'2026-11-02','15:00:00',3);

INSERT INTO "portal_slot" VALUES(655,'2026-11-02','18:00:00',3);

INSERT INTO "portal_slot" VALUES(656,'2026-11-02','21:00:00',3);

INSERT INTO "portal_slot" VALUES(657,'2026-11-03','12:00:00',3);

INSERT INTO "portal_slot" VALUES(658,'2026-11-03','15:00:00',3);

INSERT INTO "portal_slot" VALUES(659,'2026-11-03','18:00:00',3);

INSERT INTO "portal_slot" VALUES(660,'2026-11-03','21:00:00',3);

INSERT INTO "portal_slot" VALUES(661,'2026-11-04','12:00:00',3);

INSERT INTO "portal_slot" VALUES(662,'2026-11-04','15:00:00',3);

INSERT INTO "portal_slot" VALUES(663,'2026-11-04','18:00:00',3);

INSERT INTO "portal_slot" VALUES(664,'2026-11-04','21:00:00',3);

INSERT INTO "portal_slot" VALUES(665,'2026-11-05','12:00:00',3);

INSERT INTO "portal_slot" VALUES(666,'2026-11-05','15:00:00',3);

INSERT INTO "portal_slot" VALUES(667,'2026-11-05','18:00:00',3);

INSERT INTO "portal_slot" VALUES(668,'2026-11-05','21:00:00',3);

INSERT INTO "portal_slot" VALUES(669,'2026-11-06','12:00:00',3);

INSERT INTO "portal_slot" VALUES(670,'2026-11-06','15:00:00',3);

INSERT INTO "portal_slot" VALUES(671,'2026-11-06','18:00:00',3);

INSERT INTO "portal_slot" VALUES(672,'2026-11-06','21:00:00',3);

INSERT INTO "portal_slot" VALUES(673,'2026-11-07','12:00:00',3);

INSERT INTO "portal_slot" VALUES(674,'2026-11-07','15:00:00',3);

INSERT INTO "portal_slot" VALUES(675,'2026-11-07','18:00:00',3);

INSERT INTO "portal_slot" VALUES(676,'2026-11-07','21:00:00',3);

INSERT INTO "portal_slot" VALUES(677,'2026-11-08','12:00:00',3);

INSERT INTO "portal_slot" VALUES(678,'2026-11-08','15:00:00',3);

INSERT INTO "portal_slot" VALUES(679,'2026-11-08','18:00:00',3);

INSERT INTO "portal_slot" VALUES(680,'2026-11-08','21:00:00',3);

INSERT INTO "portal_slot" VALUES(681,'2026-11-09','12:00:00',3);

INSERT INTO "portal_slot" VALUES(682,'2026-11-09','15:00:00',3);

INSERT INTO "portal_slot" VALUES(683,'2026-11-09','18:00:00',3);

INSERT INTO "portal_slot" VALUES(684,'2026-11-09','21:00:00',3);

INSERT INTO "portal_slot" VALUES(685,'2026-11-10','12:00:00',3);

INSERT INTO "portal_slot" VALUES(686,'2026-11-10','15:00:00',3);

INSERT INTO "portal_slot" VALUES(687,'2026-11-10','18:00:00',3);

INSERT INTO "portal_slot" VALUES(688,'2026-11-10','21:00:00',3);

INSERT INTO "portal_slot" VALUES(689,'2026-11-11','12:00:00',3);

INSERT INTO "portal_slot" VALUES(690,'2026-11-11','15:00:00',3);

INSERT INTO "portal_slot" VALUES(691,'2026-11-11','18:00:00',3);

INSERT INTO "portal_slot" VALUES(692,'2026-11-11','21:00:00',3);

INSERT INTO "portal_slot" VALUES(693,'2026-11-12','12:00:00',3);

INSERT INTO "portal_slot" VALUES(694,'2026-11-12','15:00:00',3);

INSERT INTO "portal_slot" VALUES(695,'2026-11-12','18:00:00',3);

INSERT INTO "portal_slot" VALUES(696,'2026-11-12','21:00:00',3);

INSERT INTO "portal_slot" VALUES(697,'2026-11-13','12:00:00',3);

INSERT INTO "portal_slot" VALUES(698,'2026-11-13','15:00:00',3);

INSERT INTO "portal_slot" VALUES(699,'2026-11-13','18:00:00',3);

INSERT INTO "portal_slot" VALUES(700,'2026-11-13','21:00:00',3);

INSERT INTO "portal_slot" VALUES(701,'2026-11-14','12:00:00',3);

INSERT INTO "portal_slot" VALUES(702,'2026-11-14','15:00:00',3);

INSERT INTO "portal_slot" VALUES(703,'2026-11-14','18:00:00',3);

INSERT INTO "portal_slot" VALUES(704,'2026-11-14','21:00:00',3);

INSERT INTO "portal_slot" VALUES(705,'2026-11-15','12:00:00',3);

INSERT INTO "portal_slot" VALUES(706,'2026-11-15','15:00:00',3);

INSERT INTO "portal_slot" VALUES(707,'2026-11-15','18:00:00',3);

INSERT INTO "portal_slot" VALUES(708,'2026-11-15','21:00:00',3);

INSERT INTO "portal_slot" VALUES(709,'2026-11-16','12:00:00',3);

INSERT INTO "portal_slot" VALUES(710,'2026-11-16','15:00:00',3);

INSERT INTO "portal_slot" VALUES(711,'2026-11-16','18:00:00',3);

INSERT INTO "portal_slot" VALUES(712,'2026-11-16','21:00:00',3);

INSERT INTO "portal_slot" VALUES(713,'2026-11-17','12:00:00',3);

INSERT INTO "portal_slot" VALUES(714,'2026-11-17','15:00:00',3);

INSERT INTO "portal_slot" VALUES(715,'2026-11-17','18:00:00',3);

INSERT INTO "portal_slot" VALUES(716,'2026-11-17','21:00:00',3);

INSERT INTO "portal_slot" VALUES(717,'2026-11-18','12:00:00',3);

INSERT INTO "portal_slot" VALUES(718,'2026-11-18','15:00:00',3);

INSERT INTO "portal_slot" VALUES(719,'2026-11-18','18:00:00',3);

INSERT INTO "portal_slot" VALUES(720,'2026-11-18','21:00:00',3);

INSERT INTO "portal_slot" VALUES(721,'2026-11-19','12:00:00',3);

INSERT INTO "portal_slot" VALUES(722,'2026-11-19','15:00:00',3);

INSERT INTO "portal_slot" VALUES(723,'2026-11-19','18:00:00',3);

INSERT INTO "portal_slot" VALUES(724,'2026-11-19','21:00:00',3);

INSERT INTO "portal_slot" VALUES(725,'2026-11-20','12:00:00',3);

INSERT INTO "portal_slot" VALUES(726,'2026-11-20','15:00:00',3);

INSERT INTO "portal_slot" VALUES(727,'2026-11-20','18:00:00',3);

INSERT INTO "portal_slot" VALUES(728,'2026-11-20','21:00:00',3);

INSERT INTO "portal_slot" VALUES(729,'2026-11-21','12:00:00',3);

INSERT INTO "portal_slot" VALUES(730,'2026-11-21','15:00:00',3);

INSERT INTO "portal_slot" VALUES(731,'2026-11-21','18:00:00',3);

INSERT INTO "portal_slot" VALUES(732,'2026-11-21','21:00:00',3);

INSERT INTO "portal_slot" VALUES(733,'2026-11-22','12:00:00',3);

INSERT INTO "portal_slot" VALUES(734,'2026-11-22','15:00:00',3);

INSERT INTO "portal_slot" VALUES(735,'2026-11-22','18:00:00',3);

INSERT INTO "portal_slot" VALUES(736,'2026-11-22','21:00:00',3);

INSERT INTO "portal_slot" VALUES(737,'2026-11-23','12:00:00',3);

INSERT INTO "portal_slot" VALUES(738,'2026-11-23','15:00:00',3);

INSERT INTO "portal_slot" VALUES(739,'2026-11-23','18:00:00',3);

INSERT INTO "portal_slot" VALUES(740,'2026-11-23','21:00:00',3);

INSERT INTO "portal_slot" VALUES(741,'2026-11-24','12:00:00',3);

INSERT INTO "portal_slot" VALUES(742,'2026-11-24','15:00:00',3);

INSERT INTO "portal_slot" VALUES(743,'2026-11-24','18:00:00',3);

INSERT INTO "portal_slot" VALUES(744,'2026-11-24','21:00:00',3);

INSERT INTO "portal_slot" VALUES(745,'2026-11-25','12:00:00',3);

INSERT INTO "portal_slot" VALUES(746,'2026-11-25','15:00:00',3);

INSERT INTO "portal_slot" VALUES(747,'2026-11-25','18:00:00',3);

INSERT INTO "portal_slot" VALUES(748,'2026-11-25','21:00:00',3);

INSERT INTO "portal_slot" VALUES(749,'2026-11-26','12:00:00',3);

INSERT INTO "portal_slot" VALUES(750,'2026-11-26','15:00:00',3);

INSERT INTO "portal_slot" VALUES(751,'2026-11-26','18:00:00',3);

INSERT INTO "portal_slot" VALUES(752,'2026-11-26','21:00:00',3);

INSERT INTO "portal_slot" VALUES(753,'2026-11-27','12:00:00',3);

INSERT INTO "portal_slot" VALUES(754,'2026-11-27','15:00:00',3);

INSERT INTO "portal_slot" VALUES(755,'2026-11-27','18:00:00',3);

INSERT INTO "portal_slot" VALUES(756,'2026-11-27','21:00:00',3);

INSERT INTO "portal_slot" VALUES(757,'2026-11-28','12:00:00',3);

INSERT INTO "portal_slot" VALUES(758,'2026-11-28','15:00:00',3);

INSERT INTO "portal_slot" VALUES(759,'2026-11-28','18:00:00',3);

INSERT INTO "portal_slot" VALUES(760,'2026-11-28','21:00:00',3);

INSERT INTO "portal_slot" VALUES(761,'2026-11-29','12:00:00',3);

INSERT INTO "portal_slot" VALUES(762,'2026-11-29','15:00:00',3);

INSERT INTO "portal_slot" VALUES(763,'2026-11-29','18:00:00',3);

INSERT INTO "portal_slot" VALUES(764,'2026-11-29','21:00:00',3);

INSERT INTO "portal_slot" VALUES(765,'2026-11-30','12:00:00',3);

INSERT INTO "portal_slot" VALUES(766,'2026-11-30','15:00:00',3);

INSERT INTO "portal_slot" VALUES(767,'2026-11-30','18:00:00',3);

INSERT INTO "portal_slot" VALUES(768,'2026-11-30','21:00:00',3);

INSERT INTO "portal_slot" VALUES(769,'2026-12-01','12:00:00',3);

INSERT INTO "portal_slot" VALUES(770,'2026-12-01','15:00:00',3);

INSERT INTO "portal_slot" VALUES(771,'2026-12-01','18:00:00',3);

INSERT INTO "portal_slot" VALUES(772,'2026-12-01','21:00:00',3);

INSERT INTO "portal_slot" VALUES(773,'2026-12-02','12:00:00',3);

INSERT INTO "portal_slot" VALUES(774,'2026-12-02','15:00:00',3);

INSERT INTO "portal_slot" VALUES(775,'2026-12-02','18:00:00',3);

INSERT INTO "portal_slot" VALUES(776,'2026-12-02','21:00:00',3);

INSERT INTO "portal_slot" VALUES(777,'2026-12-03','12:00:00',3);

INSERT INTO "portal_slot" VALUES(778,'2026-12-03','15:00:00',3);

INSERT INTO "portal_slot" VALUES(779,'2026-12-03','18:00:00',3);

INSERT INTO "portal_slot" VALUES(780,'2026-12-03','21:00:00',3);

INSERT INTO "portal_slot" VALUES(781,'2026-12-04','12:00:00',3);

INSERT INTO "portal_slot" VALUES(782,'2026-12-04','15:00:00',3);

INSERT INTO "portal_slot" VALUES(783,'2026-12-04','18:00:00',3);

INSERT INTO "portal_slot" VALUES(784,'2026-12-04','21:00:00',3);

INSERT INTO "portal_slot" VALUES(785,'2026-12-05','12:00:00',3);

INSERT INTO "portal_slot" VALUES(786,'2026-12-05','15:00:00',3);

INSERT INTO "portal_slot" VALUES(787,'2026-12-05','18:00:00',3);

INSERT INTO "portal_slot" VALUES(788,'2026-12-05','21:00:00',3);

INSERT INTO "portal_slot" VALUES(789,'2026-12-06','12:00:00',3);

INSERT INTO "portal_slot" VALUES(790,'2026-12-06','15:00:00',3);

INSERT INTO "portal_slot" VALUES(791,'2026-12-06','18:00:00',3);

INSERT INTO "portal_slot" VALUES(792,'2026-12-06','21:00:00',3);

INSERT INTO "portal_slot" VALUES(793,'2026-12-07','12:00:00',3);

INSERT INTO "portal_slot" VALUES(794,'2026-12-07','15:00:00',3);

INSERT INTO "portal_slot" VALUES(795,'2026-12-07','18:00:00',3);

INSERT INTO "portal_slot" VALUES(796,'2026-12-07','21:00:00',3);

INSERT INTO "portal_slot" VALUES(797,'2026-12-08','12:00:00',3);

INSERT INTO "portal_slot" VALUES(798,'2026-12-08','15:00:00',3);

INSERT INTO "portal_slot" VALUES(799,'2026-12-08','18:00:00',3);

INSERT INTO "portal_slot" VALUES(800,'2026-12-08','21:00:00',3);

INSERT INTO "portal_slot" VALUES(801,'2026-12-09','12:00:00',3);

INSERT INTO "portal_slot" VALUES(802,'2026-12-09','15:00:00',3);

INSERT INTO "portal_slot" VALUES(803,'2026-12-09','18:00:00',3);

INSERT INTO "portal_slot" VALUES(804,'2026-12-09','21:00:00',3);

INSERT INTO "portal_slot" VALUES(805,'2026-12-10','12:00:00',3);

INSERT INTO "portal_slot" VALUES(806,'2026-12-10','15:00:00',3);

INSERT INTO "portal_slot" VALUES(807,'2026-12-10','18:00:00',3);

INSERT INTO "portal_slot" VALUES(808,'2026-12-10','21:00:00',3);

INSERT INTO "portal_slot" VALUES(809,'2026-12-11','12:00:00',3);

INSERT INTO "portal_slot" VALUES(810,'2026-12-11','15:00:00',3);

INSERT INTO "portal_slot" VALUES(811,'2026-12-11','18:00:00',3);

INSERT INTO "portal_slot" VALUES(812,'2026-12-11','21:00:00',3);

INSERT INTO "portal_slot" VALUES(813,'2026-12-12','12:00:00',3);

INSERT INTO "portal_slot" VALUES(814,'2026-12-12','15:00:00',3);

INSERT INTO "portal_slot" VALUES(815,'2026-12-12','18:00:00',3);

INSERT INTO "portal_slot" VALUES(816,'2026-12-12','21:00:00',3);

INSERT INTO "portal_slot" VALUES(817,'2026-12-13','12:00:00',3);

INSERT INTO "portal_slot" VALUES(818,'2026-12-13','15:00:00',3);

INSERT INTO "portal_slot" VALUES(819,'2026-12-13','18:00:00',3);

INSERT INTO "portal_slot" VALUES(820,'2026-12-13','21:00:00',3);

INSERT INTO "portal_slot" VALUES(821,'2026-12-14','12:00:00',3);

INSERT INTO "portal_slot" VALUES(822,'2026-12-14','15:00:00',3);

INSERT INTO "portal_slot" VALUES(823,'2026-12-14','18:00:00',3);

INSERT INTO "portal_slot" VALUES(824,'2026-12-14','21:00:00',3);

INSERT INTO "portal_slot" VALUES(825,'2026-12-15','12:00:00',3);

INSERT INTO "portal_slot" VALUES(826,'2026-12-15','15:00:00',3);

INSERT INTO "portal_slot" VALUES(827,'2026-12-15','18:00:00',3);

INSERT INTO "portal_slot" VALUES(828,'2026-12-15','21:00:00',3);

INSERT INTO "portal_slot" VALUES(829,'2026-12-16','12:00:00',3);

INSERT INTO "portal_slot" VALUES(830,'2026-12-16','15:00:00',3);

INSERT INTO "portal_slot" VALUES(831,'2026-12-16','18:00:00',3);

INSERT INTO "portal_slot" VALUES(832,'2026-12-16','21:00:00',3);

INSERT INTO "portal_slot" VALUES(833,'2026-12-17','12:00:00',3);

INSERT INTO "portal_slot" VALUES(834,'2026-12-17','15:00:00',3);

INSERT INTO "portal_slot" VALUES(835,'2026-12-17','18:00:00',3);

INSERT INTO "portal_slot" VALUES(836,'2026-12-17','21:00:00',3);

INSERT INTO "portal_slot" VALUES(837,'2026-12-18','12:00:00',3);

INSERT INTO "portal_slot" VALUES(838,'2026-12-18','15:00:00',3);

INSERT INTO "portal_slot" VALUES(839,'2026-12-18','18:00:00',3);

INSERT INTO "portal_slot" VALUES(840,'2026-12-18','21:00:00',3);

INSERT INTO "portal_slot" VALUES(841,'2026-12-19','12:00:00',3);

INSERT INTO "portal_slot" VALUES(842,'2026-12-19','15:00:00',3);

INSERT INTO "portal_slot" VALUES(843,'2026-12-19','18:00:00',3);

INSERT INTO "portal_slot" VALUES(844,'2026-12-19','21:00:00',3);

INSERT INTO "portal_slot" VALUES(845,'2026-12-20','12:00:00',3);

INSERT INTO "portal_slot" VALUES(846,'2026-12-20','15:00:00',3);

INSERT INTO "portal_slot" VALUES(847,'2026-12-20','18:00:00',3);

INSERT INTO "portal_slot" VALUES(848,'2026-12-20','21:00:00',3);

INSERT INTO "portal_slot" VALUES(849,'2026-12-21','12:00:00',3);

INSERT INTO "portal_slot" VALUES(850,'2026-12-21','15:00:00',3);

INSERT INTO "portal_slot" VALUES(851,'2026-12-21','18:00:00',3);

INSERT INTO "portal_slot" VALUES(852,'2026-12-21','21:00:00',3);

INSERT INTO "portal_slot" VALUES(853,'2026-12-22','12:00:00',3);

INSERT INTO "portal_slot" VALUES(854,'2026-12-22','15:00:00',3);

INSERT INTO "portal_slot" VALUES(855,'2026-12-22','18:00:00',3);

INSERT INTO "portal_slot" VALUES(856,'2026-12-22','21:00:00',3);

INSERT INTO "portal_slot" VALUES(857,'2026-12-23','12:00:00',3);

INSERT INTO "portal_slot" VALUES(858,'2026-12-23','15:00:00',3);

INSERT INTO "portal_slot" VALUES(859,'2026-12-23','18:00:00',3);

INSERT INTO "portal_slot" VALUES(860,'2026-12-23','21:00:00',3);

INSERT INTO "portal_slot" VALUES(861,'2026-12-24','12:00:00',3);

INSERT INTO "portal_slot" VALUES(862,'2026-12-24','15:00:00',3);

INSERT INTO "portal_slot" VALUES(863,'2026-12-24','18:00:00',3);

INSERT INTO "portal_slot" VALUES(864,'2026-12-24','21:00:00',3);

INSERT INTO "portal_slot" VALUES(865,'2026-12-25','12:00:00',3);

INSERT INTO "portal_slot" VALUES(866,'2026-12-25','15:00:00',3);

INSERT INTO "portal_slot" VALUES(867,'2026-12-25','18:00:00',3);

INSERT INTO "portal_slot" VALUES(868,'2026-12-25','21:00:00',3);

INSERT INTO "portal_slot" VALUES(869,'2026-12-26','12:00:00',3);

INSERT INTO "portal_slot" VALUES(870,'2026-12-26','15:00:00',3);

INSERT INTO "portal_slot" VALUES(871,'2026-12-26','18:00:00',3);

INSERT INTO "portal_slot" VALUES(872,'2026-12-26','21:00:00',3);

INSERT INTO "portal_slot" VALUES(873,'2026-12-27','12:00:00',3);

INSERT INTO "portal_slot" VALUES(874,'2026-12-27','15:00:00',3);

INSERT INTO "portal_slot" VALUES(875,'2026-12-27','18:00:00',3);

INSERT INTO "portal_slot" VALUES(876,'2026-12-27','21:00:00',3);

INSERT INTO "portal_slot" VALUES(877,'2026-12-28','12:00:00',3);

INSERT INTO "portal_slot" VALUES(878,'2026-12-28','15:00:00',3);

INSERT INTO "portal_slot" VALUES(879,'2026-12-28','18:00:00',3);

INSERT INTO "portal_slot" VALUES(880,'2026-12-28','21:00:00',3);

INSERT INTO "portal_slot" VALUES(881,'2026-12-29','12:00:00',3);

INSERT INTO "portal_slot" VALUES(882,'2026-12-29','15:00:00',3);

INSERT INTO "portal_slot" VALUES(883,'2026-12-29','18:00:00',3);

INSERT INTO "portal_slot" VALUES(884,'2026-12-29','21:00:00',3);

INSERT INTO "portal_slot" VALUES(885,'2026-12-30','12:00:00',3);

INSERT INTO "portal_slot" VALUES(886,'2026-12-30','15:00:00',3);

INSERT INTO "portal_slot" VALUES(887,'2026-12-30','18:00:00',3);

INSERT INTO "portal_slot" VALUES(888,'2026-12-30','21:00:00',3);

INSERT INTO "portal_slot" VALUES(889,'2026-12-31','12:00:00',3);

INSERT INTO "portal_slot" VALUES(890,'2026-12-31','15:00:00',3);

INSERT INTO "portal_slot" VALUES(891,'2026-12-31','18:00:00',3);

INSERT INTO "portal_slot" VALUES(892,'2026-12-31','21:00:00',3);

INSERT INTO "portal_slot" VALUES(893,'2027-01-01','12:00:00',3);

INSERT INTO "portal_slot" VALUES(894,'2027-01-01','15:00:00',3);

INSERT INTO "portal_slot" VALUES(895,'2027-01-01','18:00:00',3);

INSERT INTO "portal_slot" VALUES(896,'2027-01-01','21:00:00',3);

INSERT INTO "portal_slot" VALUES(897,'2027-01-02','12:00:00',3);

INSERT INTO "portal_slot" VALUES(898,'2027-01-02','15:00:00',3);

INSERT INTO "portal_slot" VALUES(899,'2027-01-02','18:00:00',3);

INSERT INTO "portal_slot" VALUES(900,'2027-01-02','21:00:00',3);

INSERT INTO "portal_slot" VALUES(901,'2027-01-03','12:00:00',3);

INSERT INTO "portal_slot" VALUES(902,'2027-01-03','15:00:00',3);

INSERT INTO "portal_slot" VALUES(903,'2027-01-03','18:00:00',3);

INSERT INTO "portal_slot" VALUES(904,'2027-01-03','21:00:00',3);

INSERT INTO "portal_slot" VALUES(905,'2027-01-04','12:00:00',3);

INSERT INTO "portal_slot" VALUES(906,'2027-01-04','15:00:00',3);

INSERT INTO "portal_slot" VALUES(907,'2027-01-04','18:00:00',3);

INSERT INTO "portal_slot" VALUES(908,'2027-01-04','21:00:00',3);

INSERT INTO "portal_slot" VALUES(909,'2027-01-05','12:00:00',3);

INSERT INTO "portal_slot" VALUES(910,'2027-01-05','15:00:00',3);

INSERT INTO "portal_slot" VALUES(911,'2027-01-05','18:00:00',3);

INSERT INTO "portal_slot" VALUES(912,'2027-01-05','21:00:00',3);

INSERT INTO "portal_slot" VALUES(913,'2027-01-06','12:00:00',3);

INSERT INTO "portal_slot" VALUES(914,'2027-01-06','15:00:00',3);

INSERT INTO "portal_slot" VALUES(915,'2027-01-06','18:00:00',3);

INSERT INTO "portal_slot" VALUES(916,'2027-01-06','21:00:00',3);

INSERT INTO "portal_slot" VALUES(917,'2027-01-07','12:00:00',3);

INSERT INTO "portal_slot" VALUES(918,'2027-01-07','15:00:00',3);

INSERT INTO "portal_slot" VALUES(919,'2027-01-07','18:00:00',3);

INSERT INTO "portal_slot" VALUES(920,'2027-01-07','21:00:00',3);

INSERT INTO "portal_slot" VALUES(921,'2027-01-08','12:00:00',3);

INSERT INTO "portal_slot" VALUES(922,'2027-01-08','15:00:00',3);

INSERT INTO "portal_slot" VALUES(923,'2027-01-08','18:00:00',3);

INSERT INTO "portal_slot" VALUES(924,'2027-01-08','21:00:00',3);

INSERT INTO "portal_submission" VALUES(1,'finished','2026-11-08 22:25:21.424187',2,'cash','',3,3,1);

INSERT INTO "portal_submission" VALUES(2,'finished','2026-11-08 22:25:21.425197',3,'card','',4,311,4);

INSERT INTO "portal_submission" VALUES(3,'finished','2026-11-08 22:25:21.426214',4,'cash','',5,619,7);

INSERT INTO "portal_submission" VALUES(4,'finished','2026-11-08 22:25:21.427222',5,'card','',6,7,2);

INSERT INTO "portal_submission" VALUES(5,'finished','2026-11-08 22:25:21.428229',6,'cash','',7,315,5);

INSERT INTO "portal_submission" VALUES(6,'finished','2026-11-08 22:25:21.429236',2,'card','',3,623,8);

INSERT INTO "portal_submission" VALUES(7,'pending','2026-11-08 22:25:21.430265',3,'cash','',4,11,3);

INSERT INTO "portal_submission" VALUES(8,'confirmed','2026-11-08 22:25:21.430265',4,'card','',5,319,6);

INSERT INTO "portal_submission" VALUES(9,'cancelled','2026-11-08 22:25:21.431272',5,'cash','Команда попросила перенести посещение.',6,627,9);

INSERT INTO "portal_submission" VALUES(10,'finished','2026-11-08 22:25:21.432659',6,'card','',7,15,1);

INSERT INTO "portal_submission" VALUES(11,'pending','2026-11-08 22:25:21.433165',2,'cash','',3,323,4);

INSERT INTO "portal_submission" VALUES(12,'confirmed','2026-11-08 22:25:21.434179',3,'card','',4,631,7);

INSERT INTO "portal_submission" VALUES(13,'cancelled','2026-11-08 22:25:21.434179',4,'cash','Команда попросила перенести посещение.',5,19,2);

INSERT INTO "portal_submission" VALUES(14,'finished','2026-11-08 22:25:21.435241',5,'card','',6,327,5);

INSERT INTO "portal_submission" VALUES(15,'pending','2026-11-08 22:25:21.436248',6,'cash','',7,635,8);

INSERT INTO "portal_submission" VALUES(16,'confirmed','2026-11-08 22:25:21.437255',2,'card','',2,23,3);

INSERT INTO "portal_submission" VALUES(17,'cancelled','2026-11-08 22:25:21.437255',3,'cash','Команда попросила перенести посещение.',2,331,6);

INSERT INTO "portal_submission" VALUES(18,'finished','2026-11-08 22:25:21.438262',4,'card','',2,639,9);

INSERT INTO "portal_submission" VALUES(19,'pending','2026-11-08 22:25:21.439274',5,'cash','',2,27,1);

INSERT INTO "portal_submission" VALUES(20,'finished','2026-11-08 22:25:21.440281',6,'card','',2,335,4);

INSERT INTO "portal_variation" VALUES(1,'Стандартный',1,1);

INSERT INTO "portal_variation" VALUES(2,'С актерами',1,1);

INSERT INTO "portal_variation" VALUES(3,'Ночной режим',1,1);

INSERT INTO "portal_variation" VALUES(4,'Стандартный',1,2);

INSERT INTO "portal_variation" VALUES(5,'С актерами',1,2);

INSERT INTO "portal_variation" VALUES(6,'Ночной режим',1,2);

INSERT INTO "portal_variation" VALUES(7,'Стандартный',1,3);

INSERT INTO "portal_variation" VALUES(8,'С актерами',1,3);

INSERT INTO "portal_variation" VALUES(9,'Ночной режим',1,3);

CREATE UNIQUE INDEX "unique_login_casefold" ON "portal_member" ((LOWER("login")));

CREATE INDEX "portal_slot_quest_id_87983f35" ON "portal_slot" ("quest_id");

CREATE INDEX "portal_variation_quest_id_8dbcc9ed" ON "portal_variation" ("quest_id");

CREATE UNIQUE INDEX "one_booking_per_live_slot" ON "portal_submission" ("slot_id") WHERE NOT ("status" = 'cancelled');

CREATE INDEX "portal_submission_owner_id_53705f1c" ON "portal_submission" ("owner_id");

CREATE INDEX "portal_submission_slot_id_6598a364" ON "portal_submission" ("slot_id");

CREATE INDEX "portal_submission_variation_id_7115db1d" ON "portal_submission" ("variation_id");

COMMIT;
