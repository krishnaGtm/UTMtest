DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_GetMaterialForUpload]
GO


--EXEC PR_RDT_GetMaterialForUpload 10621;
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

	IF EXISTS(SELECT TestID FROM TestMaterialDetermination WHERE TestID = @TestID AND ISNULL(ExpectedDate,'') = '')
	BEGIN
		EXEC PR_ThrowError N'Expected result date is not filled for all materials.';
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
		TMD.DeterminationID,
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
	LEFT JOIN TestMaterial TM ON TM.TestID = T.TestID AND TM.MaterialID = M.MaterialID
	WHERE T.TestID = @TestID

END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_RequestSampleTestCallback]
GO

CREATE PROCEDURE [dbo].[PR_RDT_RequestSampleTestCallback]
(
	@TestID						INT,
	@FolderName					NVARCHAR(100),
	@TVPDeterminationMaterial	TVP_DeterminationMaterial READONLY

) AS BEGIN
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID)
	BEGIN
		EXEC PR_ThrowError N'Invalid test.';
		RETURN;
	END

	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode = 200)
	BEGIN
		EXEC PR_ThrowError N'Invalid test status.';
		RETURN;
	END

	BEGIN TRY
		BEGIN TRANSACTION;

		--fill NrPlants, InterfaceRefID
		UPDATE TMD
		SET TMD.NrPlants = T.NrPlants,
			TMD.InterfaceRefID = T.InterfaceRefID 
		FROM TestMaterialDetermination TMD
		JOIN @TVPDeterminationMaterial T ON T.MaterialID = TMD.MaterialID AND T.DeterminationID = TMD.DeterminationID
		WHERE TMD.TestID = @TestID

		--fill FolderName
		UPDATE Test 
		SET LabPlatePlanName = @FolderName,
			StatusCode		 = 500 --SendToLIMS
		WHERE TestID = @TestID

	COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH

END
GO


