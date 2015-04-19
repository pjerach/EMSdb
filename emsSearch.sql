-------------------SEARCH FOR EMPLOYEE
use [dbEMS];
DROP FUNCTION A_SearchEmp;
GO
CREATE FUNCTION A_SearchEmp
(
	@fName VARCHAR(50), @lName VARCHAR(50), @sin VARCHAR(9)
) RETURNS TABLE
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, e.empType FROM tb_Emp AS e
	WHERE	(LEN(@fName) = 0 or e.firstName = @fName)
		AND	(LEN(@lName) = 0 or e.lastName = @lName)
		AND	(LEN(@sin) = 0 or e.socialInsNumber = @sin);
GO
DROP FUNCTION G_SearchEmp; 
GO
CREATE FUNCTION G_SearchEmp
(
	@fName VARCHAR(50), @lName VARCHAR(50), @sin VARCHAR(9)
) RETURNS TABLE
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, e.empType FROM tb_Emp AS e
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
DROP FUNCTION A_DisplayFTEmp;
GO
CREATE FUNCTION A_DisplayFTEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, fe.dateOfHire, fe.dateOfTermination, fe.salary
	FROM tb_Emp AS e INNER JOIN tb_FtEmp AS fe ON (e.empID = fe.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
DROP FUNCTION G_DisplayFTEmp;
GO
CREATE FUNCTION G_DisplayFTEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, fe.dateOfHire
	FROM tb_Emp AS e INNER JOIN tb_FtEmp AS fe ON (e.empID = fe.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO	
------------------------------------------------
-------------------DISPLAY PartTime EMPLOYEE
------------------------------------------------
DROP FUNCTION A_DisplayPTEmp;
GO
CREATE FUNCTION A_DisplayPTEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, pe.dateOfHire, pe.dateOfTermination, pe.hourlyRate
	FROM tb_Emp AS e INNER JOIN tb_PtEmp AS pe ON (e.empID = pe.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
DROP FUNCTION G_DisplayPTEmp;
GO
CREATE FUNCTION G_DisplayPTEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, pe.dateOfHire
	FROM tb_Emp AS e INNER JOIN tb_PtEmp AS pe ON (e.empID = pe.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
------------------------------------------------
-------------------DISPLAY Seasonal EMPLOYEE
------------------------------------------------
DROP FUNCTION A_DisplaySLEmp;
GO
CREATE FUNCTION A_DisplaySLEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, sl.season, sl.yearOfCt, sl.fixedCtAmt
	FROM tb_Emp AS e INNER JOIN tb_SlEmp AS sl ON (e.empID = sl.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
DROP FUNCTION G_DisplaySLEmp;
GO
CREATE FUNCTION G_DisplaySLEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, sl.season, sl.yearOfCt
	FROM tb_Emp AS e INNER JOIN tb_SlEmp AS sl ON (e.empID = sl.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
------------------------------------------------
-------------------DISPLAY Contract EMPLOYEE
------------------------------------------------
DROP FUNCTION A_DisplayCTEmp;
GO
CREATE FUNCTION A_DisplayCTEmp
(
	@fn VARCHAR(50), @ln VARCHAR(50), @sin VARCHAR(9), @cn VARCHAR(50)
) RETURNS TABLE 
AS RETURN
	SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, ct.dateStart, ct.dateStop, ct.fixedCtAmt
	FROM tb_Emp AS e INNER JOIN tb_CtEmp AS ct ON (e.empID = ct.empID)
	WHERE (@fn = e.firstName) AND (@ln = e.lastName)
	AND (@sin = e.socialInsNumber) AND (@cn = e.companyName);
GO
	

use dbEMS;
select * from dbo.A_DisplayFTEmp('rachel', 'park', '333333334', 'BlackBerry');