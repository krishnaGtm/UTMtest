DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_GetMaterialForUpload]
GO


--EXEC PR_RDT_GetMaterialForUpload 10621;
CREATE PROCEDURE [dbo].[PR_RDT_GetMaterialForUpload]
(
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @ImportType NVARCHAR(50);
	
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

	IF EXISTS(SELECT TestID FROM TestMaterialDetermination WHERE TestID = @TestID AND ISNULL(ExpectedDate,'') = '')
	BEGIN
		EXEC PR_ThrowError N'Expected result date cannot be empty. Please fill for all selected materials !';
		RETURN;
	END
	
	--If List type is imported then check for materialstatus
	SELECT @ImportType = ImportLevel FROM Test WHERE TestID = @TestID;

	IF @ImportType = 'LIST'
	BEGIN

		IF EXISTS 
		( 
			SELECT * FROM TestMaterial TM
			JOIN TestMaterialDetermination TMD ON TMD.TestID = TM.TestID AND TMD.MaterialID = TM.MaterialID 
			WHERE TM.TestID = @TestID AND ISNULL(MaterialStatus,'') = '' 
		)
		BEGIN
			EXEC PR_ThrowError N'Material Status cannot be empty. Please fill for all selected materials !';
			RETURN;
		END;
	END;

	SELECT
		F.CropCode AS 'Crop',
		T.BreedingStationCode AS 'BrStation',
		T.CountryCode AS 'Country',
		T.ImportLevel AS 'Level',
		TT.TestTypeCode AS 'TestType',
		T.TestID AS 'RequestID',
		'UTM' AS 'RequestingSystem',
		D.OriginID, --TMD.DeterminationID,
		M.MaterialID,
		M.MaterialKey,
		TMD.ExpectedDate AS 'ExpectedResultDate',
		TM.MaterialStatus
	FROM Test T
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN TestMaterialDetermination TMD ON TMD.TestID = T.TestID AND TMD.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
	LEFT JOIN TestMaterial TM ON TM.TestID = T.TestID AND TM.MaterialID = M.MaterialID
	WHERE T.TestID = @TestID

END
GO


