ALTER TABLE ReservedCapacity
ADD NewNrOfPlates	INT;
GO

ALTER TABLE ReservedCapacity
ADD NewNrOfTests	INT;
GO

DROP TYPE IF EXISTS TVP_ReservedCapacity
GO

CREATE TYPE TVP_ReservedCapacity AS TABLE
(
    SlotID		INT,
    PeriodID		INT,
    TestProtocolID	INT,
    NrOfPlates		INT,
    NrOfTests		INT,
    StatusCode		INT
)
GO

/*
	DECLARE @Periods TVP_PLAN_Period;
	INSERT INTO @Periods VALUES(4765),(4766),(4767),(4768),(4769),(4770),(4771),(4772);
	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods
*/
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
(
	@Periods TVP_PLAN_Period READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);

	DECLARE @TCols1 NVARCHAR(MAX), @TCols2 NVARCHAR(MAX), @PCols1 NVARCHAR(MAX), @PCols2 NVARCHAR(MAX);
	SELECT 
		@TCols1 = COALESCE(@TCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@TCols2 = COALESCE(@TCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))'
	FROM TestProtocol TP
	JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
	WHERE Isolated = 0 
	AND TT.DeterminationRequired = 1;

	SELECT 
		@PCols1 = COALESCE(@PCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@PCols2 = COALESCE(@PCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))'
	FROM TestProtocol TP
	JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
	WHERE Isolated = 0 
	AND TT.DeterminationRequired = 0;

	--get current period
	DECLARE @CurrentPeriodID INT, @CurrentPeriodEndDate DATETIME;
	EXEC @CurrentPeriodID = PR_PLAN_GetCurrentPeriod;
	--get end date of current period
	SELECT @CurrentPeriodEndDate = EndDate FROM [Period] WHERE PeriodID = @CurrentPeriodID;

	DECLARE @TblReservedCapicity TVP_ReservedCapacity;
	INSERT @TblReservedCapicity(SlotID, PeriodID, TestProtocolID, NrOfPlates, NrOfTests, StatusCode)
	SELECT
	   T2.SlotID,
	   T2.PeriodID,
	   T1.TestProtocolID,
	   NrOfPlates = COALESCE(NULLIF(T1.NewNrOfPlates, 0), T1.NrOfPlates, 0),
	   NrOfTests = COALESCE( NULLIF(T1.NewNrOfTests, 0), T1.NrOfTests, 0),
	   T2.StatusCode
    FROM ReservedCapacity T1
    JOIN Slot T2 ON T2.SlotID = T1.SlotID 
    JOIN @Periods P ON P.PeriodID = T2.PeriodID;

	SET @SQL = N'	
	DECLARE @TBLPeriod TABLE(PeriodID INT, TestProtocolID INT);
	INSERT INTO @TBLPeriod (PeriodID, TestProtocolID)
	SELECT DISTINCT PeriodID, TestProtocolID 
	FROM @Periods P 
	CROSS JOIN TestProtocol TP
	WHERE TP.Isolated = 0;	

	DECLARE @ReservedCapacity TABLE(PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @NonReservedCapacity TABLE(SlotID INT, PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @MarkerTestProtocolID INT;

	--calculate slot wise detailed records
	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1;
	
	--Calculate sum of reserved capacity period and protocol wise
	INSERT INTO @ReservedCapacity(PeriodID, TestProtocolID, NrOfPlates, NrOfTests)
	SELECT 
		P.PeriodID, 
		TP.TestProtocolID, 
		ISNULL(NrOfPlates,0), 
		ISNULL(NrOfTests ,0)
	FROM TestProtocol TP
	JOIN @TBLPeriod P ON P.TestProtocolID = TP.TestProtocolID
	LEFT JOIN
	(
	   SELECT
		  T1.PeriodID,
		  T1.TestProtocolID,
		  NrOfPlates = SUM(T1.NrOfPlates),
		  NrOfTests = SUM(T1.NrOfTests)
	   FROM @TblReservedCapicity T1
	   WHERE T1.StatusCode = 200
	   GROUP BY T1.PeriodID, T1.TestProtocolID
	) T2 ON T2.TestProtocolID = TP.TestProtocolID AND P.PeriodID = T2.PeriodID
	WHERE TP.Isolated = 0;

	--Calculate sum of non reserved but requested capacity slot, period and protocol wise
	;WITH CTE AS 
	(
	   SELECT 
		  T1.PeriodID,
		  T1.SlotID,
		  T1.TestProtocolID,
		  NrOfPlates = SUM(T1.NrOfPlates),
		  NrOfTests = SUM(T1.NrOfTests)
	   FROM @TblReservedCapicity T1
	   WHERE T1.StatusCode = 100
	   GROUP BY T1.PeriodID, T1.SlotID, T1.TestProtocolID
	)
	INSERT INTO @NonReservedCapacity(PeriodID, SlotID, TestProtocolID, NrOfPlates, NrOfTests)
	SELECT 
		T1.PeriodID, 
		T1.SlotID, 
		T1.TestProtocolID, 
		SUM(T2.NrOfPlates), 
		SUM(T2.NrOfTests)
	FROM CTE T1
	JOIN CTE T2 ON T1.SlotID >= T2.SlotID AND T1.TestProtocolID = T2.TestProtocolID AND T1.PeriodID = T2.PeriodID
	GROUP BY T1.PeriodID, T1.SlotID, T1.TestProtocolID;

	--calculate and transpose slot test protocol wise

	;WITH CTE2 AS
	(
		 SELECT 
			T1.PeriodID,
			T1.SlotID, 
			T1.TestProtocolID, 
			TestProtocolID2 = T1.TestProtocolID,
			NrOfPlates = T1.NrOfPlates + T2.NrOfPlates, 
			NrOfTests = T1.NrOfTests + T2.NrOfTests
		 FROM @NonReservedCapacity T1
		 JOIN @ReservedCapacity T2 ON T2.PeriodID = T1.PeriodID AND T2.TestProtocolID = T1.TestProtocolID
	)
	SELECT 
		T4.PeriodID, 
		Plates = CASE 
				    WHEN ISNULL(T1.Plates, 0) <> ISNULL(RC.NrOfPlates, 0) THEN 
					   CAST(RC.NrOfPlates AS VARCHAR(10)) + '' ( '' + CAST((T1.Plates - RC.NrOfPlates) AS VARCHAR(10)) + '' )'' 
				    ELSE 
					   CAST(T1.Plates AS VARCHAR(10)) 
				END, 
		Markers = CASE 
				    WHEN ISNULL(T1.Markers, 0) <> ISNULL(RC.NrOfTests, 0) THEN 
					   CAST(RC.NrOfTests AS VARCHAR(10)) + '' ( '' + CAST((T1.Markers - RC.NrOfTests) AS VARCHAR(10)) + '' )'' 
				    ELSE 
					   CAST(T1.Markers AS VARCHAR(10)) 
				END, 
		T1.SlotID,
		' + @TCols1 + N',' + @PCols1  + N',
		T4.BreedingStationCode, 
		T4.CropCode, 
		T4.SlotName, 
		T4.RequestUser, 
		T3.TestProtocolName, 
		T4.PlannedDate, 
		T4.ExpectedDate,
	    TotalWeeks = 
	    (
		    SELECT 
			    COUNT(PP.PeriodID) 
		    FROM [Period] PP
		    WHERE PP.StartDate >  @CurrentPeriodEndDate
		    AND PP.EndDate <= 
		    (
			    SELECT TOP 1
				    PPP.EndDate 
			    FROM [Period] PPP
			    WHERE T4.PlannedDate BETWEEN PPP.StartDate AND PPP.EndDate
		    )
	    )
	FROM 
	(
		SELECT T1.SlotID, MAX(ISNULL([Plates], 0)) AS [Plates], MAX(ISNULL([Markers], 0)) As [Markers] 
		FROM 
		(
			SELECT SlotID, [Markers], [Plates]
			FROM
			(
				SELECT
				    	T1.SlotID, 
					T1.NrOfTests, 
					T1.NrOfPlates,
					Protocol1 = CASE WHEN T1.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END,
					Protocol2 = CASE WHEN T1.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END
				FROM @TblReservedCapicity T1
				WHERE T1.StatusCode = 100 
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
	JOIN Slot T4 ON T4.SlotID = T1.SlotID
	JOIN 
	(
	   SELECT 
		  SlotID,
		  NrOfPlates = SUM(T1.NrOfPlates),
		  NrOfTests = SUM(T1.NrOfTests)
	   FROM ReservedCapacity T1
	   GROUP BY T1.SlotID
    ) RC ON RC.SlotID = T1.SlotID
    LEFT JOIN
	(
		SELECT 
			RC.SlotID, 
			TP.TestProtocolID, 
			TP.TestProtocolName			 
		FROM ReservedCapacity RC 
		JOIN TestProtocol TP ON RC.TestProtocolID = TP.TestProtocolID
		WHERE RC.TestProtocolID <> @MarkerTestProtocolID
	) T3 ON T3.SlotID = T1.SlotID
	LEFT JOIN
	(
		 SELECT SlotID, ' + @TCols2 + N',' + @PCols2  + N' 
		 FROM
		 (
			  SELECT 
				   T3.SlotID,
				  ' + @TCols1 + N',' + @PCols1  + N'
			  FROM CTE2 T1
			  PIVOT
			  (
				   MAX(NrOfTests)
				   FOR TestProtocolID IN (' + @TCols1 + N')
			  ) AS T2
			  PIVOT
			  (
				   MAX(NrOfPlates)
				   FOR TestProtocolID2 IN (' + @PCols1 + N')
			  ) AS T3
		 ) V1
		 GROUP BY SlotID
	) T2 ON T2.SlotID = T1.SlotID
    ORDER BY T4.PeriodID, T1.SlotID'

EXEC sp_executesql @SQL, N'@CurrentPeriodEndDate DATETIME, @Periods TVP_PLAN_Period READONLY, @TblReservedCapicity TVP_ReservedCapacity READONLY', @CurrentPeriodEndDate, @Periods, @TblReservedCapicity;

END
GO

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
			UPDATE ReservedCapacity SET 
				NewNrOfPlates = @NrOfPlates 
			WHERE SlotID  = @SlotID AND NrOfTests IS NULL;
			UPDATE ReservedCapacity SET 
				NewNrOfTests = @NrOfTests 
			 WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
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
		
			UPDATE ReservedCapacity SET NewNrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND NrOfTests IS NULL
			UPDATE ReservedCapacity SET NewNrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
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
			UPDATE ReservedCapacity SET NewNrOfPlates = @NrOfPlates WHERE SlotID  = @SlotID AND NrOfTests IS NULL
			UPDATE ReservedCapacity SET NewNrOfTests = @NrOfTests WHERE SlotID  = @SlotID AND NrOfPlates IS NULL
			UPDATE Slot SET StatusCode = 100 WHERE SlotID = @SlotID;
		END
	END
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
 DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;
 EXEC @ReturnValue = PR_Validate_Capacity_Period_Protocol 145, '10-04-2018', @AdditionalMarker OUT,  @AdditionalPlates OUT
 PRINT @ReturnValue
 PRINT @AdditionalMarker
 PRINT @AdditionalPlates
*/

ALTER PROCEDURE [dbo].[PR_Validate_Capacity_Period_Protocol]
(
	@SlotID INT,
	@PlannedDate DATETIME,
	@AdditionalMarker INT OUT,
	@AdditionalPlates INT OUT
)
AS BEGIN
	DECLARE @PeriodID INT,@ProtocolID INT, @CapacityMarker INT, @CapacityPlates INT,@ReservedMarker INT, @ReservedPlates INT;
	DECLARE @RequiredMarker INT, @RequiredPlates INT;
	DECLARE @PlateProtocolID INT,@MarkerProtocolID INT;

	--if plate is greater not null or greater than 0 then it is plateprotocolid.
	SELECT @PlateProtocolID = TestProtocolID 
	FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) <> 0 AND SlotID = @SlotID;

	--IF Plate is null then this is marker protocol
	SELECT @MarkerProtocolID = TestProtocolID 
	FROM ReservedCapacity WHERE ISNULL(NrOFPlates,0) = 0 AND SlotID = @SlotID; 

	SELECT @PeriodID = PeriodID
	FROM [Period] WHERE CAST(@PlannedDate AS DATE) BETWEEN CAST(StartDate AS DATE) AND CAST(EndDate AS DATE);

	SELECT 
		@CapacityMarker =SUM(ISNULL(NrOfTests,0)),
		@CapacityPlates = SUM(ISNULL(NrOfPlates,0))
	FROM AvailCapacity 
	WHERE PeriodID = @PeriodID AND TestProtocolID IN (SELECT TestProtocolID FROM ReservedCapacity WHERE SlotID = @SlotID)

	SELECT 
		@ReservedMarker =SUM(ISNULL(NrOfTests,0))
	FROM ReservedCapacity RC
	JOIN Slot S ON  S.SlotID = RC.SlotID
	WHERE PeriodID = @PeriodID AND TestProtocolID IN (SELECT TestProtocolID FROM ReservedCapacity WHERE SlotID = @SlotID)
	AND (S.StatusCode = 200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfTests,0)>0))

	SELECT
		@ReservedPlates = SUM(ISNULL(NrOfPlates,0))
	FROM ReservedCapacity RC
	JOIN Slot S ON  S.SlotID = RC.SlotID
	WHERE PeriodID = @PeriodID AND TestProtocolID IN (SELECT TestProtocolID FROM ReservedCapacity WHERE SlotID = @SlotID)
	AND (S.StatusCode = 200 OR (S.StatusCode = 100 AND ISNULL(RC.NewNrOfPlates,0)>0))


	SELECT 
		@RequiredMarker = SUM(ISNULL(NrOfTests,0)),
		@RequiredPlates = SUM(ISNULL(NrOfPlates,0))
	FROM ReservedCapacity Where SlotID = @SlotID;
	
	SET @ReservedMarker = ISNULL(@ReservedMarker,0);
	SET @ReservedPlates = ISNULL(@ReservedPlates,0);

	SET @RequiredMarker = ISNULL(@RequiredMarker,0);
	SET @RequiredPlates = ISNULL(@RequiredPlates,0);

	SET @CapacityMarker = ISNULL(@CapacityMarker,0);
	SET @CapacityPlates = ISNULL(@CapacityPlates,0);
	
	IF( @RequiredMarker + @ReservedMarker > @CapacityMarker OR @RequiredPlates + @ReservedPlates > @CapacityPlates) BEGIN
		SET @AdditionalMarker = (@ReservedMarker + @RequiredMarker) - @CapacityMarker;
		SET @AdditionalPlates = (@RequiredPlates + @ReservedPlates) - @CapacityPlates;		

		IF (@AdditionalPlates > 0) BEGIN		
			UPDATE AvailCapacity
			SET NrOfPlates = NrOfPlates + ISNULL(@AdditionalPlates,0)
			WHERE PeriodID = @PeriodID AND TestProtocolID = @PlateProtocolID;
		END

		IF(@AdditionalMarker > 0) BEGIN
			UPDATE AvailCapacity
			SET NrOfTests = NrOfTests + ISNULL(@AdditionalMarker,0)
			WHERE PeriodID = @PeriodID AND TestProtocolID = @MarkerProtocolID;
		END

	END
END
GO

/*EXEC PR_PLAN_UpdateCapacitySlot 1, 100
*/
ALTER PROC [dbo].[PR_PLAN_UpdateCapacitySlot]
(
	@SlotID INT,
	@StatusCode INT
)
AS BEGIN
	--IF EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
		UPDATE Slot Set StatusCode = @StatusCode 
		WHERE SlotID = @SlotID;
	--END

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

		SELECT @CurrentExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @CurrentExpectedDate BETWEEN StartDate AND EndDate;

		SELECT @ChangedExpectedPeriodName = PeriodName FROM 
		[Period] WHERE @ExpectedDate BETWEEN StartDate AND EndDate;
		
		SELECT @ChangedPeriod = PeriodID
		FROM Period WHERE @PlannedDate BETWEEN StartDate AND EndDate;

		DECLARE @ReturnValue INT, @AdditionalMarker INT, @AdditionalPlates INT;

		--begin transaction here
		BEGIN TRAN
		
			EXEC PR_Validate_Capacity_Period_Protocol @SlotID, @PlannedDate, @AdditionalMarker OUT,  @AdditionalPlates OUT;

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

/*
DECLARE @IsSuccess BIT,@Message NVARCHAR(MAX);
EXEC PR_PLAN_Reserve_Capacity 'AUNA','LT',1,1,1,0,'2018-04-16 12:07:25.090','2018-05-15 12:07:25.090',20,20,'KATHMANDU\Krishna',0,@IsSuccess OUT,@Message OUT
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
	@IsSuccess BIT OUT,
	@Message NVARCHAR(MAX) OUT
)
AS
BEGIN
	--SELECT * FROM TEST
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @MarkerTypeTestProtocolID INT =0, @DNATypeTestProtocolID INT =0, @PeriodID INT,@InRange BIT = 1, @SlotID INT, @NextPeriod INT, @CurrentPeriodEndDate DATETIME,@NextPeriodEndDate DATETIME;
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
		WHERE CAST(GETUTCDATE() AS DATE) BETWEEN StartDate AND EndDate

		SELECT TOP 1 @PeriodID = PeriodID
		FROM [Period]
		WHERE @PlannedDate BETWEEN StartDate AND EndDate

 

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
		WHERE S.PeriodID = @PeriodID AND TestProtocolID = @MarkerTypeTestProtocolID AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NewNrOfTests,0) >0));

		SET @ReservedTests = ISNULL(@ReservedTests,0);
		
		--WHERE S.PeriodID = @PeriodID AND S.StatusCode = 200 AND TestProtocolID IS NULL

		--get reserved plates for selected material type and crop
		SELECT 
			@ReservedPlates = SUM(RC.NrOfPlates)
		FROM ReservedCapacity RC 
		JOIN Slot S ON S.SlotID = RC.SlotID
		WHERE S.PeriodID = @PeriodID AND TestProtocolID = @DNATypeTestProtocolID AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NrOfPlates,0) >0))

		SET @ReservedPlates = ISNULL(@ReservedPlates,0);
		

		--get total capacity (Test/Marker) per period only but to become to have data on db we added method.
		SELECT 
			@CapacityTests = NrOfTests
		FROM AvailCapacity
		WHERE PeriodID = @PeriodID AND TestProtocolID = @MarkerTypeTestProtocolID;

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

				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated)
				VALUES(@SlotName,@PeriodID,'200',@CropCode,@MaterialTypeID,@MaterialStateID,@User,GetUTCDate(),@PlannedDate,@ExpectedDate,@BreedingStationCode,@Isolated);

				SELECT @SlotID = SCOPE_IDENTITY();

				SET @IsSuccess = 1;
				SET @Message = 'Reservation for '+ @SlotName + ' is completed.';				
			END
			ELSE IF(@Forced = 1 AND @InRange = 0) BEGIN				
				--create logic here....				
				INSERT INTO Slot(SlotName, PeriodID, StatusCode, CropCode, MaterialTypeID, MaterialStateID, RequestUser, RequestDate, PlannedDate, ExpectedDate,BreedingStationCode,Isolated)
				VALUES(@SlotName,@PeriodID,'100',@CropCode,@MaterialTypeID,@MaterialStateID,@User,GetUTCDate(),@PlannedDate,@ExpectedDate,@BreedingStationCode,@Isolated);

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

-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/03/15
-- Description:	Get available plates tests
/*
DECLARE @DisplayPlannedWeek NVARCHAR(20),@ExpectedDate DateTime ,@DisplayExpectedWeek NVARCHAR(20),@AvailPlates INT,@AvailTests INT;

EXEC PR_PLAN_Get_Avail_Plates_Tests 2,'LT',0,'2018-03-30',@DisplayPlannedWeek OUT,@ExpectedDate OUT, @DisplayExpectedWeek OUT, @AvailPlates OUT, @AvailTests OUT;
PRINT @DisplayPlannedWeek;
PRINT @ExpectedDate;
PRINT @DisplayExpectedWeek;
PRINT @AvailPlates;
PRINT @AvailTests;

*/
-- =============================================
ALTER PROCEDURE [dbo].[PR_PLAN_Get_Avail_Plates_Tests]
(
	@MaterialTypeID INT,
	@CropCode NVARCHAR(10),
	@Isolated BIT,
	@PlannedDate DateTime,
	@DisplayPlannedWeek NVARCHAR(20) OUT,
	@ExpectedDate DateTime OUT,
	@DisplayExpectedWeek NVARCHAR(20) OUT,
	@AvailPlates INT OUT,
	@AvailTests INT OUT
)
AS
BEGIN

	SET NOCOUNT ON;
	--DECLARE @MarkerTypeTestProtocolID INT =0, @DNATypeTestProtocolID INT =0;
	DECLARE @PeriodID INT, @TotalPlates INT, @ReservedPlates INT, @TotalTests INT, @ReservedTests INT, @TestProtocolID INT;

	--get TestProtocolID for selected Material type and crop
	SELECT 
		@TestProtocolID = TestProtocolID
	FROM MaterialTypeTestProtocol
	WHERE MaterialTypeID = @MaterialTypeID AND CropCode = @CropCode


	IF(ISNULL(@TestProtocolID,0)=0) BEGIN
		EXEC PR_ThrowError 'No valid protocol found for selected material type and crop';
		RETURN;
	END
	
	SELECT 
		@PeriodID = PeriodID 
	FROM [Period] 
	WHERE @PlannedDate BETWEEN StartDate AND EndDate;

	IF(ISNULL(@PeriodID,0)=0) BEGIN
		EXEC PR_ThrowError 'No period found for selected planned date';
		RETURN;
	END


	
	--Total number of plates avail per period per method
	SELECT 
		@TotalPlates = NrOfPlates
	FROM AvailCapacity
	WHERE PeriodID = @PeriodID AND TestProtocolID = @TestProtocolID

	--Total number of tests avail per period
	SELECT DISTINCT
		@TotalTests = NrOfTests
	FROM AvailCapacity
	WHERE PeriodID = @PeriodID --AND NrOfTests IS NOT NULL

	
	--Reserved plates per period per method
	SELECT 
		@ReservedPlates = SUM(RC.NrOfPlates)
	FROM ReservedCapacity RC
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.PeriodID = @PeriodID AND RC.TestProtocolID = @TestProtocolID AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NewNrOfPlates,0) >0));	

	--Reserved tests per period
	SELECT 
		@ReservedTests = SUM(RC.NrOfTests)
	FROM ReservedCapacity RC
	JOIN Slot S ON S.SlotID = RC.SlotID
	WHERE S.PeriodID = @PeriodID  AND (S.StatusCode = 200 OR (S.StatusCode = 100  AND ISNULL(RC.NewNrOfTests,0) >0))

	--Default Expected Week is 2 Weeks later than Planned Week
	SET @ExpectedDate = DATEADD(week, 2, @PlannedDate);

	--Get display period for Planned date
	SELECT 
		@DisplayPlannedWeek = PeriodName + ' - ' + CAST(YEAR(@PlannedDate) AS NVARCHAR(10))
	FROM [Period] 
	WHERE @PlannedDate BETWEEN StartDate AND EndDate;

	--Get display period for Expected date
	SELECT 
		@DisplayExpectedWeek = PeriodName + ' - ' + CAST(YEAR(@ExpectedDate) AS NVARCHAR(10))
	FROM [Period] 
	WHERE @ExpectedDate BETWEEN StartDate AND EndDate;

	IF(@Isolated = 1) BEGIN
		SELECT  @AvailPlates = NULL,
				--@AvailTests = NULL;
				 @AvailTests = ISNULL(@TotalTests, 0) - ISNULL(@ReservedTests, 0);
	END
	ELSE BEGIN
		SELECT @AvailPlates = ISNULL(@TotalPlates, 0) - ISNULL(@ReservedPlates, 0),
			   @AvailTests = ISNULL(@TotalTests, 0) - ISNULL(@ReservedTests, 0);
	END
END
GO