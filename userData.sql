CREATE TABLE tb_User (
	userName		VARCHAR(30)		NOT NULL,
	userPassword	VARCHAR(50)		DEFAULT NULL,
	firstName		VARCHAR(30)		DEFAULT NULL,
	lastName		VARCHAR(30)		DEFAULT NULL,
	securityLevel	INT				NOT NULL,		-- 1-admin, 2-general
	PRIMARY KEY(userName),
	UNIQUE(userName, userPassword, firstName, lastName)
);
GO
use dbEMS;
INSERT INTO tb_User VALUES ('general1', 'cr@zyR@bb1t', 'gu1FirstName', 'gu1LastName', 2);
INSERT INTO tb_User VALUES ('general2', 'Sly0ldF0x', 'gu2FirstName', 'gu2LastName', 2);
INSERT INTO tb_User VALUES ('fredAnd', '3th31M3rtz', 'gu3FirstName', 'gu3LastName', 2);
INSERT INTO tb_User VALUES ('admin', 'ems-pps-admin', 'au1FirstName', 'au1LastName', 1);