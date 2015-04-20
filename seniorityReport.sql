use [dbEMS];
IF object_id(N'WhoWorks', N'IF') IS NOT NULL
    DROP FUNCTION WhoWorks
GO
CREATE FUNCTION WhoWorks
(
	@companyName VARCHAR(30)
) RETURNS TABLE
AS RETURN
	(SELECT e.empID AS 'eid' FROM tb_Emp e WHERE e.companyName = @companyName);
GO

use [dbEMS];
IF object_id(N'HowLongEmpNoSeason', N'FN') IS NOT NULL
    DROP FUNCTION HowLongEmpNoSeason
GO
CREATE FUNCTION HowLongEmpNoSeason
(
	@oldDate DATE, @newDate DATE
) RETURNS VARCHAR(30)
AS BEGIN
	DECLARE @sinceWhenSeason VARCHAR(10)
	DECLARE @howLong INT
	DECLARE @timeUnit VARCHAR(10)
	SET @howLong = DATEDIFF(day, @oldDate, @newDate);
	IF(@howlong < 30) 
		SET @timeUnit = ' day(s)'
	ELSE
	BEGIN
		IF (@howlong < 365) 
		BEGIN
			SET @howLong = DATEDIFF(month, @oldDate, @newDate)
			SET @timeUnit = ' month(s)'
		END
		ELSE
		BEGIN
			SET @howLong = DATEDIFF(year, @oldDate, @newDate)
			SET @timeUnit = ' year(s)'
			IF(MONTH(@oldDate) > MONTH(@newDate)) SET @howLong = @howLong-1
			ELSE
				IF((MONTH(@oldDate) = MONTH(@newDate)) AND (DAY(@oldDate) > DAY(@newDate)))
						SET @howLong = @howLong-1
		END
	END
	RETURN CONCAT(CONVERT(VARCHAR(6), @howLong), @timeUnit)
END
GO

use [dbEMS];
IF object_id(N'HowLongSeason', N'FN') IS NOT NULL
    DROP FUNCTION HowLongSeason
GO
CREATE FUNCTION HowLongSeason
(
	@id INT
) RETURNS VARCHAR(15)
AS BEGIN
	DECLARE @sinceWhenSeason VARCHAR(10);
	DECLARE @sinceWhenYear VARCHAR(4);
	DECLARE @oldDate DATE;
	DECLARE @newDate DATE;
	DECLARE @howLong INT;
	SET @sinceWhenYear =  CAST((SELECT s.seasonYear FROM tb_Emp e INNER JOIN tb_SlEmp s ON e.empID = s.empID WHERE e.empID = @id) AS VARCHAR(4));
	SET @sinceWhenSeason = (SELECT s.season FROM tb_Emp e INNER JOIN tb_SlEmp s ON e.empID = s.empID WHERE e.empID = @id);
	IF(@sinceWhenSeason='FALL') 
		SET @sinceWhenSeason='09'
	ELSE IF(@sinceWhenSeason='SUMMER') 
		SET @sinceWhenSeason='07';
	ELSE IF(@sinceWhenSeason='WINTER') 
		SET @sinceWhenSeason='12'
	ELSE IF(@sinceWhenSeason='SPRING') 
		SET @sinceWhenSeason='05'
	IF(@sinceWhenSeason='09') 
		SET @newDate = (SELECT convert(date, (CONCAT(@sinceWhenYear, '1130'))));
	ELSE IF(@sinceWhenSeason='07') 
		SET @newDate = (SELECT convert(date, (CONCAT(@sinceWhenYear, '0831'))));
	ELSE IF(@sinceWhenSeason='12') 
		SET @newDate = (SELECT convert(date, (CONCAT(CONVERT(VARCHAR(4),CONVERT(INT, @sinceWhenYear+1)), '0430'))));
	ELSE IF(@sinceWhenSeason='05') 
		SET @newDate = (SELECT convert(date, (CONCAT(@sinceWhenYear, '0630'))));
	SET @oldDate = (SELECT convert(date, (CONCAT(@sinceWhenYear, @sinceWhenSeason, '01'))))		
	RETURN dbo.HowLongEmpNoSeason(@oldDate, @newDate)
END
GO

--print  convert(date, (CONCAT('2000', '07', '01')))
IF object_id(N'allEmployeeForSR', N'V') IS NOT NULL
    DROP VIEW allEmployeeForSR;
GO
CREATE VIEW allEmployeeForSR
AS			(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ef.dateOfHire AS 'Date Of Hire', dbo.HowLongEmpNoSeason(ef.dateOfHire, ef.dateOfTermination) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_FtEmp ef ON e.empID=ef.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ep.dateOfHire AS 'Date Of Hire', dbo.HowLongEmpNoSeason(ep.dateOfHire, ep.dateOfTermination) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_PtEmp ep ON e.empID=ep.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ec.dateStart AS 'Date Of Hire', dbo.HowLongEmpNoSeason(ec.dateStart, ec.dateStop) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_CtEmp ec ON e.empID=ec.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', sl.dateStart AS 'Date Of Hire', dbo.HowLongSeason(e.empID) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_SlEmp sl ON e.empID=sl.empID);
GO

use [dbEMS];
IF object_id(N'SeniorityReport', N'TF') IS NOT NULL
    DROP FUNCTION SeniorityReport
GO
CREATE FUNCTION SeniorityReport (@company VARCHAR(30))
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [SIN] VARCHAR(9), [Type] VARCHAR(2), [Date Of Hire] DATE, [Years Of Service] VARCHAR(15))
AS
BEGIN 
	Declare @Porcentaje varchar(10)
	DECLARE @id INT

	DECLARE SeniorityReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN SeniorityReportCursor
	FETCH NEXT FROM SeniorityReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO @resulttb([Employee Name], [SIN], [Type], [Date Of Hire], [Years Of Service])
		SELECT a.[Employee Name], a.[SIN], a.[Type], a.[Date Of Hire], a.[Years Of Service]
		FROM allEmployeeForSR a
		WHERE a.allid = @id;
		FETCH NEXT FROM SeniorityReportCursor INTO @id
	END
	CLOSE SeniorityReportCursor
	DEALLOCATE SeniorityReportCursor
RETURN 
END
GO


select * from dbo.SeniorityReport('BlackBerry');
select * from dbo.SeniorityReport('MS');
select * from dbo.SeniorityReport('Google');