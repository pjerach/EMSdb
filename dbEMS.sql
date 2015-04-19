--Delete the CAP database if it exists
--http://www.mytechmantra.com/LearnSQLServer/Drop-Database-in-SQL-Server-by-Killing-Existing-Connections.html
WHILE EXISTS(select NULL from sys.databases where name=N'dbEMS' )
BEGIN
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'dbEMS' 
	USE [master] 
	ALTER DATABASE [dbEMS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
	DROP DATABASE [dbEMS];
END
GO
CREATE DATABASE [dbEMS];
GO

USE [dbEMS];
-- Company Table Definition
CREATE TABLE tb_Company (
	companyName			VARCHAR(50)		NOT NULL,
	PRIMARY KEY(companyName)
);
GO

-- User Table Definition
CREATE TABLE tb_User (
	userName		VARCHAR(30)		NOT NULL,
	userPassword	VARCHAR(50)		DEFAULT NULL,
	firstName		VARCHAR(30)		DEFAULT NULL,
	lastName		VARCHAR(30)		DEFAULT NULL,
	securityLevel	INT				NOT NULL,		-- 1-admin, 2-general
	PRIMARY KEY(userName)
);
GO

-- Employee Table Definition
CREATE TABLE tb_Emp (
	empID				INT				NOT NULL		IDENTITY(1,1),
	empType				CHAR(2)			NOT NULL,
	companyName			VARCHAR(50)		NOT NULL,			
	firstName			VARCHAR(50)		DEFAULT NULL,
	lastName			VARCHAR(50)		DEFAULT NULL,
	socialInsNumber		VARCHAR(9)		DEFAULT NULL,
	dateOfBirth			DATE			DEFAULT NULL,
	activityStatus		BIT				DEFAULT 0,		-- 0-inactive, 1-active (controlled by the system)
	reasonForLeaving	VARCHAR(100)	DEFAULT NULL,	-- only for activityStatus=0
	PRIMARY KEY(empID),
	FOREIGN KEY (companyName) REFERENCES tb_Company(companyName),
	UNIQUE(empType, companyName, firstName, lastName, socialInsNumber)
);
GO

-- Full-time Employee Table Definition 
CREATE TABLE tb_FtEmp (
	empID				INT				NOT NULL,
	dateOfHire			DATE			DEFAULT NULL,
	dateOfTermination	DATE			DEFAULT NULL,
	salary				DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);
GO

-- Part-time Employee Table Definition 
CREATE TABLE tb_PtEmp (
	empID				INT				NOT NULL,
	dateOfHire			DATE			DEFAULT NULL,
	dateOfTermination	DATE			DEFAULT NULL,
	hourlyRate			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);
GO

-- Contract Employee Table Definition 
CREATE TABLE tb_CtEmp (
	empID				INT				NOT NULL,
	dateStart			DATE			DEFAULT NULL,
	dateStop			DATE			DEFAULT NULL,
	fixedCtAmt			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);
GO

-- Seasonal Employee Table Definition 
CREATE TABLE tb_SlEmp (
	empID				INT				NOT NULL,
	season				VARCHAR(10)		DEFAULT NULL,
	yearOfCt			SMALLINT		DEFAULT NULL,
	fixedCtAmt			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);
GO

-- Audit Table Definition 
CREATE TABLE tb_Audit (
	auditID				INT				NOT NULL	IDENTITY(1,1),
	timeChanged			DATETIME		DEFAULT NULL,
	empID				INT				DEFAULT NULL,
	oldEntry			VARCHAR(50)		DEFAULT NULL,
	newEntry			VARCHAR(50)		DEFAULT NULL,
	PRIMARY KEY(auditID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);
GO

-- Time Card Table Definition 
CREATE TABLE tb_TimeCard (
	timeCardID			INT				NOT NULL	IDENTITY(1,1),
	empID				INT				DEFAULT NULL,	
	dateWeekStart		DATETIME		DEFAULT NULL,
	hoursSun			TIME			DEFAULT NULL,
	hoursMon			TIME			DEFAULT NULL,
	hoursTue			TIME			DEFAULT NULL,
	hoursWed			TIME			DEFAULT NULL,
	hoursThu			TIME			DEFAULT NULL,
	hoursFri			TIME			DEFAULT NULL,
	hoursSat			TIME			DEFAULT NULL,
	piecesSun			DECIMAL(4,2)	DEFAULT NULL,
	piecesMon			DECIMAL(4,2)	DEFAULT NULL,
	piecesTue			DECIMAL(4,2)	DEFAULT NULL,
	piecesWed			DECIMAL(4,2)	DEFAULT NULL,
	piecesThu			DECIMAL(4,2)	DEFAULT NULL,
	piecesFri			DECIMAL(4,2)	DEFAULT NULL,
	piecesSat			DECIMAL(4,2)	DEFAULT NULL,
	PRIMARY KEY(timeCardID)
);
GO
