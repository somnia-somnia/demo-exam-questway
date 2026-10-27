CREATE TABLE "portal_quest" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(120) NOT NULL UNIQUE, "summary" varchar(300) NOT NULL, "active" bool NOT NULL);

CREATE TABLE "portal_member" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "login" varchar(64) NOT NULL UNIQUE, "password" varchar(128) NOT NULL, "full_name" varchar(150) NOT NULL, "phone" varchar(16) NOT NULL, "email" varchar(254) NOT NULL, "is_admin" bool NOT NULL);

CREATE TABLE "portal_review" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "body" varchar(600) NOT NULL, "created_at" datetime NOT NULL, "submission_id" bigint NOT NULL UNIQUE REFERENCES "portal_submission" ("id") DEFERRABLE INITIALLY DEFERRED);

CREATE TABLE "portal_slot" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "day" date NOT NULL, "time" time NOT NULL, "quest_id" bigint NOT NULL REFERENCES "portal_quest" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "unique_quest_time" UNIQUE ("quest_id", "day", "time"));

CREATE TABLE "portal_variation" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(80) NOT NULL, "active" bool NOT NULL, "quest_id" bigint NOT NULL REFERENCES "portal_quest" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "unique_variation_name" UNIQUE ("quest_id", "name"));

CREATE TABLE "portal_submission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "status" varchar(16) NOT NULL, "created_at" datetime NOT NULL, "participants" integer unsigned NOT NULL CHECK ("participants" >= 0), "payment" varchar(8) NOT NULL, "reason" varchar(500) NOT NULL, "owner_id" bigint NOT NULL REFERENCES "portal_member" ("id") DEFERRABLE INITIALLY DEFERRED, "slot_id" bigint NOT NULL REFERENCES "portal_slot" ("id") DEFERRABLE INITIALLY DEFERRED, "variation_id" bigint NOT NULL REFERENCES "portal_variation" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "valid_quest_status" CHECK ("status" IN ('pending', 'confirmed', 'cancelled', 'finished')), CONSTRAINT "reason_only_for_cancellation" CHECK ((("status" = 'cancelled' AND NOT ("reason" = '')) OR (NOT ("status" = 'cancelled') AND "reason" = ''))), CONSTRAINT "valid_team_size" CHECK (("participants" >= 1 AND "participants" <= 30)));

CREATE UNIQUE INDEX "unique_login_casefold" ON "portal_member" ((LOWER("login")));

CREATE INDEX "portal_slot_quest_id_87983f35" ON "portal_slot" ("quest_id");

CREATE INDEX "portal_variation_quest_id_8dbcc9ed" ON "portal_variation" ("quest_id");

CREATE UNIQUE INDEX "one_booking_per_live_slot" ON "portal_submission" ("slot_id") WHERE NOT ("status" = 'cancelled');

CREATE INDEX "portal_submission_owner_id_53705f1c" ON "portal_submission" ("owner_id");

CREATE INDEX "portal_submission_slot_id_6598a364" ON "portal_submission" ("slot_id");

CREATE INDEX "portal_submission_variation_id_7115db1d" ON "portal_submission" ("variation_id");
