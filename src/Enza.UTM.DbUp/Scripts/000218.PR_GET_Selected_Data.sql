/*
Authror					Date				Description
KRIAHNA GAUTAM			2018-DEC-22			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 
KRIAHNA GAUTAM			2019-APril-05		SP Renamed from PR_GET_3GBSelected_Data to PR_GET_Selected_Data To make generic stored procedure to fetch data for 3GB, GMAS and DNA test type
KRIAHNA GAUTAM			2019-May-31			SP adjusted to return NrOfSample when test type is DNA isolation and Material is list not plants


=================Example===============
EXEC PR_GET_Selected_Data 2049,1,100
PR_GET_Selected_Data 4426,1,100	

*/

ALTER PROCEDURE [dbo].[PR_GET_Selected_Data]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@FilterQuery NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;
	DECLARE @FilterClause NVARCHAR(MAX);
	DECLARE @Offset INT;
	DECLARE @Query NVARCHAR(MAX);
	DECLARE @Columns2 NVARCHAR(MAX)
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);
	DECLARE @ImportLevel NVARCHAR(MAX);
	DECLARE @FetchNrOrSample BIT = 0;

	IF(ISNULL(@FilterQuery,'')<>'')
	BEGIN
		SET @FilterClause = ' AND '+ @FilterQuery
	END
	ELSE
	BEGIN
		SET @FilterClause = '';
	END

	SET @Offset = @PageSize * (@Page -1);

	--get file id based on testid
	SELECT @FileID = FileID ,@ImportLevel = ImportLevel
	FROM Test 
	WHERE TestID = @TestID;
	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'Invalid file or test.';
		RETURN;
	END

	IF EXISTS(SELECT * FROM Test T 
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID WHERE TT.TestTypeName = 'DNA Isolation' AND T.TestID = @TestID AND T.ImportLevel = 'LIST')
	BEGIN
	--@FetchNrOrSample
		--SET @NrOfSampleCol = 'NrOfSamples,';
		SET @FetchNrOrSample = 1;

	END
	ELSE
	BEGIN
		SET @FetchNrOrSample = 0;
	END

	
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(ColumnID) +' AS '+[Column].[Datatype] +')' + ' AS ' + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(ColumnID)
	FROM [Column]
	WHERE FileID = @FileID
	ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END
	IF(@FetchNrOrSample=1)
	BEGIN
		SET @Query = N' ;WITH CTE AS 
						(
							SELECT M.MaterialID, R.[RowNr], D_Selected = R.Selected, R.MaterialKey, R.NrOfSamples, ' + @Columns2 + '
							FROM [ROW] R 
							JOIN Material M ON M.Materialkey = R.MaterialKey 							
							LEFT JOIN 
							(
								SELECT PT.[RowID], ' + @Columns + ' 
								FROM
								(
									SELECT *
									FROM 
									(
										SELECT * FROM dbo.VW_IX_Cell
										WHERE FileID = @FileID
										AND ISNULL([Value],'''')<>'''' 
									) SRC
									PIVOT
									(
										Max([Value])
										FOR [ColumnID] IN (' + @ColumnIDs + ')
									) PIV
								) AS PT 					
							) AS T1	ON R.[RowID] = T1.RowID  				
							WHERE R.FileID = @FileID ' + @FilterClause + '
						), Count_CTE AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE) 					
						SELECT CTE.MaterialID, CTE.MaterialKey, CTE.D_Selected , CTE.NrOfSamples, '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
						ORDER BY CTE.[RowNr]
						OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
						FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';

	END

	ELSE
	BEGIN
		SET @Query = N' ;WITH CTE AS 
						(
							SELECT R.[RowNr], D_Selected = R.Selected, R.MaterialKey, ' + @Columns2 + ' 
							FROM [ROW] R 
							LEFT JOIN 
							(
								SELECT PT.[RowID], ' + @Columns + ' 
								FROM
								(
									SELECT *
									FROM 
									(
										SELECT * FROM dbo.VW_IX_Cell
										WHERE FileID = @FileID
										AND ISNULL([Value],'''')<>'''' 
									) SRC
									PIVOT
									(
										Max([Value])
										FOR [ColumnID] IN (' + @ColumnIDs + ')
									) PIV
								) AS PT 					
							) AS T1	ON R.[RowID] = T1.RowID  				
							WHERE R.FileID = @FileID ' + @FilterClause + '
						), Count_CTE AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE) 					
						SELECT CTE.MaterialKey, CTE.D_Selected , '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
						ORDER BY CTE.[RowNr]
						OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
						FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
	END

	
					
	PRINT @QUERY;

	EXEC sp_executesql @Query, N'@FileID INT', @FileID;	
	IF(@FetchNrOrSample =0)
	BEGIN	
		SELECT CAST([TraitID] AS NVARCHAR(MAX)), [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
		Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
		FROM [Column]  WHERE [FileID]= @FileID
		UNION ALL
		SELECT [TraitID] = 'D_Selected', [ColumLabel] = 'Selected', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
		ORDER BY ColumnNr;
	END
	ELSE
	BEGIN		
		SELECT CAST([TraitID] AS NVARCHAR(MAX)), [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
		Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
		FROM [Column]  WHERE [FileID]= @FileID
		UNION ALL
		SELECT [TraitID] = 'D_Selected', [ColumLabel] = 'Selected', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
		UNION ALL 
		SELECT [TraitID] = NULL, [ColumLabel] = 'NrOfSamples', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
		ORDER BY ColumnNr;
	END


END



