----------------------------------------------------------------------------------------------------------------------------------
-- Calculate SUM of pieces given empID and Date of Working Week (for seasonal employee)
----------------------------------------------------------------------------------------------------------------------------------
use [dbEMS];
IF object_id(N'SumTotalHours', N'FN') IS NOT NULL
    DROP FUNCTION SumTotalHours
GO
CREATE FUNCTION SumTotalHours (@id INT, @whichWeek DATE)
RETURNS INT
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



use [dbEMS];
IF object_id(N'AvgHours_FT', N'FN') IS NOT NULL
    DROP FUNCTION AvgHours_FT
GO
CREATE FUNCTION AvgHours_FT
(
	@id INT , @weekDate DATE
) RETURNS DECIMAL(10,2)
AS BEGIN
	DECLARE @avgHoursWorked INT
	DECLARE @howManyWeeksSoFar INT
	SET @howManyWeeksSoFar = DATEDIFF(week, (SELECT e.dateOfHire FROM tb_Emp AS e INNER JOIN tb_FtEmp AS ft ON e.empID=ft.empID WHERE e.empID = @id), @weekDate)
	SET @totalHoursWorked = 
	
	
	(SELECT piecesSun FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesMon FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesTue FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesWed FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesThu FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesFri FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
		+ (SELECT piecesSat FROM tb_TimeCard tc WHERE tc.empID = @id AND tc.dateWeekStart=@weekDate)
RETURN @avgHoursWorked 
END
GO