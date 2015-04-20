----------------------------------------------------------------------------------------------------------------------------------
-- Calculate SUM of pieces given empID and Date of Working Week (for seasonal employee)
----------------------------------------------------------------------------------------------------------------------------------
use [dbEMS];
IF object_id(N'SumPieces', N'FN') IS NOT NULL
    DROP FUNCTION SumPieces
GO
CREATE FUNCTION SumPieces
(
	@id INT , @weekDate DATE
) RETURNS DECIMAL(10,2)
AS BEGIN
	DECLARE @sumHoursWorked INT
	SET @sumHoursWorked = (SELECT piecesSun FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesMon FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesTue FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesWed FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesThu FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesFri FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesSat FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
RETURN @sumHoursWorked 
END
GO
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------
-- For each employee type Create Functions that take in date and empID and 
-- return tables each of which forms a backbone of PayrollReport with appropriate columns
----------------------------------------------------------------------------------------------------------------------------------
-- FULL TIME
use [dbEMS];
IF object_id(N'PR_FT', N'IF') IS NOT NULL
    DROP FUNCTION PR_FT
GO
CREATE FUNCTION PR_FT
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
			dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours',
			CONVERT(DECIMAL(10,2),ft.salary/52) AS 'Gross', CONVERT(VARCHAR(100), '') AS 'Note'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID
					 INNER JOIN tb_FtEmp ft ON e.empID=ft.empID WHERE e.empType='FT' AND tc.dateWeekStart=@weekDate AND e.empID=@id)
GO
-- PART TIME
use [dbEMS];
IF object_id(N'PR_PT', N'IF') IS NOT NULL
    DROP FUNCTION PR_PT
GO
CREATE FUNCTION PR_PT
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
			dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours',
			CONVERT(DECIMAL(10,2),pt.hourlyRate) AS 'HourlyRate', CONVERT(VARCHAR(100), '') AS 'Note'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID
					 INNER JOIN tb_PtEmp pt ON e.empID=pt.empID WHERE e.empType='PT' AND tc.dateWeekStart=@weekDate AND e.empID=@id)
GO
-- SEASONAL
use [dbEMS];
IF object_id(N'PR_SL', N'IF') IS NOT NULL
    DROP FUNCTION PR_SL
GO
CREATE FUNCTION PR_SL
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
			dbo.SumHours(e.empID, tc.dateWeekStart) AS 'Hours', dbo.SumPieces(e.empID, tc.dateWeekStart) AS 'Pieces',
			CONVERT(DECIMAL(10,2),sl.piecePay) AS 'PiecePay', CONVERT(VARCHAR(100), '') AS 'Note'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID
					 INNER JOIN tb_SlEmp sl ON e.empID=sl.empID WHERE e.empType='SL' AND tc.dateWeekStart=@weekDate AND e.empID=@id)
GO
-- CONTRACT
use [dbEMS];
IF object_id(N'PR_CT', N'IF') IS NOT NULL
    DROP FUNCTION PR_CT
GO
CREATE FUNCTION PR_CT
(
	@id INT, @weekDate DATE
) RETURNS TABLE
AS RETURN (SELECT DISTINCT e.empID AS 'allid', CONCAT(e.firstName, ' ', e.LastName) AS 'Employee Name',
			'--' AS 'Hours', ct.fixedCtAmt*7/DATEDIFF(day, ct.dateStart, ct.dateStop) AS 'Gross',
			CONVERT(VARCHAR(100), CONCAT(ABS(DATEDIFF(day, SYSDATETIME(), ct.dateStop)), ' days remaining in Contract')) AS 'Note'
	FROM tb_Emp AS e INNER JOIN tb_TimeCard tc ON e.empID=tc.empID
					 INNER JOIN tb_CtEmp ct ON e.empID=ct.empID WHERE e.empType='CT' AND tc.dateWeekStart=@weekDate AND e.empID=@id)
GO
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------
-- Create Functions that go through each employee who works for the company specified
-- and checks if that employee is contained in the related (w.r.t. employeetype) funcation table (created above) 
-- (The reason why the functions are created separately is 
--  to match the sample WHR format that has 3 separate reports for each employee type)
----------------------------------------------------------------------------------------------------------------------------------
-- FULL TIME
use [dbEMS];
IF object_id(N'PayrollReport_FT', N'TF') IS NOT NULL
    DROP FUNCTION PayrollReport_FT
GO
CREATE FUNCTION PayrollReport_FT (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [Hours] DECIMAL(10,2), [Gross] DECIMAL(10,2), [Note] VARCHAR(100))
AS
BEGIN 
	DECLARE @id INT
	DECLARE @hours DECIMAL(10,2)
	DECLARE @gross DECIMAL(10,2)
	DECLARE @note VARCHAR(100)
	DECLARE PayrollReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN PayrollReportCursor
	FETCH NEXT FROM PayrollReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @gross = (SELECT ft.[Gross] FROM dbo.PR_FT(@id, @whichWeek) ft INNER JOIN tb_TimeCard tctb ON ft.allid=tctb.empID WHERE ft.allid = @id AND tctb.dateWeekStart=@whichWeek)
		set @hours = (SELECT ft.[Hours] FROM dbo.PR_FT(@id, @whichWeek) ft INNER JOIN tb_TimeCard tctb ON ft.allid=tctb.empID WHERE ft.allid = @id AND tctb.dateWeekStart=@whichWeek)
		IF @hours < 40 SET @note = 'Not Full Work Week'

		INSERT INTO @resulttb([Employee Name], [Hours], [Gross], [Note])
		SELECT ft.[Employee Name], @hours, @gross, @note
		FROM dbo.PR_FT(@id, @whichWeek) ft INNER JOIN tb_TimeCard tctb ON ft.allid=tctb.empID
		WHERE ft.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM PayrollReportCursor INTO @id
	END
	CLOSE PayrollReportCursor
	DEALLOCATE PayrollReportCursor
RETURN 
END
GO
-- PART TIME
use [dbEMS];
IF object_id(N'PayrollReport_PT', N'TF') IS NOT NULL
    DROP FUNCTION PayrollReport_PT
GO
CREATE FUNCTION PayrollReport_PT (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [Hours] DECIMAL(10,2), [Gross] DECIMAL(10,2), [Note] VARCHAR(100))
AS
BEGIN 
	DECLARE @id INT
	DECLARE @hours DECIMAL(10,2)
	DECLARE @hourly DECIMAL(10,2)
	DECLARE @gross DECIMAL(10,2)
	DECLARE @overtime DECIMAL(10,2)
	DECLARE @note VARCHAR(100)
	DECLARE PayrollReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN PayrollReportCursor
	FETCH NEXT FROM PayrollReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @hours = (SELECT pt.[Hours] FROM dbo.PR_PT(@id, @whichWeek) pt INNER JOIN tb_TimeCard tctb ON pt.allid=tctb.empID WHERE pt.allid = @id AND tctb.dateWeekStart=@whichWeek)
		SET @hourly = (SELECT pt.[HourlyRate] FROM dbo.PR_PT(@id, @whichWeek) pt INNER JOIN tb_TimeCard tctb ON pt.allid=tctb.empID WHERE pt.allid = @id AND tctb.dateWeekStart=@whichWeek)
		
		IF @hours > 40
		BEGIN
			SET @overtime = (@hours-40)*@hourly*1.5
			SET @note = CONCAT((@hours-40), ' hrs. Overtime')
		END
		IF @overtime > 0 SET @gross = @hourly*@hours + @overtime
		ELSE SET @gross = @hourly*@hours

		INSERT INTO @resulttb([Employee Name], [Hours], [Gross], [Note])
		SELECT pt.[Employee Name], @hours, @gross, @note
		FROM dbo.PR_PT(@id, @whichWeek) pt INNER JOIN tb_TimeCard tctb ON pt.allid=tctb.empID
		WHERE pt.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM PayrollReportCursor INTO @id
	END
	CLOSE PayrollReportCursor
	DEALLOCATE PayrollReportCursor
RETURN 
END
GO
-- SEASONAL
use [dbEMS];
IF object_id(N'PayrollReport_SL_WRAPPER', N'TF') IS NOT NULL
    DROP FUNCTION PayrollReport_SL_WRAPPER
GO
CREATE FUNCTION PayrollReport_SL_WRAPPER (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([eid] INT, [maxp] DECIMAL(10,2), [Employee Name] VARCHAR(60), [Hours] DECIMAL(10,2), [Gross] DECIMAL(10,2), [Note] VARCHAR(100))
AS
BEGIN 
	DECLARE @id INT
	DECLARE @hours DECIMAL(10,2)
	DECLARE @pieces DECIMAL(10,2)
	DECLARE @piecepay DECIMAL(10,2)
	DECLARE @gross DECIMAL(10,2)
	DECLARE @note VARCHAR(100)

	DECLARE PayrollReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN PayrollReportCursor
	FETCH NEXT FROM PayrollReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @hours = (SELECT sl.[Hours] FROM dbo.PR_SL(@id, @whichWeek) sl INNER JOIN tb_TimeCard tctb ON sl.allid=tctb.empID WHERE sl.allid = @id AND tctb.dateWeekStart=@whichWeek)
		SET @piecepay = (SELECT sl.[PiecePay] FROM dbo.PR_SL(@id, @whichWeek) sl INNER JOIN tb_TimeCard tctb ON sl.allid=tctb.empID WHERE sl.allid = @id AND tctb.dateWeekStart=@whichWeek)
		SET @pieces = (SELECT sl.[Pieces] FROM dbo.PR_SL(@id, @whichWeek) sl INNER JOIN tb_TimeCard tctb ON sl.allid=tctb.empID WHERE sl.allid = @id AND tctb.dateWeekStart=@whichWeek)
		IF @hours > 40 SET @gross = @pieces*@piecepay + 150
		ELSE SET @gross = @pieces*@piecepay

		INSERT INTO @resulttb([eid], [Employee Name], [Hours], [Gross], [Note])
		SELECT @id, sl.[Employee Name], @hours, @gross, @note
		FROM dbo.PR_SL(@id, @whichWeek) sl INNER JOIN tb_TimeCard tctb ON sl.allid=tctb.empID
		WHERE sl.allid = @id AND tctb.dateWeekStart=@whichWeek;

		FETCH NEXT FROM PayrollReportCursor INTO @id
	END
	CLOSE PayrollReportCursor
	DEALLOCATE PayrollReportCursor 
	UPDATE @resulttb SET [Note]='Most Productive' WHERE [eid] = (SELECT [eid] from @resulttb WHERE dbo.SumPieces([eid], @whichWeek) = (select MAX(dbo.SumPieces([eid], @whichWeek)) from @resulttb group by eid));
RETURN 
END
GO

-- SEASONAL
use [dbEMS];
IF object_id(N'PayrollReport_SL', N'IF') IS NOT NULL
    DROP FUNCTION PayrollReport_SL
GO
CREATE FUNCTION PayrollReport_SL (@company VARCHAR(30), @whichWeek DATE)
RETURNS TABLE
AS RETURN
	SELECT [Employee Name], [Hours], [Gross], [Note] FROM dbo.PayrollReport_SL_WRAPPER(@company, @whichWeek)
GO
-- CONTRACT
use [dbEMS];
IF object_id(N'PayrollReport_CT', N'TF') IS NOT NULL
    DROP FUNCTION PayrollReport_CT
GO
CREATE FUNCTION PayrollReport_CT (@company VARCHAR(30), @whichWeek DATE)
RETURNS @resulttb TABLE ([Employee Name] VARCHAR(60), [Hours] VARCHAR(2), [Gross] DECIMAL(10,2), [Note] VARCHAR(100))
AS
BEGIN 
	DECLARE @id INT
	DECLARE PayrollReportCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT ec.eid
		FROM [dbo].WhoWorks(@company) AS ec
	OPEN PayrollReportCursor
	FETCH NEXT FROM PayrollReportCursor INTO @id
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO @resulttb([Employee Name], [Hours], [Gross], [Note])
		SELECT ct.[Employee Name], ct.[Hours], ct.[Gross], ct.[Note]
		FROM dbo.PR_CT(@id, @whichWeek) ct INNER JOIN tb_TimeCard tctb ON ct.allid=tctb.empID
		WHERE ct.allid = @id AND tctb.dateWeekStart=@whichWeek;
		FETCH NEXT FROM PayrollReportCursor INTO @id
	END
	CLOSE PayrollReportCursor
	DEALLOCATE PayrollReportCursor
RETURN 
END
GO




select * from dbo.PayrollReport_FT('BlackBerry', '20110116')
select * from dbo.PayrollReport_PT('Google', '20110130')
select * from dbo.PayrollReport_SL('MS', '20110130')
select * from dbo.PayrollReport_CT('Google', '20110130')