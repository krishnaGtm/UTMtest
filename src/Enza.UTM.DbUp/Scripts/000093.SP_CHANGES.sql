/*
	EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
	EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
	EXEC [PR_GetDataWithMarkers] 1030, 1, 200, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	--@User			NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT--, @SameTestCount INT =1;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15),MateriallblColumn BIT);
	DECLARE @PlateAndWellAssigned BIT = 0; --here we have to check whether well and plate is assigned previously or not.. for now we set it to false 
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = ''; -- ,@SameTestCount NVARCHAR(5);

	SELECT @FileID = F.FileID, @FileName = T.TestName, @Crop = CropCode, @Source = T.RequestingSystem
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID AND T.RequestingUser = F.UserID;

	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'File or test doesn''t exist.';
		RETURN;
	END

	--CREATE PLATE AND WELLS IF REQUIRED
	--EXEC PR_CreatePlateAndWell @TestID,@User
	EXEC PR_CreatePlateAndWell @TestID;

	--Determination columns (for external we have to show all assigned markers, for other only linked trait should be shown.
	IF(ISNULL(@Source,'')<> 'External') BEGIN
		INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
		SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR),0
		FROM
		(	
			SELECT DISTINCT 
				T1.DeterminationID,
				CONCAT('D_', T1.DeterminationID) AS TraitID,
				ColumLabel = MAX(T4.ColumLabel),
				ColumnNR = MAX(T4.ColumnNR)
			FROM TestMaterialDetermination T1
			JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
			JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
			JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
			JOIN Trait T ON T.TraitID = CT.TraitID
			JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0
			WHERE T1.TestID = @TestID
			AND T4.FileID = @FileID
			GROUP BY T1.DeterminationID		
		) V1
		ORDER BY V1.ColumnNr;
	END
	ELSE BEGIN
		INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
			SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnLabel),0
			FROM
			(	
				SELECT 
					T1.DeterminationID,
					CONCAT('D_', T1.DeterminationID) AS TraitID,
					MAX(T.ColumnLabel) AS ColumnLabel			
				FROM TestMaterialDetermination T1
				JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
				JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
				JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
				JOIN Trait T ON T.TraitID = CT.TraitID
				--JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
				WHERE T1.TestID = @TestID
				--AND T4.FileID = @FileID			
				GROUP BY T1.DeterminationID	
			) V1
			ORDER BY V1.ColumnLabel;
	END
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT Max(ColumnID), TraitID, ColumLabel, 2, (Max(ColumnNr) + @Total), Max(DataType)
	FROM [Column]	
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	--ORDER BY ColumnNr;
	
	--get dynamic columns
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(TraitID)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 1
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	ORDER BY [ColumnNr] ASC;

	SET @SQL = N';WITH CTE AS 
	(
		SELECT V1.MaterialID, V1.MaterialKey, V1.PlateID, V1.Plate, V1.WellID, V1.Well, V1.Position1, V1.Position2, 
		V1.WellTypeID, V1.Fixed, --T01.ReplicaCount, 
		' + @Columns3 + N'
		FROM 
		(
			SELECT
				M.MaterialID, 
				M.MaterialKey,
				P.PlateID, 
				P.PlateName AS Plate, 
				W.WellID,
				W.Position AS Well, 
				CAST(RIGHT(Position, LEN(Position) - 1) AS INT) AS Position1 
				,LEFT(Position, 1) as Position2,
				WT.WellTypeID,
				Fixed = CAST((CASE WHEN WT.WellTypeName = ''F'' OR WT.WellTypeName = ''D'' THEN 1 ELSE 0 END) AS BIT)
			FROM TestMaterialDeterminationWell TMDW
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
			JOIN Material M ON M.MaterialID = TMDW.MaterialID 
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID
		) V1
		--LEFT JOIN 
		--(
		--	SELECT
		--		TMDW.MaterialID , COUNT(TMDW.MaterialID) AS ReplicaCount
		--	FROM TestMaterialDeterminationWell TMDW
		--	JOIN Well W ON W.WellID = TMDW.WellID
		--	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID			
		--	JOIN Plate P ON P.PlateID = W.PlateID
		--	WHERE P.TestID = @TestID AND WT.WellTypeName = ''A''
		--	GROUP BY TMDW.MaterialID
		--	HAVING COUNT(*) >1

		--) AS T01 ON T01.MaterialID = V1.MaterialID
		JOIN 
		(
			--trait and property columns
			SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
			(
				SELECT T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value]
				FROM [Cell] T1
				JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
				JOIN [Row] T3 ON T3.RowID = T1.RowID
				JOIN [FILE] T4 ON T4.FileID = T3.FileID
				WHERE T2.FileID = @FileID --AND T4.UserID = @User
			) SRC
			PIVOT
			(
				Max([Value])
				FOR [ColumnID] IN (' + @ColumnID2s + N')
			) PV
		) V2 ON V2.MaterialKey = V1.MaterialKey ';	
		
		IF(ISNULL(@Columns, '') <> '') BEGIN
			SET @SQL = @SQL + N'
			LEFT JOIN 
			(
				--markers info
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
				) AS T
			) V3 ON V3.MaterialKey  = V1.Materialkey ';
		END	
		
		SET @SQL = @SQL + N' WHERE  1 = 1 ';	

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @SQL = @SQL + ' AND ' + @Filter
		END

	SET @SQL = @SQL + N'
	), CTE_COUNT AS (SELECT COUNT([MaterialKey]) AS [TotalRows] FROM CTE)
	
	SELECT CTE.MaterialID,CTE.WellTypeID, CTE.WellID, CTE.Fixed, CTE.Plate, CTE.Well, --[Replica] = CASE WHEN  ISNULL(CTE.ReplicaCount,0)> 0 THEN 1 ELSE 0 END, 
	' + @Columns3 + N', CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY PlateID, Position2, Position1
	--Well
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;';

	PRINT @SQL
	
	SET @Offset = @PageSize * (@Page -1);

	--EXEC sp_executesql @SQL , N'@FileID INT, @User NVARCHAR(100), @Offset INT, @PageSize INT, @TestID INT', @FileID, @User, @Offset, @PageSize, @TestID;
	EXEC sp_executesql @SQL , N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

	--insert well and plate column
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	VALUES(999991,NULL,'Plate',3,1,'NVARCHAR(255)'),(999992,NULL,'Well',3,2,'NVARCHAR(255)')
	--get columns information
	SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
	Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END,
	MateriallblColumn = CASE WHEN (ColumnLabel = 'Plantnr' AND @Source = 'Breezys') OR (ColumnLabel = 'Plant name' AND @Source <> 'Breezys') THEN 1 ELSE 0 END
	FROM @TblColumns T1
	order by ColumnNr;
END

