/*
	Author					Date			Description
-------------------------------------------------------------------
	Krishna Gautam							SP Created
	Krishna Gautam			2020-03-12		#10396: Do not increase capacity even when it cross max capacity planned for that week. (Remove SP call PR_Validate_Capacity_Period_Protocol inside this SP)
-------------------------------------------------------------------
*/
ALTER PROC [dbo].[PR_PLAN_ApproveSlot]
(
	@SlotID INT
) 
AS BEGIN
SET NOCOUNT ON;
	DECLARE @PlannedDate DATETIME,@AdditionalMarker INT,@AdditionalPlates INT;
	BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
				EXEC PR_ThrowError 'Invalid slot';
				RETURN;
			END
			SELECT @PlannedDate = PlannedDate from Slot WHERE SlotID = @SlotID;
			
			--#10396  
			--EXEC PR_Validate_Capacity_Period_Protocol @SlotID,@PlannedDate,@AdditionalMarker OUT,@AdditionalPlates OUT;
			--#10393 End

			EXEC PR_PLAN_UpdateCapacitySlot @SlotID,200;	
			
			UPDATE ReservedCapacity SET
				NrOfPlates = CASE WHEN ISNULL(NewNrOfPlates,0) > 0 THEN NewNrOfPlates ELSE NrOfPlates END,
				NrOfTests = CASE WHEN ISNULL(NewNrOfTests,0) > 0 THEN NewNrOfTests ELSE NrOfTests END,
				NewNrOfTests = 0,
				NewNrOfPlates = 0
			 WHERE SlotID = @SlotID;

		COMMIT TRAN;
		SELECT
			ReservationNumber = RIGHT('0000' + CAST(SlotID AS NVARCHAR(5)),5), 
			SlotName, 
			PeriodName, 
			ChangedPeriodname = PeriodName, 
			PlannedDate,
			ChangedPlannedDate = PlannedDate, 
			RequestUser, 
			ExpectedDate, 
			ChangedExpectedDate = ExpectedDate			
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
	Author					Date			Description
-------------------------------------------------------------------
	Krishna Gautam							SP Created
	Krishna Gautam			2020-03-12		#10396: Do not increase capacity even when it cross max capacity planned for that week. (Remove SP call PR_Validate_Capacity_Period_Protocol inside this SP)
-------------------------------------------------------------------
*/

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
		DECLARE @SlotLinkedToTest INT;
		
		IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
			EXEC PR_ThrowError 'Invalid slot';
			RETURN;
		END

		SELECT @SlotLinkedToTest = Count(TestID) FROM SlotTest WHERE SlotID = @SlotID;

		--IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) BEGIN
		--	EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot move this slot to new planned date.';
		--	RETURN;
		--END

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


		IF((@PlannedDate <> @CurrentPlannedDate OR @ExpectedDate <> @CurrentExpectedDate) AND ISNULL(@SlotLinkedToTest,0) <> 0)
		BEGIN
			EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot move this slot to new planned date.';
			RETURN;
		END

		SELECT @CurrentExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @CurrentExpectedDate BETWEEN StartDate AND EndDate;

		SELECT @ChangedExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @ExpectedDate BETWEEN StartDate AND EndDate;
		
		SELECT @ChangedPeriod = PeriodID
		FROM Period WHERE @PlannedDate BETWEEN StartDate AND EndDate;

		DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;

		--begin transaction here
		BEGIN TRAN
		
			--#10396
			--EXEC PR_Validate_Capacity_Period_Protocol @SlotID, @PlannedDate, @AdditionalMarker OUT,  @AdditionalPlates OUT;
			--#10396 END

			--Update slot status to 200
			UPDATE Slot 
				SET PlannedDate = CAST(@PlannedDate AS DATE), 
				ExpectedDate = CAST(@ExpectedDate AS DATE),
				PeriodID = @ChangedPeriod,
				StatusCode = 200
			WHERE SlotID = @SlotID;

			--update reservedCapacity if slot is pending due to edited value.
			UPDATE ReservedCapacity SET 
				NrOfPlates = NewNrOfPlates,
				NewNrOfPlates = 0
			 WHERE SlotID = @SlotID AND ISNULL(NewNrOfPlates,0) > 0

			 --update reservedCapacity if slot is pending due to edited value.
			 UPDATE ReservedCapacity SET 
				NrOfTests = NewNrOfTests,
				NewNrOfTests = 0
			 WHERE SlotID = @SlotID AND ISNULL(NewNrOfTests,0) > 0
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

