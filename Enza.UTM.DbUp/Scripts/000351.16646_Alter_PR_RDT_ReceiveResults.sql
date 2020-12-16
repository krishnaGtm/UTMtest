CREATE TYPE [dbo].[TVP_RDTScore] AS TABLE(
	[DeterminationID] [int] NULL,
	[MaterialID] [int] NULL,
	[Score] [nvarchar](255) NULL
)
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_ReceiveResults]
GO



CREATE PROCEDURE [dbo].[PR_RDT_ReceiveResults]
(
	@TestID INT,
	@TestFlowType INT,
	@TVP_RDTScore TVP_RDTScore READONLY
) AS

BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
					
			INSERT INTO RDTTestResult(TestID, DeterminationID, MaterialID, Score, ResultStatus, SusceptibilityPercent, MappingColumn)
			SELECT @TestID, D.DeterminationID, T1.MaterialID, T1.Score, 100, SusceptibilityPercent, ValueColumn	
			FROM @TVP_RDTScore T1
			JOIN Determination D ON D.OriginID = T1.OriginID AND D.Source = 'StarLims'
			JOIN TestMaterialDetermination TMD ON TMD.DeterminationID = D.DeterminationID AND TMD.MaterialID = T1.MaterialID
			WHERE TMD.TestID = @TestID
			GROUP BY D.DeterminationID, T1.MaterialID, T1.Score, T1.SusceptibilityPercent, T1.ValueColumn;

			UPDATE Test 
				SET StatusCode = 550, --Partially Received
					TestFlowType = @TestFlowType
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


