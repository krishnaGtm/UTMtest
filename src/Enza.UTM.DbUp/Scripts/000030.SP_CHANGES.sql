
ALTER PROCEDURE [dbo].[PR_Save_SlotTest]
(
	@TestID INT,
	@UserID NVARCHAR(200),
	@SlotID INT
) AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnValue INT;
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

	BEGIN TRY
		
		IF EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode >= 200) BEGIN
			EXEC PR_ThrowError 'Cannot change slot after request is sent to LIMS.';
			RETURN;		
		END
		IF(ISNULL(@SlotID,0)= 0) BEGIN
			EXEC PR_ThrowError 'Invalid slot.';
			RETURN;	
		END

		IF NOT EXISTS( 
			SELECT T.TestID--,s.SlotID, T.MaterialStateID,S.MaterialStateID,T.MaterialTypeID,S.MaterialTypeID,T.Isolated, S.Isolated,T.MaterialStateId, S.MaterialStateID
			 FROM [File] F 
			JOIN Test T ON T.FileID = F.FileID
			JOIN Slot S ON F.CropCode = S.CropCode 
			JOIN [Period] P ON P.PeriodID = S.PeriodID

			WHERE 
			F.CropCode = S.CropCode
			AND T.MaterialTypeID = S.MaterialTypeID
			AND T.Isolated = S.Isolated
			AND T.BreedingStationCode = S.BreedingStationCode			
			AND S.StatusCode = 200 
			AND T.TestID = @TestID 
			AND S.SlotID = @SlotID
			AND CAST(T.PlannedDate AS DATE) BETWEEN CAST(P.StartDate AS DATE) AND CAST(P.EndDate AS DATE)
			) BEGIN

			EXEC PR_ThrowError 'Cannot link slot to test. Please check property of test.';
			RETURN;		

		END

		BEGIN TRAN;			
			
			IF EXISTS(SELECT TestID FROM SlotTest WHERE TestID = @TestID) BEGIN
				UPDATE SlotTest SET SlotID = @SlotID;
			END
			ELSE BEGIN
				INSERT INTO SlotTest(SlotID, TestID)
				VALUES(@SlotID, @TestID)	
			END			
			--UPdate test status to 150 meaning status changed from created to slot consumed.
			EXEC PR_Update_TestStatus @TestID, 150;

		COMMIT TRAN;
		--Get test detail
		EXEC PR_GetTestDetail @TestID, @UserID;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END
