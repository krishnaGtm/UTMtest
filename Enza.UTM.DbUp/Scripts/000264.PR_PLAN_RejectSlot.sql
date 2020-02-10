/*
	EXEC PR_PLAN_RejectSlot 8
*/
ALTER PROC [dbo].[PR_PLAN_RejectSlot]
(
	@SlotID INT
) 
AS BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @TestID INT;
		DECLARE @NrOftests INT, @NrOfPlates INT;
		BEGIN TRAN
			IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
				EXEC PR_ThrowError 'Invalid slot';
				RETURN;
			END

			IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) 
			BEGIN
				EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot reject this slot.';
				RETURN;
			END

			--EXEC PR_PLAN_UpdateCapacitySlot @SlotID,300;
			SELECT 
				@NrOftests = SUM(ISNULL(NewNrOfTests,0)),
				@NrOfPlates = SUM(ISNULL(NewNrOfPlates,0))
			FROM ReservedCapacity RC
			WHERE SLotID = @SlotID

			IF(ISNULL(@NrOfTests,0) > 0 OR ISNULL(@NrOfPlates,0) > 0)
			BEGIN
				UPDATE ReservedCapacity	SET 
					NewNrOfPlates = 0,
					NewNrOfTests = 0
				WHERE SlotID = @SlotID;
				
				UPDATE Slot SET StatusCode = 200 WHERE SlotID = @SlotID;
			END
			ELSE
			BEGIN
				EXEC PR_PLAN_UpdateCapacitySlot @SlotID,300;
			END

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
			
			EXEC PR_Validate_Capacity_Period_Protocol @SlotID,@PlannedDate,@AdditionalMarker OUT,@AdditionalPlates OUT;

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