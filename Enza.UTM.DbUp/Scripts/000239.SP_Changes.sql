
/*
Author					Date			Description
Krishna Gautam			2019-Jul-24		Service created edit slot (nrofPlates and NrofTests).

===================================Example================================

EXEC PR_PLAN_EditSlot 101,10,100,1,1
*/
ALTER PROCEDURE [dbo].[PR_PLAN_EditSlot]
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
			SET @Msg = CAST(@TotalPlatesUsed AS NVARCHAR(MAX)) + ' Plate(s) is already consumed by test. Cannot decrease the value.';
			EXEC PR_ThrowError @Msg;
			RETURN;
		END

		IF(ISNULL(@NrOfTests,0) < @TotalTestsUsed)
		BEGIN
			SET @Msg = +CAST(@TotalTestsUsed AS NVARCHAR(MAX)) + ' Marker(s) is already consumed by test. Cannot decrease the value.';
			EXEC PR_ThrowError @Msg;
			RETURN;
		END

		--if capacity is reduced and is within limit, allow it to reduce the value and return.
		IF(@NrOfPlates < ISNULL(@ActualPlates,0) AND @NrOfTests < ISNULL( @ActualTests,0))
		BEGIN
			UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND NrOfTests IS NULL
			UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
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
		WHERE TestProtocolID = @PlateProtocolID AND S.SlotID <> @slotID AND S.PeriodID = @PeriodID

		SELECT @ReservedTests = SUM(ISNULL(NrOfTests,0)) FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID 
		WHERE TestProtocolID = @TestProtocolID AND S.SlotID <> @SlotID AND S.PeriodID = @PeriodID;

		--can increase capacity if it is in range. 
		IF(@InRange = 1 AND ISNULL(@TotalAvailablePlates,0) >= (ISNULL(@ReservedPlates,0) + ISNULL(@NrOfPlates,0)) AND ISNULL(@TotalAvailableTests,0) >= (ISNULL(@ReservedTests,0) + ISNULL(@NrOfTests,0)))
		BEGIN
		
			UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND NrOfTests IS NULL
			UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
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
				SET @Msg = 'Some test linked with this slot was already sent to LIMS. Cannot increase the capacity of number of test or plate.';
				EXEC PR_ThrowError @Msg;
				RETURN;
			END
			UPDATE ReservedCapacity SET NrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND NrOfTests IS NULL
			UPDATE ReservedCapacity SET NrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
			UPDATE Slot SET StatusCode = 100 WHERE SlotID = @SlotID;
		END
	END
END

GO

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

		IF(@PlannedDate <> @CurrentPlannedDate OR @ExpectedDate <> @CurrentExpectedDate)
		BEGIN

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
		END	
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END

GO

--EXEC PR_PLAN_GetPlannedOverview 2018, 63
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlannedOverview]
(
	@Year			INT,
	@PeriodID		INT				= NULL
) AS BEGIN
SET NOCOUNT ON;

	DECLARE @MarkerTestProtocolID INT;
	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1;

	SELECT 
		P.PeriodID, 
		PeriodName = CONCAT(P.PeriodName, FORMAT(P.StartDate, ' (MMM-dd-yy - ', 'en-US' ), FORMAT(P.EndDate, 'MMM-dd-yy)', 'en-US' )),
		T1.*, 
		T2.TestProtocolName, 
		T3.BreedingStationCode, 
		T3.CropCode, 
		T3.RequestUser,
		T3.SlotName,
		CRD.CropName,
		UpdatePeriod = CAST(CASE WHEN ISNULL(T4.SlotID,0) = 0 THEN 1 ELSE 0 END AS BIT)
	FROM
	(
		SELECT T1.SlotID, MAX(ISNULL([Markers], 0)) As [Markers] , MAX(ISNULL([Plates], 0)) AS [Plates],Max(PlannedDate) AS PlanneDate,Max(ExpectedDate) AS ExpectedDate
		FROM 
		(
			SELECT SlotID, [Markers], [Plates],PlannedDate,ExpectedDate
			FROM
			(
				SELECT 
					S.SlotID, 
					NrOfTests, 
					NrOfPlates,
					Protocol1 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN 'Markers' ELSE 'Plates' END,
					Protocol2 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN 'Markers' ELSE 'Plates' END,
					S.PlannedDate,
					S.ExpectedDate
				FROM SLOT S
				JOIN ReservedCapacity RC ON RC.SlotID = S.SlotID
				JOIN TestProtocol TP On TP.TestProtocolID = RC.TestProtocolID
				JOIN [Period] P ON P.PeriodID = S.PeriodID
				WHERE StatusCode = 200 
				AND @Year BETWEEN DATEPART(YEAR, P.StartDate) AND DATEPART(YEAR, P.EndDate)
				AND (ISNULL(@PeriodID, 0) = 0 OR S.PeriodID = @PeriodID)
			) AS V1
			PIVOT 
			(
				SUM(NrOfTests)
				FOR Protocol1 IN ([Markers])
			) AS V2
			PIVOT 
			(
				SUM(NrOfPlates)
				FOR Protocol2 IN ([Plates])
			) AS V3
		) T1
		GROUP BY T1.SlotID
	) T1
	JOIN Slot T3 ON T3.SlotID = T1.SlotID
	LEFT JOIN
	(
		SELECT 
			RC.SlotID, 
			TP.TestProtocolID, 
			TP.TestProtocolName			 
		FROM ReservedCapacity RC 
		JOIN TestProtocol TP ON RC.TestProtocolID = TP.TestProtocolID
		WHERE RC.TestProtocolID <> @MarkerTestProtocolID
	) T2 ON T2.SlotID = T1.SlotID	
	LEFT JOIN
	(
		SELECT SlotID FROM SlotTest
		GROUP BY SlotID
	) T4 ON T4.SlotID = T1.SlotID
	JOIN [Period] P ON P.PeriodID = T3.PeriodID
	JOIN CropRD CRD ON CRD.CropCode = T3.CropCode
	ORDER BY T3.PeriodID, T3.BreedingStationCode, T3.CropCode;

END
GO