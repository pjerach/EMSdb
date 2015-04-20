----------------------------------------------------------------------------------------------------------------------------------
-- Calculate SUM of hours given empID and Date of Working Week
----------------------------------------------------------------------------------------------------------------------------------
use [dbEMS];
IF object_id(N'SumHours', N'FN') IS NOT NULL
    DROP FUNCTION SumHours
GO
CREATE FUNCTION SumHours
(
	@id INT, @weekDate DATE
) RETURNS DECIMAL(10,2)
AS BEGIN
	DECLARE @sumHoursWorked INT
	SET @sumHoursWorked = (SELECT hoursSun FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursMon FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursTue FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursWed FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursThu FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursFri FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT hoursSat FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
RETURN @sumHoursWorked 
END
GO
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------
-- For each employee type Create Functions that take in date and empID and 
-- return tables each of which forms a backbone of WeeklyHourReport 
----------------------------------------------------------------------------------------------------------------------------------
use [dbEMS];
IF object_id(N'WHR_FT', N'IF') IS NOT NULL
    DROP FUNCTION WHR_FT
GO
CREATE FUNCTION WHR_FT
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name', e.socialInsNumber AS 'SIN',  dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID WHERE e.empType='FT' AND tc.dateWeekStart=@weekDate AND e.empID=@id)
GO
use [dbEMS];
IF object_id(N'WHR_PT', N'FT') IS NOT NULL
    DROP FUNCTION WHR_PT
GO
CREATE FUNCTION WHR_PT
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name', e.socialInsNumber AS 'SIN',  dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID WHERE e.empType='PT' AND tc.dateWeekStart=@weekDate)
GO
use [dbEMS];
IF object_id(N'WHR_SL', N'FT') IS NOT NULL
    DROP FUNCTION WHR_SL
GO
CREATE FUNCTION WHR_SL
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name', e.socialInsNumber AS 'SIN',  dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID WHERE e.empType='SL' AND tc.dateWeekStart=@weekDate)
GO
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- Create Functions that go through each employee who works for the company specified
-- and checks if that employee is contained in the related (w.r.t. employeetype) funcation table (created above) 
-- (The reason why the functions are created separately is 
--  to match the sample WHR format that has 3 separate reports for each employee type)
----------------------------------------------------------------------------------------------------------------------------------
use [dbEMS];
IF object_id(N'WeeklyHoursReport_FT', N'TF') IS NOT NULL
    DROP FUNCTION WeeklyHoursReport_FT
GO
CREATE FUNCTION WeeklyHoursReport_FT (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [SIN] VARCHAR(9), [Hours] DECIMAL(10,2))
AS
BEGIN 
	DECLARE @id INT

	DECLARE WeeklyHoursReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN WeeklyHoursReportCursor
	FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO @resulttb([Employee Name], [SIN], [Hours])
		SELECT  ft.[Employee Name], ft.[SIN], ft.[Hours]
		FROM dbo.WHR_FT(@id, @whichWeek) ft INNER JOIN tb_TimeCard tctb ON ft.allid=tctb.empID
		WHERE ft.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	END
	CLOSE WeeklyHoursReportCursor
	DEALLOCATE WeeklyHoursReportCursor
RETURN 
END
GO

use [dbEMS];
IF object_id(N'WeeklyHoursReport_PT', N'TF') IS NOT NULL
    DROP FUNCTION WeeklyHoursReport_PT
GO
CREATE FUNCTION WeeklyHoursReport_PT (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [SIN] VARCHAR(9), [Hours] DECIMAL(10,2))
AS
BEGIN 
	DECLARE @id INT

	DECLARE WeeklyHoursReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN WeeklyHoursReportCursor
	FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO @resulttb([Employee Name], [SIN], [Hours])
		SELECT pt.[Employee Name], pt.[SIN], pt.[Hours]
		FROM dbo.WHR_PT(@id, @whichWeek) pt INNER JOIN tb_TimeCard tctb ON pt.allid=tctb.empID
		WHERE pt.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	END
	CLOSE WeeklyHoursReportCursor
	DEALLOCATE WeeklyHoursReportCursor
RETURN 
END
GO

use [dbEMS];
IF object_id(N'WeeklyHoursReport_SL', N'TF') IS NOT NULL
    DROP FUNCTION WeeklyHoursReport_SL
GO
CREATE FUNCTION WeeklyHoursReport_SL (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [SIN] VARCHAR(9), [Hours] DECIMAL(10,2))
AS
BEGIN 
	DECLARE @id INT

	DECLARE WeeklyHoursReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN WeeklyHoursReportCursor
	FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO @resulttb([Employee Name], [SIN], [Hours])
		SELECT sl.[Employee Name], sl.[SIN], sl.[Hours]
		FROM dbo.WHR_SL(@id, @whichWeek) sl INNER JOIN tb_TimeCard tctb ON sl.allid=tctb.empID
		WHERE sl.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM WeeklyHoursReportCursor INTO @id
	END
	CLOSE WeeklyHoursReportCursor
	DEALLOCATE WeeklyHoursReportCursor
RETURN 
END
GO
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

select * from dbo.WeeklyHoursReport_FT('BlackBerry', '20110116')	--5
select * from dbo.WeeklyHoursReport_PT('BlackBerry', '20110116')
select * from dbo.WeeklyHoursReport_SL('BlackBerry', '20110116')

select * from dbo.WeeklyHoursReport_FT('MS', '20110116')
select * from dbo.WeeklyHoursReport_PT('MS', '20110116')
select * from dbo.WeeklyHoursReport_SL('MS', '20110116')			--7

select * from dbo.WeeklyHoursReport_FT('Google', '20110116')
select * from dbo.WeeklyHoursReport_PT('Google', '20110116')		--20
select * from dbo.WeeklyHoursReport_SL('Google', '20110116')