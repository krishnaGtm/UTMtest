DROP TYPE IF EXISTS [dbo].[TVP_AvailCapacitySlotWise]
GO

CREATE TYPE [dbo].[TVP_AvailCapacitySlotWise] AS TABLE(
	[SlotID] [int] NULL,
	[PlannedCapacityPlates] [int] NULL,
	[PlannedCapacityTests] [int] NULL,
	[ExpectedCapacityPlates] [int] NULL,
	[ExpectedCapacityTests] [int] NULL
)
GO


DROP FUNCTION IF EXISTS [dbo].[FN_PLAN_GetReservedCapacityByPeriodsQuery]
GO


/*
	DECLARE @SQL NVARCHAR(MAX) = dbo.FN_PLAN_GetReservedCapacityByPeriodsQuery_New();
	EXEC sp_executesql @SQL;
	PRINT @SQL
*/
CREATE FUNCTION [dbo].[FN_PLAN_GetReservedCapacityByPeriodsQuery]()
RETURNS NVARCHAR(MAX)
AS BEGIN
	DECLARE @TCols1 NVARCHAR(MAX), @TCols2 NVARCHAR(MAX),@PCols1 NVARCHAR(MAX), @PCols2 NVARCHAR(MAX);
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

	IF(ISNULL(@PCols2,'')= '' OR ISNULL(@TCols2,'')= '') BEGIN		
		RETURN '';
	END


	DECLARE @SQL NVARCHAR(MAX);
	--SET @SQL = N'SELECT * FROM
	--(
	--	SELECT PeriodID, ' + @TCols2 + ',' +  @PCols2 + N' 
	--	FROM
	--	(
	--		SELECT * FROM
	--		(
	--			SELECT
	--				T2.PeriodID,
	--				T1.TestProtocolID,
	--				TestProtocolID2 = TestProtocolID,
	--				NrOfTests = SUM(T1.NrOfTests),
	--				NrOfPlates = SUM(T1.NrOfPlates)
	--			FROM ReservedCapacity T1
	--			JOIN Slot T2 ON T2.SlotID = T1.SlotID 
	--			WHERE T2.StatusCode = 200
	--			GROUP BY T2.PeriodID, T1.TestProtocolID
	--		) V1
	--		PIVOT
	--		(
	--			MAX(NrOfTests)
	--			FOR TestProtocolID IN (' + @TCols1 + N')
	--		) AS V2
	--		PIVOT
	--		(
	--			MAX(NrOfPlates)
	--			FOR TestProtocolID2 IN (' + @PCols1 + N')
	--		) AS V4
	--	) V5
	--	GROUP BY PeriodID
	--) AS V';

	--	SET @SQL = N'SELECT * FROM
	--(
	--	SELECT PeriodID = PlannedPeriod, ExpectedPeriod = MAX(ExpectedPeriod), ' + @TCols2 + ',' +  @PCols2 + N' 
	--	FROM
	--	(
	--		SELECT * FROM     
	--		(      
	--			SELECT 
	--				PlannedPeriod, 
	--				ExpectedPeriod = MAX(ExpectedPeriodID), 
	--				NrOfPlates = SUM(NrOfPlates), 
	--				NrOfTests = SUM(NrOfTests),
	--				TestProtocolID,
	--				TestProtocolID2 = TestProtocolID
	--			FROM       
	--			(      
	--				SELECT       
	--					PlannedPeriod = T2.PeriodID,       
	--					T2.slotID,       
	--					ExpectedPeriodID = P.PeriodID,       
	--					T1.TestProtocolID,  
					
	--					NrOfTests =  CASE WHEN T2.ExpectedDate BETWEEN P.StartDate and P.EndDate THEN 0 ELSE T1.NrOfTests END,   
	--					NrOfPlates = CASE WHEN T2.PlannedDate BETWEEN P.StartDate AND P.EndDate THEN 0 ELSE T1.NrOfPlates END
	--				FROM ReservedCapacity T1     
	--				JOIN Slot T2 ON T2.SlotID = T1.SlotID      
	--				JOIN [Period] P ON (T2.ExpectedDate BETWEEN P.StartDate and P.EndDate) OR (T2.PlannedDate BETWEEN P.StartDate AND P.EndDate)     
	--				WHERE T2.StatusCode = 200      
	--			) T      
	--		GROUP BY PlannedPeriod,TestProtocolID     
	--		) V1
	--		PIVOT
	--		(
	--			MAX(NrOfTests)
	--			FOR TestProtocolID IN (' + @TCols1 + N')
	--		) AS V2
	--		PIVOT
	--		(
	--			MAX(NrOfPlates)
	--			FOR TestProtocolID2 IN (' + @PCols1 + N')
	--		) AS V4
	--	) V5
	--	GROUP BY PlannedPeriod
	--) AS V
	-- WHERE PeriodID IN (SELECT PeriodID FROM @Periods) OR ExpectedPeriod IN (SELECT PeriodID FROM @Periods)';


	SET @SQL = N'
	SELECT * FROM
	(
		SELECT PeriodID = PlannedPeriod, ' + @TCols2 + ',' +  @PCols2 + N' 
		FROM
		(
			SELECT * FROM     
			(      
				SELECT 
					PlannedPeriod,
					NrOfPlates = SUM(NrOfPlates), 
					NrOfTests = SUM(NrOfTests),
					TestProtocolID,
					TestProtocolID2 = TestProtocolID
				FROM       
				(      
					SELECT       
						PlannedPeriod = T2.PeriodID,       
						T2.slotID,
						T1.TestProtocolID,
						NrOfTests =  0,   
						NrOfPlates = T1.NrOfPlates
					FROM ReservedCapacity T1     
					JOIN Slot T2 ON T2.SlotID = T1.SlotID
					JOIN [Period] P ON P.PeriodID = T2.PeriodID
					WHERE T2.StatusCode = 200      
				) T      
			GROUP BY PlannedPeriod,TestProtocolID     
			) V1
			PIVOT
			(
				MAX(NrOfTests)
				FOR TestProtocolID IN (' + @TCols1 + N')
			) AS V2
			PIVOT
			(
				MAX(NrOfPlates)
				FOR TestProtocolID2 IN (' + @PCols1 + N')
			) AS V3
			UNION
			SELECT * FROM     
			(      
				SELECT 
					PlannedPeriod,
					NrOfPlates = SUM(NrOfPlates), 
					NrOfTests = SUM(NrOfTests),
					TestProtocolID,
					TestProtocolID2 = TestProtocolID
				FROM       
				(      
					SELECT       
						PlannedPeriod = P.PeriodID,       
						T2.slotID,
						T1.TestProtocolID,
						NrOfTests = T1.NrOfTests,   
						NrOfPlates = 0
					FROM ReservedCapacity T1     
					JOIN Slot T2 ON T2.SlotID = T1.SlotID 
					JOIN [Period] P ON (T2.ExpectedDate BETWEEN P.StartDate and P.EndDate)
					WHERE T2.StatusCode = 200      
				) T1      
			GROUP BY PlannedPeriod,TestProtocolID     
			) V4
			PIVOT
			(
				MAX(NrOfTests)
				FOR TestProtocolID IN (' + @TCols1 + N')
			) AS V5
			PIVOT
			(
				MAX(NrOfPlates)
				FOR TestProtocolID2 IN (' + @PCols1 + N')
			) AS V6

		) V7
		GROUP BY PlannedPeriod
	) AS V
	 WHERE PeriodID IN (SELECT PeriodID FROM @Periods)';

	RETURN @SQL;
END 
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
GO

/*
	DECLARE @PeriodID INT;
	DECLARE @Periods TVP_PLAN_Period;

	--EXEC @PeriodID = PR_PLAN_GetCurrentPeriod;
	SET @PeriodID =4844
	INSERT INTO @Periods(PeriodID)
	SELECT TOP 5 
		PeriodID
	FROM [Period] 
	WHERE PeriodID < @PeriodID
	ORDER BY PeriodID DESC;

	INSERT INTO @Periods(PeriodID) 
	SELECT TOP 13 
		PeriodID
	FROM [Period] 
	WHERE PeriodID >= @PeriodID
	ORDER BY PeriodID;
	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods
*/
CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListBySlotForLAB]
(
	@Periods TVP_PLAN_Period READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);

	DECLARE @TCols1 NVARCHAR(MAX), @TCols2 NVARCHAR(MAX), @PCols1 NVARCHAR(MAX), @PCols2 NVARCHAR(MAX);
	DECLARE @TCols3 NVARCHAR(MAX), @TCols4 NVARCHAR(MAX), @PCols3 NVARCHAR(MAX),@PCols4 NVARCHAR(MAX); 

	SELECT 
		@TCols1 = COALESCE(@TCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@TCols2 = COALESCE(@TCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))',
		@TCols3 = COALESCE(@TCols3 + ',', '') + CAST(TestProtocolID AS NVARCHAR(MAX)),
		@TCols4 = COALESCE(@TCols4 + ',', '') +'NULLIF('+QUOTENAME(TestProtocolID) + ',0)'
	FROM TestProtocol TP
	JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
	WHERE Isolated = 0 
	AND TT.DeterminationRequired = 1;

	SELECT 
		@PCols1 = COALESCE(@PCols1 + ',', '') + QUOTENAME(TestProtocolID),
		@PCols2 = COALESCE(@PCols2 + ',', '') + QUOTENAME(TestProtocolID) + ' = ' + 'MAX(ISNULL(' + QUOTENAME(TestProtocolID) + ', 0))',		
		@PCols3 = COALESCE(@PCols3 + ',', '') + CAST(TestProtocolID AS NVARCHAR(MAX)),
		@PCols4 = COALESCE(@PCols4 + ',', '') +'NULLIF('+QUOTENAME(TestProtocolID) + ',0)'
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
	DECLARE @TblReservedCapacityTemp TVP_ReservedCapacity;

	DECLARE @AvailCapacitySlotWise TVP_AvailCapacitySlotWise;
	
	INSERT INTO @AvailCapacitySlotWise(SlotID, PlannedCapacityPlates, PlannedCapacityTests, ExpectedCapacityPlates,ExpectedCapacityTests)
	SELECT 
		T.SlotID, 
		PCPlates = MAX( PC.NrOfPlates ), 
		PCTests = MAX( PC.NrOfTests), 
		ECPlates = MAX(EC.NrOfPlates), 
		ECTests = MAX(EC.NrOfTests)  
	FROM
	(
		SELECT  RC.SlotID, RC.TestProtocolID, PeriodID = MAX(S.PeriodID), PPID = MIN(PP.PeriodID), EPID =  MAX(PP.PeriodID)
		FROM ReservedCapacity RC
		JOIN Slot S ON S.SlotID = RC.SlotID
		JOIN [Period] PP ON PP.PeriodID = S.PeriodID OR S.ExpectedDate BETWEEN PP.Startdate AND PP.EndDate
		JOIN @Periods P1 ON P1.PeriodID = S.PeriodID
		GROUP BY RC.TestProtocolID, RC.SlotID
	) T
	JOIN AvailCapacity PC ON PC.PeriodID = T.PPID AND PC.TestProtocolID = T.TestProtocolID 
	JOIN AvailCapacity EC ON EC.PeriodID = T.EPID AND EC.TestProtocolID = T.TestProtocolID
	GROUP BY T.SlotID

	INSERT @TblReservedCapacityTemp(SlotID, PeriodID, TestProtocolID, NrOfPlates, StatusCode)
	SELECT
	   T2.SlotID,
	   T2.PeriodID,
	   T1.TestProtocolID,
	   NrOfPlates = COALESCE(NULLIF(T1.NewNrOfPlates, 0), T1.NrOfPlates, 0),
	   T2.StatusCode
    FROM ReservedCapacity T1
    JOIN Slot T2 ON T2.SlotID = T1.SlotID 
    JOIN @Periods P ON P.PeriodID = T2.PeriodID;

	INSERT @TblReservedCapacityTemp(SlotID, PeriodID, TestProtocolID, NrOfTests, StatusCode)
	SELECT
	   T2.SlotID,
	   P.PeriodID,
	   T1.TestProtocolID,
	   NrOfTests = COALESCE( NULLIF(T1.NewNrOfTests, 0), T1.NrOfTests, 0),
	   T2.StatusCode
    FROM ReservedCapacity T1
    JOIN Slot T2 ON T2.SlotID = T1.SlotID 
	JOIN [Period] P ON T2.ExpectedDate BETWEEN P.StartDate AND P.EndDate
    JOIN @Periods P1 ON P1.PeriodID = P.PeriodID;

	INSERT  @TblReservedCapicity(SlotID, PeriodID, TestProtocolID, NrOfTests, NrOfPlates, StatusCode)
	SELECT SlotID, PeriodID, TestProtocolID, NrOfTests = MAX(NrOfTests), MAX(NrOfPlates), MAX(StatusCode)
	FROM @TblReservedCapacityTemp 
	GROUP BY SlotID,PeriodID, TestProtocolID;

	

	SET @SQL = N'	
	DECLARE @TBLPeriod TABLE(PeriodID INT, TestProtocolID INT);
	DECLARE @AvailCapacity TABLE(PeriodID INT, TestProtocolID INT, Capacity INT); 
	INSERT INTO @TBLPeriod (PeriodID, TestProtocolID)
	SELECT DISTINCT PeriodID, TestProtocolID 
	FROM @Periods P 
	CROSS JOIN TestProtocol TP
	WHERE TP.Isolated = 0;	

	INSERT INTO @AvailCapacity (PeriodID, TestProtocolID, Capacity)
	SELECT DISTINCT C.PeriodID,TestProtocolID, COALESCE( NULLIF(NrOfPlates, 0), NrOfTests, 0)
	FROM AvailCapacity C
	JOIN @periods P ON P.PeriodID = C.PeriodID
	GROUP BY C.PeriodID,TestProtocolID,NrOfPlates,NrOfTests

	DECLARE @ReservedCapacity TABLE(PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @NonReservedCapacity TABLE(SlotID INT, PeriodID INT, TestProtocolID INT, NrOfPlates INT, NrOfTests INT)
	DECLARE @MarkerTestProtocolID INT;

	
	SELECT 
		@MarkerTestProtocolID = TestProtocolID 
	FROM TestProtocol TP
	JOIN TestType TT On TT.TestTypeID = TP.TestTypeID
	WHERE TT.DeterminationRequired = 1;
	
	
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
	   SELECT PeriodID,TestProtocolID, NrOfPlates = SUM(NrOfPlates) , NrOfTests = SUM(NrOfTests) FROM
	   (
		   SELECT       
				T2.PeriodID,
				T1.TestProtocolID,
				NrOfTests =  0,   
				NrOfPlates = SUM(T1.NrOfPlates)
			FROM ReservedCapacity T1     
			JOIN Slot T2 ON T2.SlotID = T1.SlotID
			JOIN @Periods P1 ON P1.PeriodID = T2.PeriodID
			WHERE T2.StatusCode = 200
			GROUP BY T2.PeriodID,T1.TestProtocolID
		
			UNION

			SELECT       
				P.PeriodID,
				T1.TestProtocolID,
				NrOfTests = SUM(T1.NrOfTests),   
				NrOfPlates = 0
			FROM ReservedCapacity T1     
			JOIN Slot T2 ON T2.SlotID = T1.SlotID 
			JOIN [Period] P ON (T2.ExpectedDate BETWEEN P.StartDate and P.EndDate)
			JOIN @Periods P1 ON P1.PeriodID = P.PeriodID
			WHERE T2.StatusCode = 200
			GROUP BY P.PeriodID,T1.TestProtocolID
		) T
		GROUP BY T.PeriodID, T.TestProtocolID

	) T2 ON T2.TestProtocolID = TP.TestProtocolID AND P.PeriodID = T2.PeriodID
	WHERE TP.Isolated = 0;

	
	;WITH CTE AS 
	(
	   SELECT 
		  T1.PeriodID,
		  T1.SlotID,
		  T1.TestProtocolID,
		  NrOfPlates = SUM(ISNULL(T1.NrOfPlates,0)),
		  NrOfTests = SUM(ISNULL(T1.NrOfTests,0))
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
		CalculationFor = CASE WHEN ISNULL(T4.OtherPeriod,0)  <> T4.PeriodID THEN ''ExpectedPeriod'' ELSE ''PlannedPeriod'' END,
		PlannedExceed = CASE 
								WHEN T5.PlannedCapacityPlates < COALESCE('+@PCols4+',0) THEN '''+@PCols3+'''
								ELSE '''' 
								END,
		ExpectedExceed = CASE 
								WHEN T5.ExpectedCapacityTests < COALESCE('+@TCols4+',0) THEN '''+@TCols3+'''
								ELSE ''''
								END,
		
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
	
	
	JOIN 
	(
		SELECT 
			P.PeriodID, 
			S.SlotID,
			S.PlannedDate, 
			S.ExpectedDate,
			S.BreedingStationCode, 
			S.CropCode, 
			S.SlotName, 
			S.RequestUser,
			OtherPeriod = CASE WHEN S.PeriodID = TT.PPID THEN S.PeriodID 
								ELSE TT.EPID
							END
		FROM Slot S
		JOIN 
		(
			SELECT  
				S.SlotID,
				PPID = MIN(PP.PeriodID), 
				EPID =  MAX(PP.PeriodID)
			FROM  Slot S
			JOIN [Period] PP ON PP.PeriodID = S.PeriodID OR S.ExpectedDate BETWEEN PP.Startdate AND PP.EndDate			
			GROUP BY S.SlotID
		) TT ON TT.SlotID = S.SlotID
		JOIN [Period] P ON P.PeriodID = S.PeriodID OR S.ExpectedDate BETWEEN P.StartDate AND P.EndDate
	) T4 ON T4.SlotID = T1.SlotID
	JOIN @AvailCapacitySlotWise T5 ON T5.SlotID = T4.SlotID
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

	

EXEC sp_executesql @SQL, N'@CurrentPeriodEndDate DATETIME, @Periods TVP_PLAN_Period READONLY, @TblReservedCapicity TVP_ReservedCapacity READONLY, @AvailCapacitySlotWise TVP_AvailCapacitySlotWise READONLY', @CurrentPeriodEndDate, @Periods, @TblReservedCapicity, @AvailCapacitySlotWise;

END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
GO


--EXEC PR_PLAN_GetPlanApprovalListForLAB 4844
CREATE PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
(
	@PeriodID	INT = NULL
) AS BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ARGS		NVARCHAR(MAX);
	DECLARE @SQL		NVARCHAR(MAX);

	--Prepare 8 periods to display
	DECLARE @Periods TVP_PLAN_Period;
	IF(ISNULL(@PeriodID, 0) <> 0) BEGIN
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 8 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;
	END

	
	ELSE BEGIN
		--get current period
		EXEC @PeriodID = PR_PLAN_GetCurrentPeriod;
		INSERT INTO @Periods(PeriodID) 
		SELECT TOP 8 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;
	END

	--Get standard values 
	SET @SQL = N'SELECT 
		PeriodName = CONCAT(PeriodName, FORMAT(StartDate, '' (MMM-dd - '', ''en-US'' ), FORMAT(EndDate, ''MMM-dd)'', ''en-US'' )), 
		T1.Remark, T1.PeriodID, T2.*
	FROM [Period] T1
	LEFT JOIN
	(' +
		dbo.FN_PLAN_GetAvailableCapacityByPeriodsQuery()			
	+ N') T2 ON T2.PID = T1.PeriodID
	WHERE T1.PeriodID IN (SELECT PeriodID FROM @Periods)
	ORDER BY T1.PeriodID;'

	EXEC sp_executesql @SQL, N'@Periods TVP_PLAN_Period READONLY', @Periods;
	
	
	--get current values
	SET @SQL = dbo.FN_PLAN_GetReservedCapacityByPeriodsQuery();

	EXEC sp_executesql @SQL, N'@Periods TVP_PLAN_Period READONLY', @Periods;

	--get columns list
	SELECT TestProtocolID, TestProtocolName,CalculationFor
	FROM
	(
		SELECT
			0 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName,
			CalculationFor = 'ExpectedPeriod'
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 1
		UNION
		SELECT 
			1 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName,
			CalculationFor = 'PlannedPeriod'
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 0
	) V
	ORDER BY DisplayOrder;

	--Get summary period and slot wise
	DELETE FROM @Periods;

	INSERT INTO @Periods(PeriodID) 
		SELECT TOP 4 
			PeriodID
		FROM [Period] 
		WHERE PeriodID < @PeriodID
		ORDER BY PeriodID DESC;

	INSERT INTO @Periods(PeriodID) 
		SELECT TOP 11 
			PeriodID
		FROM [Period] 
		WHERE PeriodID >= @PeriodID
		ORDER BY PeriodID;

	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods
END
GO


