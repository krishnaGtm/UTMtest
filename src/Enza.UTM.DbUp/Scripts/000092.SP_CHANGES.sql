
ALTER PROCEDURE [dbo].[PR_Get_WellType]
AS
BEGIN
	SELECT WellTypeID,BGColor,FGColor,WellTypeName FROM WellType;
END

