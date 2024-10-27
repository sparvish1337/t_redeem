CREATE TABLE `redeem_codes` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `code` VARCHAR(255) NOT NULL COLLATE 'utf8mb3_general_ci',
    `items` JSON NOT NULL,
    `uses` INT(11) NOT NULL,
    `redeemed_by` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb4_bin',
    `created_by` VARCHAR(255) NOT NULL COLLATE 'utf8mb3_general_ci',
    `created_at` TIMESTAMP NULL DEFAULT current_timestamp(),
    `expiry` DATETIME NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `code` (`code`) USING BTREE,
    CONSTRAINT `redeemed_by` CHECK (json_valid(`redeemed_by`)),
    CONSTRAINT `items` CHECK (json_valid(`items`))
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=4;
