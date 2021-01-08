
/*
Author					Date			Description
Krishna Gautam			2019-Jul-24		Service created edit slot (nrofPlates and NrofTests).
Krishna Gautam			2019-Nov-19		Update new requested value and approved value on different field that is used for furhter process (if denied only deny new request of approved slot).
Krishna Gautam			2020-Nov-23		#16322:Update slot reservation to change planned date (expected date based on planned date) and change number of plates/tests.
Krishna Gautam			2020-Nov-23		#16339:Split plates and tests based on planned date and expected date respectively.

===================================Example================================

EXEC PR_PLAN_EditSlot 101,10,100,1,1
*/
ALTER PROCEDURE [dbo].[PR_PLAN_EditSlot]
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
	
	DECLARE @TotalPlatesUsed INT, @TotalTestsUsed INT, @ActualPlates INT, @ActualTests INT, @TotalAvailablePlates INT, @TotalAvailableTests INT, @PlateProtocolID INT, @TestProtocolID INT, @PeriodID INT, @ReservedPlates INT, @ReservedTests INT,@NextPeriod INT,@NextPeriodEndDate DATETIME, @PeriodStartDate DATETIME;
	DECLARE @Msg NVARCHAR(MAX),	@CurrentPeriodEndDate DATETIME, @ChangedPlannedPeriodID INT, @ChangedExpectedPeriodID INT;
	DECLARE @InRange BIT =1; --@TestInLims BIT;

	DECLARE @CurrentPlannedDate DATETIME, @CurrentExpectedDate DATETIME;

	--get period for provided slot. 
	SELECT @PeriodID = PeriodID FROM Slot WHERE SlotID = @SlotID;

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
		IF(@InRange = 1 AND ISNULL(@TotalAvailablePlates,0) >= (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) AND ISNULL(@TotalAvailableTests,0) >= (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
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

/*
Authror					Date				Description
KRIAHNA GAUTAM								SP Created
KRIAHNA GAUTAM			2020-Mar-24			#11242: Change request to add remark.
KRIAHNA GAUTAM			2020-Nov-11			#16340: Date is taking timezone

DECLARE @IsSuccess BIT,@Message NVARCHAR(MAX);
EXEC PR_PLAN_Reserve_Capacity 'AUNA','LT',1,1,1,0,'2018-04-16 12:07:25.090','2018-05-15 12:07:25.090',20,20,'KATHMANDU\Krishna',0,'tt',@IsSuccess OUT,@Message OUT
PRINT @IsSuccess;
PRINT @Message;
*/

ALTER PROCEDURE [dbo].[PR_PLAN_Reserve_Capacity]
(
	@BreedingStationCode NVARCHAR(10),
	@CropCode NVARCHAR(10),
	@TestTypeID INT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@Isolated BIT,
	@PlannedDate DateTime,
	@ExpectedDate DateTime,
	@NrOfPlates INT,
	@NrOfTests INT,
	@User NVARCHAR(200),
	@Forced BIT,
	@Remark NVARCHAR(MAX),
	@IsSuccess BIT OUT,
	@Message NVARCHAR(MAX) OUT
)
AS
BEGIN
	--SELECT * FROM TEST
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @MarkerTypeTestProtocolID INT =0, @DNATypeTestProtocolID INT =0, @PeriodID INT,@InRange BIT = 1, @SlotID INT, @NextPeriod INT, @CurrentPeriodEndDate DATETIME,@NextPeriodEndDate DATETIME,@PeriodIDForTest INT;
		DECLARE @ReservedPlates INT =0, @ReservedTests INT=0, @CapacityPlates INT =0, @CapacityTests INT=0;
		DECLARE @MaxSlotID INT, @SlotName NVARCHAR(100);
		
		IF(ISNULL(@Isolated,0) = 0) BEGIN
			SELECT TOP 1 @DNATypeTestProtocolID = TestProtocolID 
			FROM MaterialTypeTestProtocol
			WHERE MaterialTypeID = @MaterialTypeID AND CropCode = @CropCode;
		END
		ELSE BEGIN
			SELECT TOP 1 @DNATypeTestProtocolID = TestProtocolID 
			FROM TestProtocol
			WHERE Isolated = 1;
		END


		IF EXISTS(SELECT TOP 1 TestTypeID FROM TestType WHERE TestTypeID = @TestTypeID AND DeterminationRequired = 1) BEGIN
			SELECT TOP 1 @MarkerTypeTestProtocolID = TestProtocolID 
			FROM TestProtocol
			WHERE TestTypeID = @TestTypeID;
		END
		
			
		SELECT TOP 1 @CurrentPeriodEndDate = EndDate
		FROM [Period]
		--WHERE CAST(GETUTCDATE() AS DATE) BETWEEN StartDate AND EndDate
		WHERE CAST(GETDATE() AS DATE) BETWEEN StartDate AND EndDate

		SELECT TOP 1 @PeriodID = PeriodID
		FROM [Period]
		WHERE @PlannedDate BETWEEN StartDate AND EndDate

		SELECT TOP 1 @PeriodIDForTest = PeriodID
		FROM [Period]
		WHERE @ExpectedDate BETWEEN StartDate AND EndDate

		IF(ISNULL(@DNATypeTestProtocolID,0)=0) BEGIN
			EXEC PR_ThrowError 'No valid protocol found for selected material type and crop';
			RETURN;
		END

		IF(ISNULL(@PeriodID,0)=0) BEGIN
			EXEC PR_ThrowError 'No period found for selected date';
			RETURN;
		END

		SELECT TOP 1 @NextPeriod = PeriodID,
		@NextPeriodEndDate = EndDate
		FROM [Period]
		WHERE StartDate > @CurrentPeriodEndDate
		ORDER BY StartDate;

		IF(ISNULL(@NextPeriod,0)=0) BEGIN
			EXEC PR_ThrowError 'No Next period found for selected date';
			RETURN;
		END

		IF(@PlannedDate  <= @NextPeriodEndDate) BEGIN			
			SET @InRange = 0;
			SET @IsSuccess = 0;
			SET @Message = 'Reservation time is too short. Do you want to request for reservation anyway?';
			IF(@Forced = 0)
				RETURN;
		END

		--get reserved tests if selected testtype is marker tests
		SELECT 
			@ReservedTests = SUM(RC.NrOfTests)
		FROM ReservedCapacity RC 
		JOIN Slot S ON S.SlotID = RC.SlotID
		JOIN [Period] P ON S.ExpectedDate BETWEEN P.StartDate AND P.EndDate
		WHERE P.PeriodID = @PeriodIDForTest AND TestProtocolID = @MarkerTypeTestProtocolID AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NewNrOfTests,0) >0));

		SET @ReservedTests = ISNULL(@ReservedTests,0);
		
		--WHERE S.PeriodID = @PeriodID AND S.StatusCode = 200 AND TestProtocolID IS NULL

		--get reserved plates for selected material type and crop
		SELECT 
			@ReservedPlates = SUM(RC.NrOfPlates)
		FROM ReservedCapacity RC 
		JOIN Slot S ON S.SlotID = RC.SlotID
		WHERE S.PeriodID = @PeriodID AND TestProtocolID = @DNATypeTestProtocolID AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NewNrOfPlates,0) >0))

		SET @ReservedPlates = ISNULL(@ReservedPlates,0);
		

		--get total capacity (Test/Marker) per period only but to become to have data on db we added method.
		SELECT 
			@CapacityTests = NrOfTests
		FROM AvailCapacity
		WHERE PeriodID = @PeriodIDForTest AND TestProtocolID = @MarkerTypeTestProtocolID;

		SET @CapacityTests = ISNULL(@CapacityTests,0);

		--Get Total capacity( plates) PER period PER Method.
		SELECT 
			@CapacityPlates = NrOfPlates
		FROM AvailCapacity
		WHERE PeriodID = @PeriodID AND TestProtocolID = @DNATypeTestProtocolID;

		SET @CapacityPlates = ISNULL(@CapacityPlates,0);

		--for isolated check no of test(markers) and ignore no of plates.
		IF(ISNULL(@Isolated,0) =1) BEGIN
			IF((@ReservedTests + @NrOfTests) > @CapacityTests) BEGIN
				SET @InRange = 0;
			END
		END
		--for marker test type protocol we have to check both no of plates and no of tests(markers)
		ELSE IF(ISNULL(@MarkerTypeTestProtocolID,0) <> 0) BEGIN			
			IF(((@ReservedTests + @NrOfTests) > @CapacityTests) OR ( (@ReservedPlates + @NrOfPlates) > @CapacityPlates)) BEGIN
				SET @InRange = 0;
			END
		END
		--for dna  test type protocol we have to check only no plates not no of tests(markers)		
		ELSE BEGIN			
			IF(@ReservedPlates + @NrOfPlates > @CapacityPlates) BEGIN
				SET @InRange = 0;
			END
		END

		--do not create data if not in range and forced bit is false.
		IF(@Forced = 0 AND @InRange = 0) BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Reservation quota is already occupied. Do you want to reserve this capacity anyway?';
			RETURN;
		END

		BEGIN TRANSACTION;
			SELECT @MaxSlotID = ISNULL(IDENT_CURRENT('Slot'),0) + 1
			FROM Slot;

			IF(ISNULL(@MaxSlotID,0) = 0) BEGIN
				SET @MaxSlotID = 1;
			END

			SET @SlotName = @BreedingStationCode + '-' + @CropCode + '-' + RIGHT('00000'+CAST(@MaxSlotID AS NVARCHAR(10)),5);
			--on this case create slot and reserved capacity data			
			IF(@InRange = 1) BEGIN
				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated, Remark)
				VALUES(@SlotName,@PeriodID,'200',@CropCode,@MaterialTypeID,@MaterialStateID,@User,GETDATE(),@PlannedDate,@ExpectedDate,@BreedingStationCode,@Isolated, @Remark);

				SELECT @SlotID = SCOPE_IDENTITY();

				SET @IsSuccess = 1;
				SET @Message = 'Reservation for '+ @SlotName + ' is completed.';				
			END
			ELSE IF(@Forced = 1 AND @InRange = 0) BEGIN				
				--create logic here....				
				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated,Remark)
				VALUES(@SlotName, @PeriodID, '100', @CropCode, @MaterialTypeID, @MaterialStateID, @User, GETDATE(), @PlannedDate, @ExpectedDate, @BreedingStationCode, @Isolated, @Remark);

				SELECT @SlotID = SCOPE_IDENTITY();	

				SET @IsSuccess = 1;
				SET @Message = 'Your request for '+ @SlotName + ' is pending. You will get notification after action from LAB.';		
			END

			--create reserve capacity here based on two protocols
			IF(ISNULL(@MarkerTypeTestProtocolID,0) <> 0) BEGIN
				INSERT INTO ReservedCapacity(SlotID, TestProtocolID, NrOfTests)
				VALUES(@SlotID,@MarkerTypeTestProtocolID,@NrOfTests);
			END
			INSERT INTO ReservedCapacity(SlotID, TestProtocolID, NrOfPlates)
			VALUES(@SlotID,@DNATypeTestProtocolID,@NrOfPlates);
						

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH

END

GO
