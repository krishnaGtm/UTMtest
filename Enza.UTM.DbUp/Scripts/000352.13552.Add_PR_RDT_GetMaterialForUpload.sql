DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_GetMaterialForUpload]
GO

--EXEC PR_RDT_GetMaterialForUpload 2064;
CREATE PROCEDURE [dbo].[PR_RDT_GetMaterialForUpload]
(
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID)
	BEGIN
		EXEC PR_ThrowError N'Invalid test.';
		RETURN;
	END

	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode = 100)
	BEGIN
		EXEC PR_ThrowError N'Invalid test status.';
		RETURN;
	END

	SELECT
		F.CropCode AS 'Crop',
		T.BreedingStationCode AS 'BrStation',
		T.CountryCode AS 'Country',
		T.ImportLevel AS 'Level',
		TT.TestTypeCode AS 'TestType',
		T.TestID AS 'RequestID',
		'UTM' AS 'RequestingSystem',
		D.DeterminationID,
		M.MaterialID,
		M.MaterialKey,
		CONVERT(varchar(50), TMD.ExpectedDate, 120) AS 'ExpectedResultDate',
		M.MaterialState AS 'MaterialStatus'
	FROM Test T
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN TestMaterialDetermination TMD ON TMD.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID	
	WHERE T.TestID = @TestID

END
GO


