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
		T3.PeriodID, 
		PeriodName = CONCAT(P.PeriodName, FORMAT(P.StartDate, ' (MMM-dd-yy - ', 'en-US' ), FORMAT(P.EndDate, 'MMM-dd-yy)', 'en-US' )),
		T1.*, 
		T2.TestProtocolName, 
		T3.BreedingStationCode, 
		T3.CropCode, 
		T3.RequestUser,
		T3.SlotName,
		CRD.CropName
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
	LEFT JOIN Slot T3 ON T3.SlotID = T1.SlotID
	JOIN [Period] P ON P.PeriodID = T3.PeriodID
	JOIN CropRD CRD ON CRD.CropCode = T3.CropCode
	ORDER BY T3.PeriodID, T3.BreedingStationCode, T3.CropCode;

END
