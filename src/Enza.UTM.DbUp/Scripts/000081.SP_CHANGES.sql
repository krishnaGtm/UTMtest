--EXEC PR_PLAN_GetPlanApprovalListForLAB 91
ALTER PROCEDURE [dbo].[PR_PLAN_GetPlanApprovalListForLAB]
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
	SET @SQL = dbo.FN_PLAN_GetReservedCapacityByPeriodsQuery() + 
		N' WHERE PeriodID IN (SELECT PeriodID FROM @Periods);'
	EXEC sp_executesql @SQL, N'@Periods TVP_PLAN_Period READONLY', @Periods;

	--get columns list
	SELECT TestProtocolID, TestProtocolName
	FROM
	(
		SELECT
			0 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 1
		UNION
		SELECT 
			1 AS DisplayOrder, 
			TestProtocolID = CAST(TestProtocolID AS VARCHAR(10)), 
			TestProtocolName
		FROM TestProtocol TP
		JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		WHERE TP.Isolated = 0
		AND TT.DeterminationRequired = 0
	) V
	ORDER BY DisplayOrder;

	--Get summary period and slot wise
	EXEC PR_PLAN_GetPlanApprovalListBySlotForLAB @Periods;
END
