-----------------------------------------
------- INSERTING USERS
-----------------------------------------
use dbEMS;
INSERT INTO tb_User VALUES ('general1', 'cr@zyR@bb1t', 'gu1FirstName', 'gu1LastName', 2);
INSERT INTO tb_User VALUES ('general2', 'Sly0ldF0x', 'gu2FirstName', 'gu2LastName', 2);
INSERT INTO tb_User VALUES ('fredAnd', '3th31M3rtz', 'gu3FirstName', 'gu3LastName', 2);
INSERT INTO tb_User VALUES ('admin', 'ems-pss-admin', 'au1FirstName', 'au1LastName', 1);

-----------------------------------------
------- INSERTING COMPANIES
-----------------------------------------
use dbEMS;
insert into tb_Company values ('BlackBerry');
insert into tb_Company values ('Google');
insert into tb_Company values ('MS');

-----------------------------------------
------- INSERTING FULLTIME EMPLOYEE
-----------------------------------------
use dbEMS;
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('FT', 'BlackBerry', 'rachel', 'park', '333333334', '1989-11-19');
insert into tb_FtEmp values (1, '2000-1-1', '2010-1-1', 200000);
GO
/*
use dbEMS;
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('PT', 'Google', 'rachel', 'park', '333333334', '1989-11-19');
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('FT', 'MS', 'rachel', 'Joo', '121212121', '1989-11-19');
GO
*/