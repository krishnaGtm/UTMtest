/*

Authror					Date				Description
Binod Gurung			2018/01/20			This stored procedure is executed to fill plates in lims
KRIAHNA GAUTAM			2020/07/20			#14943 Validation added for preventing multiple sending of request.	
KRIAHNA GAUTAM			2020/10/19			#16324 Calculation of number of tests to 250

===========================Example=========================

EXEC PR_GetPlatesForLims 7605, 'KATHMANDU\binodg'
*/
ALTER PROCEDURE [dbo].[PR_GetPlatesForLims]
(
	@TestID	INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(100);
	DECLARE @ColumnLabel NVARCHAR(100) = 'plant name', @ImportLevel NVARCHAR(MAX);
	DECLARE @SlotStatus INT, @TestStatus INT;

	DECLARE @ReturnValue INT;
	DECLARE @DeadWellType INT =0, @MarkerAssigned INT =0
	

	SELECT @DeadWellType = WellTypeID 
	FROM WEllType WHERE WellTypeName = 'D'

	SELECT @SlotStatus = S.StatusCode FROM Slot S
	JOIN SlotTest ST ON ST.SlotID = S.SlotID
	JOIN Test T ON T.TestID = ST.TestID
	WHERE T.TestID = @TestID

	SELECT @TestStatus = StatusCode FROM Test WHERE TestID = @TestID;

	IF(ISNULL(@SlotStatus,0) <> 200)
	BEGIN
		EXEC PR_ThrowError N'Slot used for this test need to be approved from lab first.';
		RETURN;
	END

	IF(ISNULL(@TestStatus,0) >= 500)
	BEGIN
		EXEC PR_ThrowError N'Request is already sent to LIMS.';
		RETURN;
	END


	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Quota exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN;
	END

	--check maximum number of marker validation.(maximum number of tests 250)
	--#16324
	SELECT @MarkerAssigned = ISNULL(COUNT(DeterminationID),0)
	FROM 
	(
		SELECT T1.DeterminationID, T1.PlateID
		FROM
		(
			SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID 
			FROM TestMaterialDetermination TMD 
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
			WHERE P.TestID = @TestID AND W.WellTypeID <> @DeadWellType
		) T1
		GROUP BY T1.DeterminationID, T1.PlateID
	)T1
	
	IF(ISNULL(@MarkerAssigned,0) > 250)
	BEGIN
		EXEC PR_ThrowError N'Number of tests/marker should not be greater than 250. Unassign some marker before sending to LIMS.';
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
		LimsPlateplanID = ISNULL(T.LabPlatePlanID,0),
		RequestID = T.TestID,
		LimsPlateID = ISNULL(P.LabPlateID,0),
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

/*
Authror					Date				Description
Binod Gurung			2018/01/17			Pull Test Information
KRIAHNA GAUTAM			2020/07/20			#14943 Validation added for preventing multiple sending of request.	
KRIAHNA GAUTAM			2020/11/06			#16324 Calculation of number of tests to 250

===========================Example=========================
EXEC PR_GetTestInfoForLIMS 2084, 40
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
		EXEC PR_ThrowError N'Reservation Quta exceed for tests or plates. Unassign some markers or change slot for this test.';
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
			DATEPART(WEEK, T.PlannedDate)	AS PlannedWeek,
			MS.MaterialStateCode,
			MT.MaterialTypeCode,
			CT.ContainerTypeCode,
			ExpecdedYear = YEAR(T.ExpectedDate),
			ExpectedWeek = DATEPART(WEEK, T.ExpectedDate),
			@CountryCode					AS CountryCode,
			CONVERT(varchar(50), T.PlannedDate, 127) AS PlannedDate,
			CONVERT(varchar(50), T.ExpectedDate, 127) AS ExpectedDate
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