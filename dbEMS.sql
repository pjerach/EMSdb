USE master;
GO

--Delete the CAP database if it exists.
IF EXISTS(SELECT * from sys.databases WHERE name='dbEMS')
	BEGIN
		DROP DATABASE EMS_EMPLOYEE;
	END
ELSE
	BEGIN
		PRINT 'Database dbEMS Does Not Exist'
	END

--Create a new database called dbEMS.
CREATE DATABASE dbEMS;
GO
PRINT 'Database dbEMS Created'
IF OBJECT_ID('dbo.tb_FtEmp', 'U')		IS NOT NULL DROP TABLE dbo.tb_FtEmp
IF OBJECT_ID('dbo.tb_PtEmp', 'U')		IS NOT NULL DROP TABLE dbo.tb_PtEmp
IF OBJECT_ID('dbo.tb_CtEmp', 'U')		IS NOT NULL DROP TABLE dbo.tb_CtEmp
IF OBJECT_ID('dbo.tb_SlEmp', 'U')		IS NOT NULL DROP TABLE dbo.tb_SlEmp
IF OBJECT_ID('dbo.tb_TimeCard', 'U')	IS NOT NULL DROP TABLE dbo.tb_TimeCard
IF OBJECT_ID('dbo.tb_Audit', 'U')		IS NOT NULL DROP TABLE dbo.tb_Audit
IF OBJECT_ID('dbo.tb_User', 'U')		IS NOT NULL DROP TABLE dbo.tb_User
IF OBJECT_ID('dbo.tb_Emp', 'U')			IS NOT NULL DROP TABLE dbo.tb_Emp
IF OBJECT_ID('dbo.tb_Company', 'U')		IS NOT NULL DROP TABLE dbo.tb_Company

-- Company Table Definition
CREATE TABLE tb_Company (
	companyName			VARCHAR(50)		NOT NULL,
	PRIMARY KEY(companyName)
);

-- User Table Definition
CREATE TABLE tb_User (
	userName		VARCHAR(30)		NOT NULL,
	userPassword	VARCHAR(50)		DEFAULT NULL,
	firstName		VARCHAR(30)		DEFAULT NULL,
	lastName		VARCHAR(30)		DEFAULT NULL,
	securityLevel	INT				NOT NULL,		-- 1-admin, 2-general
	PRIMARY KEY(userName)
);

-- Employee Table Definition
CREATE TABLE tb_Emp (
	empID				INT				NOT NULL		IDENTITY(1,1),
	empType				INT				NOT NULL,
	companyName			VARCHAR(50)		NOT NULL,			
	firstName			VARCHAR(50)		DEFAULT NULL,
	lastName			VARCHAR(50)		DEFAULT NULL,
	socialInsNumber		VARCHAR(9)		DEFAULT NULL,
	dateOfBirth			DATE			DEFAULT NULL,
	activityStatus		BIT				DEFAULT 0,
	reasonForLeaving	VARCHAR(100)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (companyName) REFERENCES tb_Company(companyName)
);

-- Full-time Employee Table Definition 
CREATE TABLE tb_FtEmp (
	empID				INT				NOT NULL,
	dateOfHire			DATE			DEFAULT NULL,
	dateOfTermination	DATE			DEFAULT NULL,
	salary				DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);

-- Part-time Employee Table Definition 
CREATE TABLE tb_PtEmp (
	empID				INT				NOT NULL,
	dateOfHire			DATE			DEFAULT NULL,
	dateOfTermination	DATE			DEFAULT NULL,
	hourlyRate			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);

-- Contract Employee Table Definition 
CREATE TABLE tb_CtEmp (
	empID				INT				NOT NULL,
	dateStart			DATE			DEFAULT NULL,
	dateStop			DATE			DEFAULT NULL,
	fixedCtAmt			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);

-- Seasonal Employee Table Definition 
CREATE TABLE tb_SlEmp (
	empID				INT				NOT NULL,
	season				INT				DEFAULT NULL,	-- 1-Sprint, 2-Summer, 3-Fall, 4-Winter 
	yearOfCt			SMALLINT		DEFAULT NULL,
	fixedCtAmt			DECIMAL(10,2)	DEFAULT NULL,
	PRIMARY KEY(empID),
	FOREIGN KEY (empID) REFERENCES tb_Emp(empID)
);

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