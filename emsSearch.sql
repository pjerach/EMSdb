use dbEMS;
DROP FUNCTION SearchEmp; 
GO
CREATE FUNCTION SearchEmp
(
	@fName VARCHAR(50), @lName VARCHAR(50), @sin VARCHAR(9)
) RETURNS TABLE
AS	RETURN
		SELECT e.socialInsNumber, e.firstName, e.LastName, e.companyName, e.empType FROM tb_Emp e
		WHERE	(@fName is null or e.firstName = @fName)
			AND	(@lName is null or e.lastName = @lName)
			AND	(@sin is null or e.socialInsNumber = @sin);
GO

select * from SearchEmp('rachel', 'park', null);