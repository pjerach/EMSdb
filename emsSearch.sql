-------------------SEARCH FOR EMPLOYEE
use [dbEMS];
IF object_id(N'A_SearchEmp', N'IF') IS NOT NULL
    DROP FUNCTION A_SearchEmp
GO
CREATE FUNCTION A_SearchEmp
(
	@fName VARCHAR(50), @lName VARCHAR(50), @sin VARCHAR(9)
) RETURNS TABLE
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, e.empType FROM tb_Emp AS e
	WHERE	(LEN(@fName) = 0 or e.firstName LIKE '%' + @fName + '%')
		AND	(LEN(@lName) = 0 or e.lastName LIKE '%' + @lName + '%')
		AND	(LEN(@sin) = 0 or e.socialInsNumber LIKE '%' + @sin + '%');
GO
IF object_id(N'G_SearchEmp', N'IF') IS NOT NULL
DROP FUNCTION G_SearchEmp; 
GO
CREATE FUNCTION G_SearchEmp
(
	@fName VARCHAR(50), @lName VARCHAR(50), @sin VARCHAR(9)
) RETURNS TABLE
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, e.empType FROM tb_Emp AS e
	WHERE	(LEN(@fName) = 0 or e.firstName = @fName)
		AND	(LEN(@lName) = 0 or e.lastName = @lName)
		AND	(LEN(@sin) = 0 or e.socialInsNumber = @sin)
		AND (e.empType <> 'CT');
GO
------------------------------------------------
-------------------DISPLAY FullTime EMPLOYEE
------------------------------------------------
use [dbEMS];
GO
IF object_id(N'A_DisplayFTEmp', N'IF') IS NOT NULL
DROP FUNCTION A_DisplayFTEmp;
GO
CREATE FUNCTION A_DisplayFTEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, fe.dateOfHire, fe.dateOfTermination, fe.salary
	FROM tb_Emp AS e INNER JOIN tb_FtEmp AS fe ON (e.empID = fe.empID)
	WHERE (@eid = e.empID);
GO
IF object_id(N'G_DisplayFTEmp', N'IF') IS NOT NULL
DROP FUNCTION G_DisplayFTEmp;
GO
CREATE FUNCTION G_DisplayFTEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, fe.dateOfHire
	FROM tb_Emp AS e INNER JOIN tb_FtEmp AS fe ON (e.empID = fe.empID)
	WHERE (@eid = e.empID);
GO	
------------------------------------------------
-------------------DISPLAY PartTime EMPLOYEE
------------------------------------------------
IF object_id(N'A_DisplayPTEmp', N'IF') IS NOT NULL
DROP FUNCTION A_DisplayPTEmp;
GO
CREATE FUNCTION A_DisplayPTEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, pe.dateOfHire, pe.dateOfTermination, pe.hourlyRate
	FROM tb_Emp AS e INNER JOIN tb_PtEmp AS pe ON (e.empID = pe.empID)
	WHERE (@eid = e.empID);
GO
IF object_id(N'G_DisplayPTEmp', N'IF') IS NOT NULL
DROP FUNCTION G_DisplayPTEmp;
GO
CREATE FUNCTION G_DisplayPTEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, pe.dateOfHire
	FROM tb_Emp AS e INNER JOIN tb_PtEmp AS pe ON (e.empID = pe.empID)
	WHERE (@eid = e.empID);
GO
------------------------------------------------
-------------------DISPLAY Seasonal EMPLOYEE
------------------------------------------------
IF object_id(N'A_DisplaySLEmp', N'IF') IS NOT NULL
DROP FUNCTION A_DisplaySLEmp;
GO
CREATE FUNCTION A_DisplaySLEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, sl.season, sl.seasonYear, sl.dateStart, sl.piecePay
	FROM tb_Emp AS e INNER JOIN tb_SlEmp AS sl ON (e.empID = sl.empID)
	WHERE (@eid = e.empID);
GO
IF object_id(N'G_DisplaySLEmp', N'IF') IS NOT NULL
DROP FUNCTION G_DisplaySLEmp;
GO
CREATE FUNCTION G_DisplaySLEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, sl.season, sl.seasonYear, sl.dateStart
	FROM tb_Emp AS e INNER JOIN tb_SlEmp AS sl ON (e.empID = sl.empID)
	WHERE (@eid = e.empID);
GO
------------------------------------------------
-------------------DISPLAY Contract EMPLOYEE
------------------------------------------------
IF object_id(N'A_DisplayCTEmp', N'IF') IS NOT NULL
DROP FUNCTION A_DisplayCTEmp;
GO
CREATE FUNCTION A_DisplayCTEmp
(
	@eid INT
) RETURNS TABLE 
AS RETURN
	SELECT e.empID, e.socialInsNumber, e.firstName, e.LastName, e.companyName, ct.dateStart, ct.dateStop, ct.fixedCtAmt
	FROM tb_Emp AS e INNER JOIN tb_CtEmp AS ct ON (e.empID = ct.empID)
	WHERE (@eid = e.empID);
GO
	

use dbEMS;
select * from dbo.A_DisplayFTEmp(1);--'rachel', 'park', '333333334', 'BlackBerry');