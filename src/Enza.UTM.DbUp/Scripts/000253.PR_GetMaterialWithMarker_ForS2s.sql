/*

Author					Date				Description
KRISHNA GAUTAM			2019-MAY-03			Get Material and with assigned Marker data.
KRISHNA GAUTAM			2019-MAY-08			Marker and determinations is fetched from New table created for S2S which is S2SDonorMarkerScore

=================Example===============
EXEC PR_GetMaterialWithMarker_ForS2s 34199,1, 150, ''

*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarker_ForS2s]
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
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(MAX), ColumnLabel NVARCHAR(MAX), ColumnType INT, ColumnNr INT, DataType NVARCHAR(MAX));


	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 2, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT) * 2) - 1
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) + 8 AS ColumnNR
		FROM S2SDonorMarkerScore T1
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

	--Get Score Columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT)) * 2
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('score_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) + 7 AS ColumnNR
		FROM S2SDonorMarkerScore T1
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
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 0, (MAX(ColumnNr) + 8), MAX(DataType)
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

	--get score column
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
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType IN (1,2)
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType NOT IN (1,2)
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowID, T1.RowNr, T1.Selected, M.MaterialKey,D.ProjectCode,D.DH0Net,D.Requested,D.Transplant,D.ToBeSown, ' + @Columns3 + N'
			FROM 
			(
				SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
				(
					SELECT RowID, MaterialKey,RowNr,ColumnID,Selected,Value
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
			LEFT JOIN S2SDonorInfo D ON D.RowID = T1.RowID
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowID, T1.RowNr, T1.Selected, M.MaterialKey, D.ProjectCode, D.DH0Net,D.Requested,D.Transplant,D.ToBeSown, ' + @Columns3 + N'
			FROM 
			(
				SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
				(
					
					SELECT RowID, MaterialKey,RowNr,ColumnID,Selected,Value
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
			LEFT JOIN S2SDonorInfo D ON D.RowID = T1.RowID
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			LEFT JOIN 
			(
				--markers info
				SELECT MaterialID, ' + @Columns  + N'
				FROM 
				(
					SELECT T1.MaterialID, T1.DeterminationID
					FROM [S2SDonorMarkerScore] T1
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
				--Score Info
				SELECT MaterialID, ' + @Columns4  + N'
				FROM 
				(
					SELECT T1.MaterialID,T1.DeterminationID,Score
					FROM [S2SDonorMarkerScore] T1
					WHERE T1.TestID = @TestID AND ISNULL(T1.RelationDonorID,0) = 0
				) SRC 
				PIVOT
				(
					MAX(Score)
					FOR [DeterminationID] IN (' + @ColumnIDs4 + N')
				) PV
				
			) AS T3				
			ON T3.MaterialID = T2.MaterialID
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, D_Selected = Selected, ProjectCode, DH0Net, Requested, Transplant, ToBeSown, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY
		OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))';

		SET @Offset = @PageSize * (@Page -1);

		--PRINT @Query;
		
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		  --PRINT 1;
		update @TblColumns set ColumnType = 1 where ColumnType = 2;
		update @TblColumns SET ColumnNr = ColumnNr + 8 WHERE ColumnLabel NOT IN ('GID', 'Plant name','Crop')
		update @TblColumns SET ColumnNr = 0, ColumnType = 3 WHERE ColumnLabel = 'GID'
		update @TblColumns SET ColumnNr = 1, ColumnType = 3 WHERE ColumnLabel = 'Plant name';
		update @TblColumns SET ColumnNr = 2, ColumnType = 3 WHERE ColumnLabel = 'Crop';

		INSERT INTO @TblColumns(Traitid,ColumnLabel, ColumnType, DataType, ColumnNr)
		VALUES('D_Selected','Selected', 3,  'BIT', 3);

		--insert other columns
		--DH0Net, Requested, Transplant, ToBeSown,ProjectCode		
		INSERT INTO @TblColumns(Traitid,ColumnLabel, ColumnType, DataType, ColumnNr)
		VALUES		
		('ProjectCode','ProjectCode',3,'NVARCHAR(20)',4),
		(NULL,'DH0Net', 3, 'INT', 5),
		(NULL,'Requested', 3, 'INT', 6),
		(NULL,'Transplant', 3, 'INT', 7),
		(NULL,'ToBeSown', 3, 'INT', 8);
		
		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY Columntype DESC,ColumnNr;

		
END
GO