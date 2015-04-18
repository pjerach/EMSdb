use dbEMS;
-- IMPORTANT
--Before insert employee add company first to the company database due to fk constraint
insert into tb_Company values ('BlackBerry');
insert into tb_Company values ('Google');
insert into tb_Company values ('MS');
insert into tb_User values ('rach', '1234', 'rachel', 'park', 1);
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('FT', 'BlackBerry', 'rachel', 'park', '333333334', '1989-11-19');
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('PT', 'Google', 'rachel', 'park', '333333334', '1989-11-19');
insert into tb_Emp (empType, companyName, firstName, lastName, socialInsNumber, dateOfBirth) values 
	('FT', 'MS', 'rachel', 'Joo', '121212121', '1989-11-19');
GO