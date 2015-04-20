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
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('FT', 'BlackBerry', 'rachel', 'park', '333333334', '1989-11-19', 1);
insert into tb_FtEmp values (1, '2000-1-1', '2010-1-1', 200000);

insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('SL', 'MS', 'jo', 'chang', '1212121', '1989-11-19', 1);
insert into tb_SlEmp values (2, 'FALL', 2010, '2010-9-1', 9999.99);

insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('SL', 'MS', 'jo', 'chang', '1212121', '1989-11-19', 1);
insert into tb_SlEmp values (3, 'WINTER', 2010, '2010-9-1', 9999.99);

insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('PT', 'Google', 'rachel', 'park', '333333334', '1989-11-19', 1);
insert into tb_PtEmp values (4, '2000-6-1', '2010-1-1', 2000);

insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('PT', 'Google', 'rachel', 'park', '333333334', '1989-11-19', 0);
insert into tb_PtEmp values (5, '2011-1-2', '2016-1-1', -1);

insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth, activityStatus) values 
	('CT', 'Google', '', 'park', '333333334', '1989-11-19', 1);
insert into tb_CtEmp values (6, '2011-1-2', '2016-1-1', 7000);
GO
select * from tb_Emp;
select * from tb_SlEmp;
select * from tb_TimeCard;

insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(1, CONVERT(DATE, '20110116'), 1, 1, 1, 1, 1, 0, 0);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(2, '20110116', 1, 1, 1, 1, 1, 1, 1);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(4, '20110116', 1, 0, 4, 5, 10, 0, 0);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(6, '20110116', 1, 1, 1, 1, 1, 1, 1);

insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(1,  CONVERT(DATE, '20110123'), 1, 1, 1, 1, 2, 0, 0);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(2, '20110123', 1, 1, 1, 1, 1, 1, 1);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(4, '20110123', 1, 0, 4, 5, 10, 0, 0);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(6, '20110123', 10, 10, 10, 10, 10, 10, 10);

insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(1, '20110130', 10, 10, 10, 10, 1, 0, 0);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(2, '20110130', 10, 10, 10, 10, 10, 1, 1);
insert into tb_TimeCard(empID, dateWeekStart, hoursSun, hoursMon, hoursTue, hoursWed, hoursThu, hoursFri, hoursSat) values
(4, '20110130', 10, 10, 4, 5, 10, 10, 0);
insert into tb_TimeCard(empID, dateWeekStart) values
(6, '20110130');