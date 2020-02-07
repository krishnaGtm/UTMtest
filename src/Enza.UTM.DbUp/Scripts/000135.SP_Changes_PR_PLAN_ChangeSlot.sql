
ALTER PROC [dbo].[PR_PLAN_ChangeSlot]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@ExpectedDate DATETIME
) 
AS BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @CurrentPlannedDate DATETIME, @CurrentExpectedDate DATETIME, @CurrentPeriodName NVARCHAR(100),@CurrentExpectedPeriodName NVARCHAR(100), @ChangedExpectedPeriodName NVARCHAR(100);
		--DECLARE @CurrentPeriod INT, 
		DECLARE @ChangedPeriod INT;
		DECLARE @InRange INT;
		
		IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
			EXEC PR_ThrowError 'Invalid slot';
			RETURN;
		END
		IF( @ExpectedDate < @PlannedDate) BEGIN
			EXEC PR_ThrowError 'Expected date should not be earlier than planned date.';
			RETURN;
		END
		--First we have to select before we update data for this stored procedure
		SELECT 
			@CurrentPeriodName = PeriodName, 
			@CurrentPlannedDate = PlannedDate,
			@CurrentExpectedDate = ExpectedDate
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;

		SELECT @CurrentExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @CurrentExpectedDate BETWEEN StartDate AND EndDate;

		SELECT @ChangedExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @ExpectedDate BETWEEN StartDate AND EndDate;


		--SELECT @CurrentPeriod = PeriodID
		--FROM Period WHERE @CurrentPlannedDate BETWEEN StartDate AND EndDate;
		
		SELECT @ChangedPeriod = PeriodID
		FROM Period WHERE @PlannedDate BETWEEN StartDate AND EndDate;

		--IF(ISNULL(@CurrentPeriod,0) = ISNULL(@ChangedPeriod,0)) BEGIN
		--	EXEC PR_ThrowError 'Cannot change planned date to same week.';
		--	RETURN;
		--END

		DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;

		--begin transaction here
		BEGIN TRAN
		
			EXEC PR_Validate_Capacity_Period_Protocol @SlotID, @PlannedDate, @AdditionalMarker OUT,  @AdditionalPlates OUT;

			UPDATE Slot 
				SET PlannedDate = CAST(@PlannedDate AS DATE), 
				ExpectedDate = CAST(@ExpectedDate AS DATE),
				PeriodID = @ChangedPeriod,
				StatusCode = 200
			WHERE SlotID = @SlotID;	
		COMMIT TRAN;

		SELECT 
			ReservationNumber = RIGHT('0000' + CAST(SlotID AS NVARCHAR(5)),5), 
			SlotName, 
			PeriodName = @CurrentPeriodName, 
			ChangedPeriodname = PeriodName, 
			PlannedDate = @CurrentPlannedDate,
			ChangedPlannedDate = PlannedDate,
			RequestUser,  
			ExpectedDate = @CurrentExpectedDate, 
			ChangedExpectedDate = ExpectedDate,
			CurrentExpectedPeriodName = @CurrentExpectedPeriodName,
			ChangedExpectedPeriodName = @ChangedExpectedPeriodName 
		FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID WHERE S.SlotID = @SlotID;
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END


GO


/*
EXEC PR_GetSlot_ForTest 80

*/
ALTER PROCEDURE [dbo].[PR_GetSlot_ForTest]
(
	--@User NVARCHAR(200),
	@TestID INT = NULL
	
)
AS BEGIN
	IF(ISNULL(@TestID,0)=0)BEGIN
		EXEC PR_ThrowError 'Invalid Test.';
		RETURN;	
	END
	ELSE BEGIN
		SELECT S.SlotID,S.SlotName FROM Slot S
		JOIN [Period] P ON P.PeriodID = S.PeriodID
		
		JOIN 
		(
			SELECT F.CropCode, T.* 
			FROM [File] F JOIN Test T ON T.FileID = F.FileID
			WHERE T.TestID = @TestID
		) AS T
		ON T.CropCode = S.CropCode 
		AND T.MaterialTypeID = S.MaterialTypeID 
		AND T.Isolated = S.Isolated
		AND T.BreedingStationCode = S.BreedingStationCode		
		WHERE S.StatusCode = 200 AND T.TestID = @TestID 
		AND CAST(T.PlannedDate AS DATE) BETWEEN CAST(P.StartDate AS DATE) AND CAST(P.EndDate AS DATE)
	END
END
GO