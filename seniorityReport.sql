
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
IF object_id(N'allEmployeeForSR', N'V') IS NOT NULL
    DROP VIEW allEmployeeForSR;
GO
CREATE VIEW allEmployeeForSR
AS			(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ef.dateOfHire AS 'Date Of Hire', DATEDIFF(day, ef.dateOfHire, SYSDATETIME()) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_FtEmp ef ON e.empID=ef.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ep.dateOfHire AS 'Date Of Hire', DATEDIFF(day, ep.dateOfHire, SYSDATETIME()) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_PtEmp ep ON e.empID=ep.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', ec.dateStart AS 'Date Of Hire', DATEDIFF(day, ec.dateStart, SYSDATETIME()) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_CtEmp ec ON e.empID=ec.empID)
	UNION	(SELECT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
		   e.socialInsNumber AS 'SIN', e.empType AS 'Type', sl.dateStart AS 'Date Of Hire', DATEDIFF(day, sl.dateStart, SYSDATETIME()) AS 'Years Of Service'
			FROM tb_Emp AS e INNER JOIN tb_SlEmp sl ON e.empID=sl.empID);
GO

use [dbEMS];
IF object_id(N'SeniorityReport', N'IF') IS NOT NULL
    DROP FUNCTION SeniorityReport
GO
CREATE FUNCTION SeniorityReport (@company VARCHAR(30))
RETURNS @resulttb TABLE (rid INT, rname VARCHAR(60), rsin VARCHAR(9), rtype VARCHAR(2), rdate DATE, rduration INT)
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
		INSERT INTO @resulttb(rid, rname, rsin, rtype, rdate, rduration)
		SELECT a.allid, a.[Employee Name], a.[SIN], a.[Type], a.[Date Of Hire], a.[Years Of Service]
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
