DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_RequestSampleTestCallback]
GO

DROP TYPE IF EXISTS [TVP_DeterminationMaterial]
GO

CREATE TYPE [dbo].[TVP_DeterminationMaterial] AS TABLE(
	[OriginID] [int] NULL,
	[MaterialID] [int] NULL,
	[NrPlants] [int] NULL,
	[LimsRefID] [int] NULL
)
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
			TMD.InterfaceRefID = T.LimsRefID 
		FROM TestMaterialDetermination TMD
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID AND D.Source = 'StarLims'
		JOIN @TVPDeterminationMaterial T ON T.MaterialID = TMD.MaterialID AND T.OriginID = D.OriginID
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


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_ReceiveResults]
GO

DROP TYPE IF EXISTS [dbo].[TVP_RDTScore]
GO

CREATE TYPE [dbo].[TVP_RDTScore] AS TABLE(
	[OriginID] [int] NULL,
	[MaterialID] [int] NULL,
	[Score] [nvarchar](255) NULL
)
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
					
			INSERT INTO RDTTestResult(TestID, DeterminationID, MaterialID, Score, ResultStatus)
			SELECT @TestID, T1.OriginID, T1.MaterialID, T1.Score, 100		
			FROM @TVP_RDTScore T1
			JOIN Determination D ON D.OriginID = T1.OriginID AND D.Source = 'StarLims'
			JOIN TestMaterialDetermination TMD ON TMD.DeterminationID = D.DeterminationID AND TMD.MaterialID = T1.MaterialID
			WHERE TMD.TestID = @TestID
			GROUP BY T1.OriginID, T1.MaterialID, T1.Score;

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


