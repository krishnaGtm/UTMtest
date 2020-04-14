-- EXEC PR_PLAN_GetSlotsForBreeder 'To', 'NLEN', 'JAVRA\kgautam', 1, 200, ''
ALTER PROCEDURE [dbo].[PR_PLAN_GetSlotsForBreeder]
(
	@CropCode		NVARCHAR(10),
	@BrStationCode	NVARCHAR(50),
	@RequestUser	NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
)
AS BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Offset INT;
    DECLARE @WellType INT;

    SELECT @WellType = WelltypeID FROM WellType WHERE WellTypeName = 'D';

    SET @Offset = @PageSize * (@Page -1);
	
    SET @SQL = N';WITH CTE AS
    (
		SELECT 
			SlotID = S.SlotID,
			SlotName = MAX(S.SlotName),
			PeriodName = MAX(P.PeriodName2),
			CropCode = MAX(S.CropCode),
			BreedingStationCode = MAX(S.BreedingStationCode),
			MaterialTypeCode = MAX(MT.MaterialTypeCode),
			MaterialStateCode = MAX(MS.MaterialStateCode),
			RequestDate = MAX(S.RequestDate),
			PlannedDate = MAX(S.PlannedDate),
			ExpectedDate = MAX(S.ExpectedDate),
			Isolated = S.Isolated,
			StatusCode = MAX(S.StatusCode),
			StatusName = MAX(STA.StatusName),			
			[TotalPlates] =SUM(ISNULL(RC.NrOfPlates,0)),
			[TotalTests] =SUM(ISNULL(RC.NrOfTests,0)),
			[AvailablePlates] =SUM(ISNULL(RC.NrOfPlates,0)) - SUM(ISNULL(UsedPlates,0)),
			[AvailableTests] = SUM(ISNULL(RC.NrOfTests,0)) - SUM(ISNULL(UsedMarker,0)),
			UsedPlates = SUM(ISNULL(UsedPlates,0)),
			UsedMarker = SUM(ISNULL(UsedMarker,0))
		FROM Slot S
		JOIN VW_Period P ON P.PeriodID = S.PeriodID
		JOIN MaterialType MT ON MT.MaterialTypeID = S.MaterialTypeID
		JOIN MaterialState MS ON MS.MaterialStateID = S.MaterialStateID
		JOIN [Status] STA ON STA.StatusCode = S.StatusCode AND STA.StatusTable = ''Slot''
		LEFT JOIN
		(
			SELECT SlotID,NrOfTests = MAX(ISNULL(RC.NrOfTests,0)),
			NrOfPlates = MAX(ISNULL(RC.NrOfPlates,0)) FROM ReservedCapacity RC
			GROUP BY SlotID
		
		) RC ON RC.SlotID = S.SlotID
		LEFT JOIN 
		(

			SELECT SlotID, COUNT(DISTINCT P.PlateID) AS UsedPlates
			FROM SlotTest ST 
			JOIN Test T ON T.TestID = ST.TestID
			JOIN Plate P ON P.TestID = T.TestID
			GROUP BY SlotID
		) T1 ON T1.SlotID = S.SlotID
		LEFT JOIN 
		(
			SELECT SlotID, COUNT(DeterminationID) AS UsedMarker  FROM 
			(
				SELECT SlotID,T.TestID,P.PlateID,TMD.DeterminationID
				FROM SlotTest ST 
				JOIN Test T ON T.TestID = ST.TestID
				JOIN Plate P ON P.TestID = T.TestID			
				JOIN Well W ON W.PlateID = P.PlateID				
				JOIN TestMaterialDetermination TMD on TMD.TestID = T.TestID
				JOIN TestMaterialDeterminationWell TMDW oN Tmdw.MaterialID = TMD.MaterialID AND TMDW.WellID = W.WellID
				WHERE W.WellTypeID != @WellType
				GROUP BY ST.SlotID,T.TestID,P.PlateID,DeterminationID
			) V 
			GROUP BY SlotID
		  ) T2 ON T2.SlotID = S.SlotID
		  WHERE S.CropCode = @CropCode
		  AND S.BreedingStationCode = @BrStationCode
		  ' + CASE WHEN ISNULL(@Filter,'') <> '' THEN ' AND ' + @Filter ELSE '' END + N'	
	   GROUP BY S.SlotID, Isolated), CTE_COUNT AS (SELECT COUNT(SlotID) AS [TotalRows] FROM CTE
    )	
    SELECT 
	   CTE.SlotID, 
	   CTE.SlotName,
	   CTE.PeriodName,
	   CTE.CropCode,
	   CTE.BreedingStationCode,
	   CTE.MaterialTypeCode,
	   CTE.MaterialStateCode,
	   CTE.RequestDate,
	   CTE.PlannedDate,
	   CTE.ExpectedDate,
	   CTE.Isolated,
	   CTE.StatusCode,
	   CTE.StatusName,
	   CTE.[TotalPlates],
	   CTE.[TotalTests],
	   CTE.[AvailablePlates],
	   CTE.[AvailableTests],
	   CTE.UsedPlates,
	   CTE.UsedMarker,
	   S.RequestUser,
	   S.Remark,
	   CTE_COUNT.TotalRows 
    FROM CTE
    JOIN Slot S ON S.SlotID = CTE.SlotID
    CROSS APPLY CTE_COUNT
    ORDER BY PlannedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY';

    EXEC sp_executesql @SQL, N'@CropCode NVARCHAR(10), @BrStationCode NVARCHAR(50), @Offset INT, @PageSize INT, @WellType INT', @CropCode, @BrStationCode, @Offset, @PageSize, @WellType;
END
GO