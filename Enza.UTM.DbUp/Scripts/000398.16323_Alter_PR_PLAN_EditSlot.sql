DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_EditSlot]
GO


/*
Author					Date			Description
Krishna Gautam			2019-Jul-24		Service created edit slot (nrofPlates and NrofTests).
Krishna Gautam			2019-Nov-19		Update new requested value and approved value on different field that is used for furhter process (if denied only deny new request of approved slot).

===================================Example================================

EXEC PR_PLAN_EditSlot 101,10,100,1,1
*/
CREATE PROCEDURE [dbo].[PR_PLAN_EditSlot]
(
	@SlotID INT,
	@NrOfPlates INT,
	@NrOfTests INT,
	@Forced BIT,
	@Message NVARCHAR(MAX) OUT
)
AS
BEGIN
	
	DECLARE @TotalPlatesUsed INT, @TotalTestsUsed INT, @ActualPlates INT, @ActualTests INT, @TotalAvailablePlates INT, @TotalAvailableTests INT, @PlateProtocolID INT, @TestProtocolID INT, @PeriodID INT, @ReservedPlates INT, @ReservedTests INT,@NextPeriod INT,@NextPeriodEndDate DATETIME, @PeriodStartDate DATETIME;
	DECLARE @Msg NVARCHAR(MAX),	@CurrentPeriodEndDate DATETIME;
	DECLARE @TestInLims BIT, @InRange BIT =1;

	--get period for provided slot. 
	SELECT @PeriodID = PeriodID FROM Slot WHERE SlotID = @SlotID;
	--if no period fould return error.
	IF(ISNULl(@PeriodID,0) = 0)
	BEGIN
		SET @Msg =N'Invalid slot.';
		EXEC PR_ThrowError @Msg;
	END

	--get current period end date to calculate whether slot updated is for current current period week + 1 week.
	SELECT TOP 1 @CurrentPeriodEndDate = EndDate
	FROM [Period]
	WHERE CAST(GETUTCDATE() AS DATE) BETWEEN StartDate AND EndDate;

	SELECT TOP 1 @NextPeriod = PeriodID,
		@NextPeriodEndDate = EndDate
	FROM [Period]
	WHERE StartDate > @CurrentPeriodEndDate
	ORDER BY StartDate;

	--check if next period is available to get next period end date.
	IF(ISNULL(@NextPeriod,0)=0) BEGIN
		EXEC PR_ThrowError 'Next Period Not found';
		RETURN;
	END

	SELECT @PeriodStartDate = StartDate
	FROM [Period] WHERE PeriodID = @PeriodID


	IF(@PeriodStartDate < @NextPeriodEndDate)
	BEGIN
		SET @InRange = 0;
		IF(ISNULL(@Forced,0) = 0)
		BEGIN
			SET @Message = 'Week range is too short to update value.You need lab approval to apply this change. Do you want continue?';
			RETURN;
		END
	END

	SELECT @ActualPlates = SUM(NrOfPlates)  FROM ReservedCapacity WHERE SlotID = @SlotID

	SELECT @ActualTests = SUM(NrOfTests)  FROM ReservedCapacity WHERE SlotID = @SlotID

	IF(ISNULL(@ActualPlates,0) <> ISNULL(@NrOfPlates,0) OR ISNULL(@ActualTests,0) <> ISNULL(@NrOfTests,0))
	BEGIN
		SELECT @TestInLims = CASE WHEN COUNT(T.TestID) > 0 THEN 1 ELSE 0 END
		FROM SlotTest ST
		JOIN Test T ON T.TestID = ST.TestID
		WHERE ST.SlotID = @SlotID AND T.StatusCode >= 400;

		SELECT @TotalPlatesUsed = ISNULL(COUNT(P.PlateID),0)
		FROM SlotTest ST 
		JOIN Test T ON ST.TestID = T.TestID
		JOIN Plate P ON P.TestID = T.TestID
		WHERE ST.SlotID = @SlotID;

		SELECT @TotalTestsUsed = ISNULL(COUNT(V2.DeterminationID),0)
		FROM
		(
			SELECT V.DeterminationID, V.PlateID
			FROM
			(
				SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID FROM TestMaterialDetermination TMD 
				JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
				JOIN Well W ON W.WellID = TMDW.WellID
				JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
				JOIN SlotTest ST ON ST.TestID = P.TestID
				WHERE ST.SlotID = @SlotID
		
			) V
			GROUP BY V.DeterminationID, V.PlateID
		) V2 ;


		IF(ISNULL(@NrOfPlates,0) < @TotalPlatesUsed)
		BEGIN
			SET @Msg = CAST(@TotalPlatesUsed AS NVARCHAR(MAX)) + ' Plate(s) is already consumed by Test(s). Value cannot be less than already consumed.';
			EXEC PR_ThrowError @Msg;
			RETURN;
		END

		IF(ISNULL(@NrOfTests,0) < @TotalTestsUsed)
		BEGIN
			SET @Msg = +CAST(@TotalTestsUsed AS NVARCHAR(MAX)) + ' Marker(s) is already consumed by Test(s). Value cannot be less than already consumed.';
			EXEC PR_ThrowError @Msg;
			RETURN;
		END

		--if capacity is reduced and is within limit, allow it to reduce the value and return.
		IF(@NrOfPlates < ISNULL(@ActualPlates,0) AND @NrOfTests < ISNULL( @ActualTests,0))
		BEGIN
			UPDATE ReservedCapacity SET 
				NrOfPlates = @NrOfPlates 
			WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) =0;

			UPDATE ReservedCapacity SET 
				NrOfTests = @NrOfTests 
			 WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) =0
			RETURN;
		END


		--if plate not null or greater than 0 then it is plateprotocolid.
		SELECT @PlateProtocolID = TestProtocolID 
		FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) <> 0 AND SlotID = @SlotID;

		--IF Plate is null then this is marker protocol
		SELECT @TestProtocolID = TestProtocolID 
		FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) = 0 AND SlotID = @SlotID; 

		SELECT @TotalAvailablePlates = MAX(NrOfPlates) FROM AvailCapacity WHERE TestProtocolID = @PlateProtocolID AND PeriodID = @PeriodID;

		SELECT @TotalAvailableTests = MAX(NrOfTests) FROM AvailCapacity WHERE TestProtocolID = @TestProtocolID AND PeriodID = @PeriodID;


		SELECT @ReservedPlates = SUM(ISNULL(NrOfPlates,0)) FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID  
		WHERE TestProtocolID = @PlateProtocolID AND S.SlotID <> @slotID AND S.PeriodID = @PeriodID AND (S.StatusCode =200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfPlates,0)>0));

		SELECT @ReservedTests = SUM(ISNULL(NrOfTests,0)) FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID 
		WHERE TestProtocolID = @TestProtocolID AND S.SlotID <> @SlotID AND S.PeriodID = @PeriodID AND (S.StatusCode = 200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfTests,0)>0));

		--can increase capacity if it is in range. 
		IF(@InRange = 1 AND ISNULL(@TotalAvailablePlates,0) >= (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) AND ISNULL(@TotalAvailableTests,0) >= (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
		BEGIN
		
			UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
			UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0
			RETURN;
		END

		--if capacity is not in range and forced bit if false then return error message.
		IF(ISNULL(@TotalAvailablePlates,0) < (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) OR ISNULL(@TotalAvailableTests,0) < (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
		BEGIN
			SET @InRange = 0;
			IF(ISNULl(@Forced,0) = 0)
			BEGIN
				SET @Message = 'Lab capacity is full. You need lab approval to apply this change. Do you want to continue?';
				RETURN;
			END
		END

		--IF(@Forced = 1 AND (ISNULL(@TotalAvailablePlates,0) < (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) OR ISNULL(@TotalAvailableTests,0) < (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0))))
		IF(@Forced = 1)
		BEGIN
			IF(ISNULL(@TestInLims,0) > 0)
			BEGIN
				
				IF(ISNULL(@NrOfPlates,0) <= @TotalPlatesUsed AND ISNULL(@NrOfTests,0) <= @TotalTestsUsed)
				BEGIN
					
					UPDATE ReservedCapacity SET NewNrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
					UPDATE ReservedCapacity SET NewNrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0
					
				END
				ELSE
				BEGIN
				
					SET @Msg = 'Some test linked with this slot was already sent to LIMS. Cannot increase the capacity of number of test or plate.';
					EXEC PR_ThrowError @Msg;
					
				END

				RETURN;
			END
			ELSE
			BEGIN
				UPDATE ReservedCapacity SET NewNrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
				UPDATE ReservedCapacity SET NewNrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0
				UPDATE Slot SET StatusCode = 100 WHERE SlotID = @SlotID;
			END
		END
	END
END
GO


