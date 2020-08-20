DROP PROCEDURE IF EXISTS [dbo].[PR_Save_Score]
GO


CREATE PROCEDURE [dbo].[PR_Save_Score]
(
	@TestID INT,
	@TVP_ScoreResult TVP_ScoreResult READONLY
) AS

BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
					
			INSERT INTO TestResult(WellID, DeterminationID, ObsValueChar)
			SELECT W.WellID,T1.Determination, ScoreVal				
			FROM @TVP_ScoreResult T1
			JOIN Well W ON W.Position = T1.Position 
			JOIN Plate P ON P.PlateID = W.PlateID			
			WHERE P.LabPlateID = T1.LimsPlateID
			AND P.TestID = @TestID
			GROUP BY W.WellID, T1.Determination,T1.ScoreVal;

			--Update test status only when score exists
			IF EXISTS (SELECT TOP 1 ScoreVal FROM @TVP_ScoreResult)
			BEGIN
				UPDATE Test SET StatusCode = 600 WHERE TestID = @TestID;
			END;
			
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END

GO