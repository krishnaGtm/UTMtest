--EXEC PR_Get3GBMaterialsForUpload 2061;
ALTER PROCEDURE [dbo].[PR_Get3GBMaterialsForUpload]
(
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);

	DECLARE @tbl TABLE(BreEZysAdministrationCode NVARCHAR(20), ThreeGBTaskID INT, PlantNumber NVARCHAR(100), BreedingProject NVARCHAR(10), PlantID NVARCHAR(50), Gen NVARCHAR(50));

	INSERT @tbl (BreEZysAdministrationCode, ThreeGBTaskID, PlantNumber, BreedingProject, PlantID, Gen)
	SELECT
		BreEZysAdministrationCode = CASE WHEN T.RequestingSystem = 'Phenome' THEN 'PH' ELSE 'NL' END,
		T.ThreeGBTaskID,
		PlantNumber = COALESCE(V1.[Plant name], V1.PlantNr),
		BreedingProject =ISNULL(M.BreedingStationCode, T.BreedingStationCode),
		PlantID = R.MaterialKey,
		V1.Gen
	FROM [Row] R
	JOIN [Material] M ON R.MaterialKey = M.MaterialKey
	JOIN [File] F ON F.FileID = R.FileID
	JOIN Test T ON T.FileID = F.FileID
	LEFT JOIN
	(
		SELECT V2.MaterialKey, V2.[Plant name], V2.PlantNr, V2.Gen 
		FROM
		(
			SELECT 
				R.MaterialKey,
				C2.ColumLabel,
				CellValue = C.[Value]
			FROM [Cell] C
			JOIN [Column] C2 ON C2.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN [File] F ON F.FileID = R.FileID
			JOIN Test T ON T.FileID = F.FileID
			WHERE C2.ColumLabel IN('Plant name', 'PlantNr', 'Gen')
			AND T.TestID = @TestID
		) V1
		PIVOT
		(
			Max(CellValue)
			FOR [ColumLabel] IN ([Plant name], [PlantNr], [Gen])
		) V2
	) V1 ON V1.MaterialKey = R.MaterialKey
	WHERE T.TestID = @TestID
	AND ISNULL(R.Selected, 0) = 1;
	

	SELECT 
		V1.*,
		V2.TwoGBPlatePlanID,
		V2.TwoGBPlateNumber,
		V2.TwoGBRow,
		V2.TwoGBColumn,
		V2.TwoGBWeek,
		V2.MarkerName,
		V2.Result
	FROM @tbl V1
	LEFT JOIN
	(
		SELECT
			TwoGBPlatePlanID = T.LabPlatePlanName,
			TwoGBPlateNumber = P.PlateName,
			TwoGBRow =  LEFT(W.Position, 1),
			TwoGBColumn = RIGHT(W.Position, LEN(W.Position) - 1),
			TwoGBWeek = DATEPART(WEEK, T.ExpectedDate),
			MarkerName = D.DeterminationName,
			Result = TR.ObsValueChar,
			M.MaterialKey
			--P.PlateID,
			--,W.WellID,
			--TMD.DeterminationID	
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID
		JOIN [Row] R ON R.FileID = F.FileID
		JOIN Material M ON M.MaterialKey = R.MaterialKey
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
		JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
		JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
		WHERE TT.DeterminationRequired = 1 /*Get only determination required test types*/
		  AND T.StatusCode >= 600 /*Received*/
	) V2 ON V2.MaterialKey = V1.PlantID;	
END
GO

