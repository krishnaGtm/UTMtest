IF TYPE_ID(N'TVP_RDTScore') IS NULL
BEGIN

	CREATE TYPE [dbo].[TVP_RDTScore] AS TABLE(
		[DeterminationID] [int] NULL,
		[MaterialID] [int] NULL,
		[Score] [nvarchar](255) NULL
	)

END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_ReceiveResults]
GO

CREATE PROCEDURE [dbo].[PR_RDT_ReceiveResults]
(
	@TestID INT,
	@TVP_RDTScore TVP_RDTScore READONLY
) AS

BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
					
			INSERT INTO RDTTestResult(TestID, DeterminationID, MaterialID, Score)
			SELECT @TestID, T1.DeterminationID, T1.MaterialID, T1.Score		
			FROM @TVP_RDTScore T1
			JOIN TestMaterialDetermination TMD ON TMD.DeterminationID = T1.DeterminationID AND TMD.MaterialID = T1.MaterialID
			WHERE TMD.TestID = @TestID
			GROUP BY T1.DeterminationID, T1.MaterialID, T1.Score;

			UPDATE Test 
				SET StatusCode = 550 --Partially Received
			WHERE TestID = @TestID;
			
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END

GO


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
		EXEC PR_ThrowError N'Expected result date is not filled for all materials.';
		RETURN;
	END
	
	--If List type is imported then check for materialstatus
	SELECT @ImportType = ImportLevel FROM Test WHERE TestID = @TestID;

	IF @ImportType = 'LIST'
	BEGIN

		IF EXISTS ( SELECT * FROM TestMaterial WHERE TestID = @TestID AND MaterialStatus IS NULL )
		BEGIN
			EXEC PR_ThrowError N'Material Status must be filled for LIST type.';
			RETURN;
		END
	END;

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


