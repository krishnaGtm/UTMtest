--EXEC PR_Get3GBMaterialsForUpload 2051, N'GID=''534584''';
ALTER PROCEDURE [dbo].[PR_Get3GBMaterialsForUpload]
(
	@TestID		INT,
	@Filter		NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);

	DECLARE @tbl TABLE(BreEZysAdministrationCode NVARCHAR(20), ThreeGBTaskID INT, PlantNumber NVARCHAR(100), BreedingProject NVARCHAR(10), PlantID NVARCHAR(50), Gen NVARCHAR(50));

	IF(ISNULL(@Filter, '') = '') BEGIN
		INSERT @tbl (BreEZysAdministrationCode, ThreeGBTaskID, PlantNumber, BreedingProject, PlantID, Gen)
		SELECT
			BreEZysAdministrationCode = CASE WHEN T.RequestingSystem = 'Phenome' THEN 'PH' ELSE 'NL' END,
			T.ThreeGBTaskID,
			PlantNumber = COALESCE(V1.[Plant name], V1.PlantNr),
			BreedingProject = T.BreedingStationCode,
			PlantID = R.MaterialKey,
			V1.Gen
		FROM [Row] R
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
		WHERE T.TestID = @TestID;
	END
	ELSE BEGIN
		SELECT 
			@Columns  = COALESCE(@Columns + ',', '') + QUOTENAME(ColumnID) + ' AS ' + ISNULL(QUOTENAME(TraitID), QUOTENAME(ColumLabel)),
			@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
		FROM [Column] C
		JOIN [File] F ON F.FileID = C.FileID
		JOIN Test T ON T.FileID = F.FileID
		WHERE T.TestID = @TestID
		ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END

	DECLARE @PlantNr NVARCHAR(50);
	SELECT 
		@PlantNr = 	CASE WHEN T.RequestingSystem = 'Phenome' THEN '[Plant name]' ELSE '[PlantNr]' END
	FROM Test T 
	WHERE T.TestID =  @TestID;

	SET @SQL = N'
		SELECT 
			BreEZysAdministrationCode = CASE WHEN T.RequestingSystem = ''Phenome'' THEN ''PH'' ELSE ''NL'' END,
			T.ThreeGBTaskID,
			PlantNumber = ' + @PlantNr + 
			N', BreedingProject = T.BreedingStationCode,
			PlantID = R.MaterialKey,
			T1.Gen
		FROM [ROW] R 
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], ' + @Columns + ' 
			FROM
			(
				SELECT * FROM 
				(
					SELECT 
						T3.[MaterialKey],
						T1.[ColumnID], 
						T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					JOIN Test T ON T.FileID = T4.FileID
					WHERE T.TestID = @TestID 
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  
		JOIN [File] F ON F.FileID = R.FileID
		JOIN Test T ON T.FileID = F.FileID				
		WHERE T.TestID = @TestID AND ' + @Filter;

		--PRINT @SQL 
		INSERT @tbl (BreEZysAdministrationCode, ThreeGBTaskID, PlantNumber, BreedingProject, PlantID, Gen)
		EXEC sp_executesql @SQL, N'@TestID INT', @TestID; 
	END

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
			TwoGBPlatePlanID = T.TestID,
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