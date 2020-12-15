/*

Author					Date				Description
KRISHNA GAUTAM			2020-July-10			Get Material and with assigned test data.

=================Example===============
EXEC PR_RDT_GetMaterialWithTests 10622,1, 150, '[D_88222] like ''%0%'''
EXEC PR_RDT_GetMaterialWithTests 10622,1, 150, ''

*/
ALTER PROCEDURE [dbo].[PR_RDT_GetMaterialWithTests]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Columns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX),@Columns4 NVARCHAR(MAX), @ColumnIDS4 NVARCHAR(MAX);
	DECLARE @Offset INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(MAX), ColumnLabel NVARCHAR(MAX), ColumnType INT, ColumnNr INT, DataType NVARCHAR(MAX),Updatable BIT);
	

	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, Updatable,DataType)
	SELECT DeterminationID, TraitID, ColumnLabel, 2, ColumnNr, 1, 'Bool'
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			ColumnLabel = CONCAT(T4.ColumLabel , ' (', COUNT(T1.DeterminationID) ,')'),
			ColumnNr = MAX(T4.ColumnNR)
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
		JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID			
		GROUP BY T1.DeterminationID,T4.ColumLabel	
	) V1
	ORDER BY V1.ColumnNr;

	--Get date Columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr,Updatable,DataType)
	SELECT DeterminationID, TraitID, ColumLabel, 1, ColumnNR, 1, 'Date'
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('Date_', T1.DeterminationID) AS TraitID,
			CONCAT(T4.ColumLabel, ', Exp date')  AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
		JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
		WHERE T1.TestID = @TestID
		AND T4.FileID = @FileID			
		GROUP BY T1.DeterminationID,T4.ColumLabel	
	) V1
	ORDER BY V1.ColumnNr;


	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,Updatable)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 0, MAX(ColumnNr), MAX(DataType), 0
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	
	--get Get Determination Column
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 2
	GROUP BY TraitID;

	--get determination selected column
	SELECT 
		@Columns4  = COALESCE(@Columns4 + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs4  = COALESCE(@ColumnIDs4 + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID,ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 0
	--ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel))) +' = ISNULL('+QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))+',0)'
	FROM @TblColumns
	WHERE ColumnType = 2
	GROUP BY TraitID
	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType NOT IN (1,2)
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT * FROM 
			(
			SELECT M.MaterialID,  TM.MaterialStatus, T1.RowID, T1.MaterialKey,' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowID, ' + @Columns2 + N'  
				FROM 
				(
					SELECT MaterialKey,RowID,ColumnID,Value
					FROM VW_IX_Cell_Material
					WHERE FileID = @FileID
					AND ISNULL([Value],'''')<>''''
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			LEFT JOIN TestMaterialStatus TM ON TM.TestID = @TestID AND TM.MaterialID = M.MaterialID
			
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT * FROM 
			(
			SELECT M.MaterialID, TM.MaterialStatus, T1.RowID, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowID, ' + @Columns2 + N'  FROM 
				(
					SELECT MaterialKey,RowID,ColumnID,Value
					FROM VW_IX_Cell_Material
					WHERE FileID = @FileID
					AND ISNULL([Value],'''')<>'''' 
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			LEFT JOIN TestMaterialStatus TM ON TM.TestID = @TestID AND TM.MaterialID = M.MaterialID

			LEFT JOIN 
			(
				SELECT MaterialID, MaterialKey, ' + @Columns  + N'
				FROM 
				(
					SELECT T2.MaterialID,T2.MaterialKey, T1.DeterminationID
					FROM [TestMaterialDetermination] T1
					JOIN Material T2 ON T2.MaterialID = T1.MaterialID
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					COUNT(DeterminationID)
					FOR [DeterminationID] IN (' + @ColumnIDs + N')
				) PV
				
			) AS T2			
			ON T2.MaterialID = M.MaterialID

			LEFT JOIN 
			(
				SELECT MaterialID, MaterialKey, ' + @Columns4  + N'
				FROM 
				(
					SELECT T2.MaterialID,T2.MaterialKey, T1.DeterminationID,ExpectedDate = CONVERT(varchar,T1.ExpectedDate,103) -- CAST(T1.ExpectedDate AS DATE)
					FROM [TestMaterialDetermination] T1
					JOIN Material T2 ON T2.MaterialID = T1.MaterialID
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					MAX(ExpectedDate)
					FOR [DeterminationID] IN (' + @ColumnIDS4 + N')
				) PV
				
			) AS T3			
			ON T3.MaterialID = M.MaterialID
			) AS T
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, MaterialStatus, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowID
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY
		OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))';

		SET @Offset = @PageSize * (@Page -1);

		PRINT @Query;

		
		
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		IF(ISNULL(@ImportLevel,'PLT') = 'LIST')
		BEGIN
			INSERT INTO @TblColumns(ColumnLabel, ColumnType, ColumnNr, Updatable,DataType)
			VALUES('MaterialStatus', 0,1,1,'NVARCHAR(255)')
		END
		SELECT 
			TraitID, 
			ColumnLabel, 
			ColumnType = CASE WHEN ColumnType = 2 THEN 1 ELSE ColumnType END, 
			ColumnNr, 
			DataType,
			Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' OR ColumnLabel = 'MaterialStatus' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY Fixed desc, ColumnType DESC, ColumnNr, DataType

		
END
GO





ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForRDT]
(	
	@CropCode							NVARCHAR(15),
	@TestID								INT,	
	@TVP_TMD_WithDate TVP_TMD_WithDate	READONLY,
	@TVPProperty TVP_PropertyValue		READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	
	--insert or delete statement for merge
	MERGE INTO TestMaterialDetermination T 
	USING @TVP_TMD_WithDate S	
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.ExpectedDate,'') != ISNULL(S.ExpectedDate,'')
		THEN UPDATE SET T.ExpectedDate = S.ExpectedDate		
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,ExpectedDate) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.ExpectedDate);


	MERGE INTO TestMaterialStatus T 
	USING @TVPProperty S ON T.MaterialID = S.MaterialID  AND T.TestID = @TestID AND S.[Key] = 'MaterialStatus'
	WHEN MATCHED AND ISNULL(T.MaterialStatus,'') <> ISNULL(S.[Value],'') THEN UPDATE
		SET T.MaterialStatus = S.[Value]
	WHEN NOT MATCHED THEN
		INSERT(TestID, MaterialID, MaterialStatus)
		VALUES(@TestID, S.MaterialID, S.[Value]);

			
END

GO


--EXEC PR_RDT_GetMaterialForUpload 2064;
ALTER PROCEDURE [dbo].[PR_RDT_GetMaterialForUpload]
(
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID)
	BEGIN
		EXEC PR_ThrowError N'Invalid test.';
		RETURN;
	END

	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID AND StatusCode = 100)
	BEGIN
		EXEC PR_ThrowError N'Invalid test status.';
		RETURN;
	END

	IF EXISTS(SELECT TestID FROM TestMaterialDetermination WHERE TestID = @TestID AND ISNULL(ExpectedDate,'') = '')
	BEGIN
		EXEC PR_ThrowError N'Expected result date is not filled for all materials.';
		RETURN;
	END

	SELECT
		F.CropCode AS 'Crop',
		T.BreedingStationCode AS 'BrStation',
		T.CountryCode AS 'Country',
		T.ImportLevel AS 'Level',
		TT.TestTypeCode AS 'TestType',
		T.TestID AS 'RequestID',
		'UTM' AS 'RequestingSystem',
		D.DeterminationID,
		M.MaterialID,
		M.MaterialKey,
		CONVERT(varchar(50), TMD.ExpectedDate, 120) AS 'ExpectedResultDate',
		TMS.MaterialStatus
	FROM Test T
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN TestMaterialDetermination TMD ON TMD.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID	
	LEFT JOIN TestMaterialStatus TMS ON TMS.TestID = T.TestID AND TMS.MaterialID = M.MaterialID
	WHERE T.TestID = @TestID

END
GO