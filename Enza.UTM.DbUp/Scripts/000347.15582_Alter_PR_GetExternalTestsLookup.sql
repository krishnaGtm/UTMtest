DROP PROCEDURE IF EXISTS [dbo].[PR_GetExternalTestsLookup]
GO

-- EXEC PR_GetExternalTestsLookup 'TO', 'NLEN'
CREATE PROCEDURE [dbo].[PR_GetExternalTestsLookup]
(
	@CropCode NVARCHAR(20),
	@BrStationCode	NVARCHAR(10)
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
	AND T.StatusCode IN (600,700)
	AND F.ImportDateTime >=  @dt
	ORDER BY T.TestID DESC
END

GO