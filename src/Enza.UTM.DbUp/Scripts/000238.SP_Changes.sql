DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_EditSlot]
GO

/*
Author					Date			Description
Krishna Gautam			2019-Jul-24		Service created edit slot (nrofPlates and NrofTests).

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
		
		IF NOT EXISTS (SELECT SlotID FROM Slot WHERE SlotID = @SlotID) BEGIN	
			EXEC PR_ThrowError 'Invalid slot';
			RETURN;
		END

		IF EXISTS(SELECT SlotID FROM SlotTest WHERE SlotID = @SlotID) BEGIN
			EXEC PR_ThrowError 'Slot is already assigned to some tests. Cannot move this slot to new planned date.';
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

			EXEC PR_PLAN_UpdateCapacitySlot @SlotID,300;			
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
	EXEC PR_GetPlatesForLims 87, 'KATHMANDU\binodg'

	Description: This stored procedure is executed to fill plates in lims
*/
ALTER PROCEDURE [dbo].[PR_GetPlatesForLims]
(
	@TestID	INT--,
	--@UserID	NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(100);
	DECLARE @ColumnLabel NVARCHAR(100) = 'plant name', @ImportLevel NVARCHAR(MAX);
	DECLARE @SlotStatus INT;

	DECLARE @ReturnValue INT;
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	SELECT @SlotStatus = S.StatusCode FROM Slot S
	JOIN SlotTest ST ON ST.SlotID = S.SlotID
	JOIN Test T ON T.TestID = ST.TestID
	WHERE T.TestID = @TestID

	IF(ISNULL(@SlotStatus,0) <> 200)
	BEGIN
		EXEC PR_ThrowError N'Slot used for this test need to be approved from lab first.';
		RETURN;
	END


	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Quota exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN;
	END
	--GET Plant Name
	DECLARE @PlantNrColumnID NVARCHAR(MAX), @SQL NVARCHAR(MAX);
	DECLARE @tbl TABLE
	(	
		MaterialID INT,
		PlantNr NVARCHAR(200)
	);

	SELECT @Source = RequestingSystem, @ImportLevel = ImportLevel FROM Test WHERE TestID = @TestID;
	IF(ISNULL(@Source, '') = 'Breezys') BEGIN
		SET @ColumnLabel = 	'Plantnr';	
	END
	IF(@ImportLevel = 'LIST') BEGIN
		SET @ColumnLabel = 	'GID';
	END
	SELECT DISTINCT
		@PlantNrColumnID =  QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	JOIN Test T ON T.FileID = F.FileID
	WHERE C.ColumLabel = @ColumnLabel
	AND T.TestID = @TestID
	--AND T.RequestingUser = @UserID;

	SET @SQL = N' SELECT MaterialID,' + @PlantNrColumnID + ' AS Plantnr  
		FROM 
		(
			SELECT 
				M.MaterialID, 
				C.ColumnID, 
				C.[Value]
			FROM [Cell] C
			JOIN [Column] C1 ON C1.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [File] F ON F.FileID = C1.FileID
			JOIN Test T ON T.FileID = F.FileID
			WHERE C1.ColumLabel = @ColumnLabel
			AND T.TestID = @TestID
			--AND T.RequestingUser = @UserID
		) SRC
		PIVOT
		(
			MAX([Value])
			FOR [ColumnID] IN (' + @PlantNrColumnID + ')
		) PV';

	INSERT INTO @tbl(MaterialID, PlantNr) 
	--EXEC sp_executesql @SQL, N'@TestID INT, @UserID	NVARCHAR(100), @ColumnLabel NVARCHAR(100)', @TestID, @UserID, @ColumnLabel;
	EXEC sp_executesql @SQL, N'@TestID INT, @ColumnLabel NVARCHAR(100)', @TestID, @ColumnLabel;

	--GET Well and Material Information
	SELECT
		F.CropCode,
		LimsPlateplanID = T.LabPlatePlanID,0,
		RequestID = T.TestID,
		LimsPlateID = P.LabPlateID,0,
		LimsPlateName = P.PlateName,
		PlateColumn = SUBSTRING(W.Position, 2, LEN(W.Position) - 1),
		PlateRow = LEFT(W.Position, 1),
		PlantNr = CASE WHEN M.Source = 'Breezys' THEN  RIGHT(M.MaterialKey, LEN(M.MaterialKey) - 2) ELSE M.MaterialKey END,
		PlantName = M2.PlantNr,
		T.BreedingStationCode
	FROM Plate P
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN Well W ON W.PlateID = P.PlateID
	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
	JOIN Material M ON M.MaterialID = TMDW.MaterialID
	JOIN @tbl M2 ON M2.MaterialID = M.MaterialID	
	WHERE T.TestID =  @TestID
	--AND T.RequestingUser = @UserID 
	AND WellTypeName !='D';


	--GET Markers information
	SELECT
		LimsPlateID = P.LabPlateID,
		D.DeterminationID AS MarkerNr, 
		MAX(D.DeterminationName) AS MarkerName
	FROM TestMaterialDetermination TMD
	JOIN Test T ON T.TestID = TMD.TestID
	JOIN Plate P ON P.TestID = T.TestID
	JOIN Well W ON W.PlateID = P.PlateID
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = TMD.MaterialID
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID  
	WHERE T.TestID =  @TestID
	GROUP BY P.LabPlateID,D.DeterminationID
	order by p.LabPlateID,D.DeterminationID
END
GO

-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/17
-- Description:	Pull Test Information
-- =============================================
/*
EXEC PR_GetTestInfoForLIMS 90, 40
*/
ALTER PROCEDURE [dbo].[PR_GetTestInfoForLIMS]
(
	@TestID INT,
	@MaxPlates INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SynCode VARCHAR(4), @CropCode VARCHAR(4), @CountryCode VARCHAR(4), @TotalTests INT, @Isolated BIT, @ReturnValue INT, @RemarkRequired BIT, @DeterminationRequired INT,@DeadWellType INT,@TotalPlates INT;
	DECLARE @SlotStatus INT;
	
	SELECT @SlotStatus = S.StatusCode FROM Slot S
	JOIN SlotTest ST ON ST.SlotID = S.SlotID
	JOIN Test T ON T.TestID = ST.TestID
	WHERE T.TestID = @TestID

	IF(ISNULL(@SlotStatus,0) <> 200)
	BEGIN
		EXEC PR_ThrowError N'Slot used for this test need to be approved from lab first.';
		RETURN;
	END

	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate WHERE TestID = @TestID;

	IF(@TotalPlates > @MaxPlates) BEGIN
		DECLARE @Error NVARCHAR(MAX) = 'Reservation of Plate failed. Maximum of '+ CAST(@MaxPlates AS NVARCHAR(10)) + ' plates can be reserved for test. ';
		EXEC PR_ThrowError @Error;
		RETURN;			
	END

	--check if total tests and plates falls within range of total marker and palates for this test
	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Qouta exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN 0;
	END


	SELECT TOP 1 
		@SynCode = T.SyncCode,  --return synccode if country code is not available.
		@CropCode = F.CropCode,
		@CountryCode = COALESCE(NULLIF(T.CountryCode, ''), T.SyncCode)
	FROM Test T 
	JOIN [File] F ON F.FileID = T.FileID
	WHERE T.TestID = @TestID
	  --AND T.RequestingUser = @UserID;

	SELECT @DeadWellType = WellTypeID 
	FROM WEllType WHERE WellTypeName = 'D'
	
	--Amount of tests per plate CUMULATED for ALL plates together
	SELECT @TotalTests = COUNT(V2.DeterminationID)
	FROM
	(
		SELECT V.DeterminationID, V.PlateID
		FROM
		(
			SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID FROM TestMaterialDetermination TMD 
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
			WHERE TMD.TestID = @TestID AND W.WellTypeID <> @DeadWellType
		
		) V
		GROUP BY V.DeterminationID, V.PlateID
	) V2 ;	
	
	SELECT  @RemarkRequired = TT.RemarkRequired, 
			@DeterminationRequired = TT.DeterminationRequired 
	FROM TestType TT
	JOIN Test T ON T.TestTypeID = TT.TestTypeID
	WHERE T.TestID = @TestID
	  --AND T.RequestingUser = @UserID;

	--For Test type with Remarkrequired true is DNA Isolation type. For DNA Isolation type, Isolated value is true
	IF(@RemarkRequired = 1)
		SET @Isolated = 1

	--Determination should be used for Test type with DeterminatonRequired true
	IF(@TotalTests = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one Marker/Determination.';
		RETURN 0;
	END

	--For DNA Isolation type Markers are not used. Dummy value -1 is sent for now. Should be changed later
	IF(@Isolated = 1)
		SET @TotalTests = -1;

	SELECT	YEAR(T.PlannedDate)				AS PlannedYear, 
			COUNT(P.PlateID)				AS TotalPlates, 
			@TotalTests						AS TotalTests, 
			@SynCode						AS SynCode, 
			T.Remark						AS Remark, 
			--@Isolated						AS Isolated, 
			IsIsolated = CASE WHEN T.Isolated = 1 THEN 'T' ELSE 'F' END,
			@CropCode						AS CropCode, 
			DATEPART(WEEK, T.PlannedDate)	AS PlannedWeek,
			MS.MaterialStateCode,
			MT.MaterialTypeCode,
			CT.ContainerTypeCode,
			ExpecdedYear = YEAR(T.ExpectedDate),
			ExpectedWeek = DATEPART(WEEK, T.ExpectedDate),
			@CountryCode					AS CountryCode
	FROM Test T
	JOIN Plate P ON P.TestID = T.TestID
	LEFT JOIN MaterialState MS ON MS.MaterialStateID = T.MaterialStateID
	LEFT JOIN MaterialType MT ON MT.MaterialTypeID = T.MaterialTypeID
	LEFT JOIN ContainerType CT ON CT.ContainerTypeID = T.ContainerTypeID	
	WHERE T.TestID = @TestID
	 --AND  T.RequestingUser = @UserID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END

GO