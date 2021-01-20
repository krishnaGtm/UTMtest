DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_EditSlot]
GO


/*
Author					Date			Description
Krishna Gautam			2019-Jul-24		Service created edit slot (nrofPlates and NrofTests).
Krishna Gautam			2019-Nov-19		Update new requested value and approved value on different field that is used for furhter process (if denied only deny new request of approved slot).
Krishna Gautam			2020-Nov-23		#16322:Update slot reservation to change planned date (expected date based on planned date) and change number of plates/tests.
Krishna Gautam			2020-Nov-23		#16339:Split plates and tests based on planned date and expected date respectively.
Binod Gurung			2021-Jan-19		#18479: Ignore AvailablePlates in case of Isolated slot
===================================Example================================

EXEC PR_PLAN_EditSlot 101,10,100,1,1
*/
CREATE PROCEDURE [dbo].[PR_PLAN_EditSlot]
(
	@SlotID INT,
	@NrOfPlates INT,
	@NrOfTests INT,
	@PlannedDate DATETIME NULL,
	@ExpectedDate DATETIME NULL,
	@Forced BIT,
	@Message NVARCHAR(MAX) OUT
)
AS
BEGIN
	
	DECLARE @TotalPlatesUsed INT, @TotalTestsUsed INT, @ActualPlates INT, @ActualTests INT, @TotalAvailablePlates INT, @TotalAvailableTests INT, @PlateProtocolID INT, @TestProtocolID INT, @PeriodID INT, @ReservedPlates INT, @ReservedTests INT,@NextPeriod INT,@NextPeriodEndDate DATETIME, @PeriodStartDate DATETIME, @Isolated BIT;
	DECLARE @Msg NVARCHAR(MAX),	@CurrentPeriodEndDate DATETIME, @ChangedPlannedPeriodID INT, @ChangedExpectedPeriodID INT;
	DECLARE @InRange BIT =1; --@TestInLims BIT;

	DECLARE @CurrentPlannedDate DATETIME, @CurrentExpectedDate DATETIME;

	--get period for provided slot. 
	SELECT @PeriodID = PeriodID, @Isolated = Isolated FROM Slot WHERE SlotID = @SlotID;

	IF(ISNULL(@PlannedDate,'') = '')
	BEGIN
		SELECT @PlannedDate = PlannedDate, @ExpectedDate = ExpectedDate FROM Slot WHERE SlotID = @SlotID;
	END

	--get changed period ID
	SELECT @ChangedPlannedPeriodID = PeriodID FROM [Period] WHERE @PlannedDate BETWEEN StartDate AND EndDate;
	SELECT @ChangedExpectedPeriodID = PeriodID FROM [Period] WHERE @ExpectedDate BETWEEN StartDate AND EndDate;

	--Check if planned date is changed and test linked to this slot is already sent to lims
	IF EXISTS (SELECT St.SlotID FROM SlotTest ST
			JOIN Test T ON T.TestID = ST.TestID
			WHERE ST.SlotID = @SlotID AND T.StatusCode > 400)
	BEGIN				
		SELECT @CurrentPlannedDate = PlannedDate FROM Slot WHERE SlotID = @SlotID;
		IF(CAST(@CurrentPlannedDate AS DATETIME) <> CAST(@PlannedDate AS DATETIME))
		BEGIN
			EXEC PR_ThrowError 'Plateplan/Test linked with this slot is already sent to LIMS. Cannot change planned date.';
			RETURN;
		END
	END

	IF(@PeriodID = @ChangedPlannedPeriodID)
	BEGIN
		UPDATE Slot SET PlannedDate = @PlannedDate, ExpectedDate = @ExpectedDate WHERE SlotID = @SlotID;
	END

	--if no period fould return error.
	IF(ISNULl(@PeriodID,0) = 0)
	BEGIN
		SET @Msg =N'Invalid slot.';
		EXEC PR_ThrowError @Msg;
	END

	IF(ISNULl(@PeriodID,0) = 0)
	BEGIN
		SET @Msg =N'Period not found for changed date.';
		EXEC PR_ThrowError @Msg;
	END

	--get current period end date to calculate whether slot updated is for current current period week + 1 week.
	SELECT TOP 1 @CurrentPeriodEndDate = EndDate
	FROM [Period]
	WHERE CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate;

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
	
	SELECT @ActualPlates = SUM(NrOfPlates)  FROM ReservedCapacity WHERE SlotID = @SlotID

	SELECT @ActualTests = SUM(NrOfTests)  FROM ReservedCapacity WHERE SlotID = @SlotID

	--Week range warning display only if the number of plates/tests is increased
	IF(@PeriodID <> @ChangedPlannedPeriodID OR (@PeriodStartDate < @NextPeriodEndDate AND (ISNULL(@NrOfPlates,0) > @ActualPlates OR ISNULL(@NrOfTests,0) > @ActualTests)))
	BEGIN
		SET @InRange = 0;
		IF(ISNULL(@Forced,0) = 0)
		BEGIN
			SET @Message = 'Week range is too short to update value or Slot is moving to next week. You need lab approval to apply this change. Do you want continue?';
			RETURN;
		END
	END
	
	IF(ISNULL(@ActualPlates,0) <> ISNULL(@NrOfPlates,0) OR ISNULL(@ActualTests,0) <> ISNULL(@NrOfTests,0) OR @PeriodID <> @ChangedPlannedPeriodID)
	BEGIN
		IF(@PeriodID <> @ChangedPlannedPeriodID)
		BEGIN
			IF EXISTS (SELECT * FROM SlotTest ST
			JOIN Test T ON T.TestID = ST.TestID
			WHERE ST.SlotID = @SlotID AND T.StatusCode > 400)
			BEGIN
				EXEC PR_ThrowError 'Plateplan/Test linked with this slot is already sent to LIMS. Cannot move slot to another week.';
				RETURN;
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM SlotTest ST
				JOIN Test T ON T.TestID = ST.TestID
				WHERE ST.SlotID = @SlotID)
				BEGIN
					EXEC PR_ThrowError 'PlatePlan/Test already linked to this slot. Either unlink test from this slot or change planned/expected date of test linked with this slot.';
					RETURN;
				END
			END
		END

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
		IF(@NrOfPlates < ISNULL(@ActualPlates,0) AND @NrOfTests < ISNULL( @ActualTests,0) AND (@PeriodID = @ChangedPlannedPeriodID))
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

		--SELECT @TotalAvailablePlates = MAX(NrOfPlates) FROM AvailCapacity WHERE TestProtocolID = @PlateProtocolID AND PeriodID = @PeriodID;
		SELECT @TotalAvailablePlates = MAX(NrOfPlates) FROM AvailCapacity WHERE TestProtocolID = @PlateProtocolID AND PeriodID = @ChangedPlannedPeriodID;

		--SELECT @TotalAvailableTests = MAX(NrOfTests) FROM AvailCapacity WHERE TestProtocolID = @TestProtocolID AND PeriodID = @PeriodID;
		SELECT @TotalAvailableTests = MAX(NrOfTests) FROM AvailCapacity WHERE TestProtocolID = @TestProtocolID AND PeriodID = @ChangedExpectedPeriodID;


		--SELECT @ReservedPlates = SUM(ISNULL(NrOfPlates,0)) FROM ReservedCapacity RC
		--JOIN Slot S ON S.SlotID = RC.SlotID  
		--WHERE TestProtocolID = @PlateProtocolID AND S.SlotID <> @slotID AND S.PeriodID = @PeriodID AND (S.StatusCode =200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfPlates,0)>0));
		SELECT @ReservedPlates = SUM(ISNULL(NrOfPlates,0)) FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID  
		WHERE TestProtocolID = @PlateProtocolID AND S.SlotID <> @slotID AND S.PeriodID = @ChangedPlannedPeriodID AND (S.StatusCode =200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfPlates,0)>0));

		--SELECT @ReservedTests = SUM(ISNULL(NrOfTests,0)) FROM ReservedCapacity RC
		--JOIN Slot S ON S.SlotID = RC.SlotID 
		--WHERE TestProtocolID = @TestProtocolID AND S.SlotID <> @SlotID AND S.PeriodID = @PeriodID AND (S.StatusCode = 200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfTests,0)>0));

		SELECT @ReservedTests = SUM(ISNULL(NrOfTests,0)) FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID 
		WHERE TestProtocolID = @TestProtocolID AND S.SlotID <> @SlotID AND S.PeriodID = @ChangedExpectedPeriodID AND (S.StatusCode = 200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfTests,0)>0));


		--can increase capacity if it is in range. 
		IF(@InRange = 1 
			AND (ISNULL(@TotalAvailablePlates,0) >= (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) OR @Isolated = 1) --ignore avail plates in case of isolated
			AND ISNULL(@TotalAvailableTests,0) >= (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
		BEGIN
		
			UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
			UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0

			IF(ISNULL(@PlannedDate,'') <> '')
				UPDATE Slot SET PlannedDate = @PlannedDate, PeriodID = @ChangedPlannedPeriodID WHERE SlotID = @SlotID;
			IF(ISNULL(@ExpectedDate,'') <> '')
				UPDATE Slot SET ExpectedDate = @ExpectedDate, PeriodID = @ChangedPlannedPeriodID WHERE SlotID = @SlotID;
			RETURN;
		END

		--if capacity is not in range and forced bit if false then return error message.
		IF((ISNULL(@TotalAvailablePlates,0) < (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) AND @Isolated = 0) --ignore avail plates in case of isolated
		OR ISNULL(@TotalAvailableTests,0) < (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
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
			--If lab approval is not needed
			IF(ISNULL(@InRange,0) > 0)
			--IF(ISNULL(@TestInLims,0) > 0)
			BEGIN
				IF(@ActualPlates <> @NrOfPlates)
					UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
				if(@ActualTests <> @NrOfTests)
					UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0
				
				--UPDATE SLOT						
				IF(ISNULL(@PlannedDate,'') <> '')
					UPDATE Slot SET PlannedDate = @PlannedDate,PeriodID = @ChangedPlannedPeriodID  WHERE SlotID = @SlotID;
				IF(ISNULL(@ExpectedDate,'') <> '')
					UPDATE Slot SET ExpectedDate = @ExpectedDate, PeriodID = @ChangedPlannedPeriodID WHERE SlotID = @SlotID;

				RETURN;
			END
			ELSE
			BEGIN
				--UPDATE RESERVE CAPACITY
				IF(@ActualPlates <> @NrOfPlates)
					UPDATE ReservedCapacity SET NewNrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND ISNULL(NrOfTests,0) = 0
				if(@ActualTests <> @NrOfTests)
					UPDATE ReservedCapacity SET NewNrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND ISNULL(NrOfPlates,0) = 0
				
				--UPDATE SLOT	
				UPDATE Slot SET StatusCode = 100 WHERE SlotID = @SlotID;				
				IF(ISNULL(@PlannedDate,'') <> '')
					UPDATE Slot SET PlannedDate = @PlannedDate, PeriodID = @ChangedPlannedPeriodID WHERE SlotID = @SlotID;
				IF(ISNULL(@ExpectedDate,'') <> '')
					UPDATE Slot SET ExpectedDate = @ExpectedDate, PeriodID = @ChangedPlannedPeriodID WHERE SlotID = @SlotID;
			END
		END
	END
END
GO


