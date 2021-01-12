
/*
Authror					Date				Description
Binod Gurung			2018/01/17			Pull Test Information
KRIAHNA GAUTAM			2020/07/20			#14943 Validation added for preventing multiple sending of request.	
KRIAHNA GAUTAM			2020/11/06			#16324 Calculation of number of tests to 250
KRIAHNA GAUTAM			2021/01/12			#18426:Wrong week number is sent in planned week and expected week (now it is taken from Period table's week name)

===========================Example=========================
EXEC PR_GetTestInfoForLIMS 11654, 40
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
	DECLARE @SlotStatus INT, @TestStatus INT;
	
	SELECT @SlotStatus = S.StatusCode, @TestStatus = T.StatusCode FROM Slot S
	JOIN SlotTest ST ON ST.SlotID = S.SlotID
	JOIN Test T ON T.TestID = ST.TestID
	WHERE T.TestID = @TestID

	IF(ISNULL(@SlotStatus,0) <> 200)
	BEGIN
		EXEC PR_ThrowError N'Slot used for this test need to be approved from lab first.';
		RETURN;
	END

	IF(ISNULL(@TestStatus,0) >= 200)
	BEGIN
		EXEC PR_ThrowError N'Request is already sent to LIMS.';
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
		RETURN;
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
	IF(ISNULL(@TotalTests,0) = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one Marker/Determination.';
		RETURN;
	END

	IF(@TotalTests > 250)
	BEGIN
		EXEC PR_ThrowError N'Number of tests/marker should not be greater than 250. Unassign some marker before sending to LIMS.';
		RETURN;
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
			IsIsolated = CASE WHEN T.Isolated = 1 THEN 'Y' ELSE 'N' END,
			@CropCode						AS CropCode,
			PlannedWeek = CAST(RIGHT(MAX(PP.PeriodName),2) AS INT),
			MS.MaterialStateCode,
			MT.MaterialTypeCode,
			CT.ContainerTypeCode,
			ExpecdedYear = YEAR(T.ExpectedDate),
			ExpectedWeek = CAST(RIGHT(MAX(EP.PeriodName),2) AS INT),
			@CountryCode					AS CountryCode,
			CONVERT(varchar(50), T.PlannedDate, 127) AS PlannedDate,
			CONVERT(varchar(50), T.ExpectedDate, 127) AS ExpectedDate
	FROM Test T
	JOIN Plate P ON P.TestID = T.TestID
	LEFT JOIN MaterialState MS ON MS.MaterialStateID = T.MaterialStateID
	LEFT JOIN MaterialType MT ON MT.MaterialTypeID = T.MaterialTypeID
	LEFT JOIN ContainerType CT ON CT.ContainerTypeID = T.ContainerTypeID
	JOIN [Period] PP ON T.PlannedDate BETWEEN PP.StartDate AND PP.EndDate
	JOIN [Period] EP ON T.ExpectedDate BETWEEN EP.StartDate AND EP.EndDate
	WHERE T.TestID = @TestID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END
