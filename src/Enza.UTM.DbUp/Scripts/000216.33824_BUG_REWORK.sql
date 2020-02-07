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
			T2.PeriodID,
			T1.TestProtocolID,
			NrOfPlates = SUM(T1.NrOfPlates),
			NrOfTests = SUM(T1.NrOfTests)
		 FROM ReservedCapacity T1
		 JOIN Slot T2 ON T2.SlotID = T1.SlotID 
		 JOIN @Periods P ON P.PeriodID = T2.PeriodID
		 WHERE T2.StatusCode = 200
		 GROUP BY T2.PeriodID, T1.TestProtocolID
	) T2 ON T2.TestProtocolID = TP.TestProtocolID AND P.PeriodID = T2.PeriodID
	WHERE TP.Isolated = 0;

	--Calculate sum of non reserved but requested capacity slot, period and protocol wise
	;WITH CTE AS 
	(
		SELECT 
			T2.PeriodID,
			T1.SlotID,
			T1.TestProtocolID,
			NrOfPlates = SUM(T1.NrOfPlates),
			NrOfTests = SUM(T1.NrOfTests)
		FROM ReservedCapacity T1
		JOIN Slot T2 ON T2.SlotID = T1.SlotID
		JOIN @Periods P ON P.PeriodID = T2.PeriodID
		WHERE T2.StatusCode = 100
		GROUP BY T2.PeriodID, T1.SlotID, T1.TestProtocolID
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
		T1.Plates, 
		T1.Markers, 
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
					S.SlotID, 
					NrOfTests, 
					NrOfPlates,
					Protocol1 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END,
					Protocol2 = CASE WHEN RC.TestProtocolID = @MarkerTestProtocolID THEN ''Markers'' ELSE ''Plates'' END
				FROM SLOT S
				JOIN ReservedCapacity RC ON RC.SlotID = S.SlotID
				JOIN TestProtocol TP On TP.TestProtocolID = RC.TestProtocolID
				JOIN @Periods P ON P.PeriodID = S.PeriodID
				WHERE S.StatusCode = 100 
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
	LEFT JOIN Slot T4 ON T4.SlotID = T1.SlotID
	ORDER BY T4.PeriodID, T1.SlotID'

EXEC sp_executesql @SQL, N'@CurrentPeriodEndDate DATETIME, @Periods TVP_PLAN_Period READONLY', @CurrentPeriodEndDate, @Periods;

END
GO