-- EXEC PR_GetExternalTestsLookup 'TO', 'NLEN', 1
ALTER PROCEDURE [dbo].[PR_GetExternalTestsLookup]
(
	@CropCode NVARCHAR(20),
	@BrStationCode	NVARCHAR(10),
	@ShowAll BIT 
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @dt DATE = DATEADD(YEAR, -2, GETUTCDATE());
	SELECT
		T.TestID,
		T.TestName
	FROM Test T
	JOIN [File] F ON F.FileID = T.FileID
	WHERE T.RequestingSystem = 'External'
	AND F.CropCode = @CropCode
	AND T.BreedingStationCode = @BrStationCode
	AND T.StatusCode IN (600, CASE WHEN @ShowAll = 1 THEN 700 END)
	AND F.ImportDateTime >=  @dt
	ORDER BY T.TestID DESC
END
