
/*
	Author:			KRISHNA GAUTAM
	Created Date:	2017-DEC-04
	Updated Date:	2018-FEB-26
	Description:	Get Material and with assigned Marker data. */

	/*
	=================Example===============
	EXEC [PR_GetMaterialWithMarker] 3095,1, 150, ''
*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarker]
(
	@TestID INT,
	--@UserID NVARCHAR(100),
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));

	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID --AND F.UserID = @UserID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR)
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			MAX(T4.ColumLabel) AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
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
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 2, (MAX(ColumnNr) + @Total), MAX(DataType)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	
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


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, NrOfSamples, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, NrOfSamples, ' + @Columns2 + N'  FROM 
				(
					SELECT T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value], T3.NrOfSamples
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					--JOIN Material M ON M.Materialkey= T3.MaterialKey
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T4.FileID = @FileID --AND T4.UserID = @UserID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, NrOfSamples, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, NrOfSamples, ' + @Columns2 + N'  FROM 
				(
					SELECT  T3.[MaterialKey], T3.RowNr, T1.[ColumnID], T1.[Value], T3.NrOfSamples
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					--JOIN Material M ON M.Materialkey= T3.MaterialKey
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T4.FileID = @FileID --AND T4.UserID = @UserID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			
			JOIN Material M ON M.MaterialKey = T1.MaterialKey

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
				) PV
				
			) AS T2			
			ON T2.MaterialID = M.MaterialID
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, NrOfSamples, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY;';

		SET @Offset = @PageSize * (@Page -1);

		--PRINT @QUERY;

		--EXEC sp_executesql @Query,N'@FileID INT, @UserID NVARCHAR(200), @Offset INT, @PageSize INT, @TestID INT', @FileID, @UserID, @Offset, @PageSize, @TestID;
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		--DECLARE @LastColumnNr INT;
		--SELECT @LastColumnNr = ISNULL(MAX(ColumnNr), 0) FROM @TblColumns;

		--add columns for NrOfSamples
		IF(@ImportLevel = 'LIST') BEGIN
			INSERT INTO @TblColumns(ColumnLabel, ColumnType, DataType, ColumnNr)
			VALUES('NrOfSamples', 2, 'NVARCHAR(255)', 0);
		END

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY ColumnNr;


	--END
END;
