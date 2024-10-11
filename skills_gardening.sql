CREATE TABLE `skills_gardening` (
	`identifier` VARCHAR(46) NOT NULL COLLATE 'latin1_swedish_ci',
	`experience` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;