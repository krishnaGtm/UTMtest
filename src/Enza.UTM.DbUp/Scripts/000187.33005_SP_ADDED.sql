CREATE TYPE [dbo].[TVP_Rows] AS TABLE(
	RowID		INT,
	TotalRows	INT
)
GO

CREATE TYPE [dbo].[TVP_Filters] AS TABLE(
	ColumnID	VARCHAR(20),
	[Value]		NVARCHAR(255),
	Expr		NVARCHAR(50),
	ColType		VARCHAR(20)
)
GO

DROP FUNCTION IF EXISTS FN_ApplyFilters
GO

/*
	DECLARE @Filters NVARCHAR(MAX) = N'[{"Col" : 2618, "Val": "4", "Expr": "contains","ColType": "NVARCHAR"},{"Col" : 2687, "Val": "BF", "Expr": "contains","ColType": "NVARCHAR"}]';
	
	DECLARE @T_Filters TVP_Filters
	INSERT INTO @T_Filters(ColumnID, [Value], Expr, ColType)
	SELECT 
		ColumnID, 
		[Value], 
		Expr, 
		ColType 
	FROM OPENJSON(@Filters) WITH
	(
		ColumnID	VARCHAR(20)		'$.Col',
		[Value]		NVARCHAR(255)	'$.Val',
		Expr		NVARCHAR(50)	'$.Expr',
		ColType		VARCHAR(20)		'$.ColType'
	);
	PRINT dbo.FN_ApplyFilters(@T_Filters);
*/
CREATE FUNCTION FN_ApplyFilters
(
	 @Filters TVP_Filters READONLY
)RETURNS NVARCHAR(MAX)
AS BEGIN
	DECLARE @P_COLUMNS NVARCHAR(MAX);
	SELECT 
		@P_COLUMNS = COALESCE(@P_COLUMNS , '') + 
		QUOTENAME(ColumnID) + ' ' +
		CASE Expr 
			WHEN 'eq' THEN  '= ' 
			WHEN 'neq' THEN '<> ' 
			WHEN 'gte' THEN '>= ' 
			WHEN 'gt' THEN  '> ' 
			WHEN 'lte' THEN '<= ' 
			WHEN 'lt' THEN '< ' 
			WHEN 'isnull' THEN 'IS NULL ' 
			WHEN 'isnotnull' THEN 'IS NOT NULL '
			WHEN 'startswith' THEN 'LIKE '
			WHEN 'contains' THEN 'LIKE '
			WHEN 'doesnotcontains' THEN 'LIKE '
			WHEN 'endswith' THEN 'LIKE '
			WHEN 'isempty' THEN '= '
			WHEN 'isnotempty' THEN '<> '
		END	+
		CASE ColType 
			WHEN 'NVARCHAR' THEN
				CASE ISNULL(Expr, '')
					WHEN 'startswith' THEN	
						'''' + ISNULL([Value], '') + '%'''			
					WHEN 'contains' THEN
						'''%' + ISNULL([Value], '') + '%'''
					WHEN 'doesnotcontains' THEN
						'''%' + ISNULL([Value], '') + '%'''
					WHEN 'endswith' THEN
						'''%' + ISNULL([Value], '') + ''''
					WHEN 'isempty' THEN
						''''''
					WHEN 'isnotempty' THEN
						''''''
					WHEN 'isnull' THEN
						''
					WHEN 'isnotnull' THEN
						''
					ELSE 
						'''' + ISNULL([Value], '') + ''''
				END
			WHEN 'DATETIME' THEN   '''' + ISNULL([Value], '') + ''''
			ELSE ISNULL([Value], '')
		END	+ ' AND '	 
	FROM @Filters;
	
	IF(ISNULL(@P_COLUMNS, '') <> '') BEGIN
		SET @P_COLUMNS = LEFT(@P_COLUMNS, LEN(@P_COLUMNS) - 3);
	END
	RETURN @P_COLUMNS;
END
GO


DROP PROCEDURE IF EXISTS PR_S2S_GETDATA
GO

/*
	DECLARE @Filters NVARCHAR(MAX) = N'[{"Col" : 2618, "Val": "4", "Expr": "contains","ColType": "NVARCHAR"},{"Col" : 2687, "Val": "BF", "Expr": "contains","ColType": "NVARCHAR"}]';
	DECLARE @TotalRows INT
	EXEC PR_S2S_GETDATA 2043, 1, 200, @Filters, @TotalRows OUT;
	PRINT @TotalRows;
*/

CREATE PROCEDURE PR_S2S_GETDATA
(
	@TestID		INT,
	@Page		INT,
	@PageSize	INT,
	@Filters	NVARCHAR(MAX) = NULL,
	@TotalRows	INT OUTPUT
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @FileID INT, @OffSet INT, @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @Columns2 NVARCHAR(MAX);
	DECLARE @T_Filters TVP_Filters, @Rows TVP_Rows;

	SELECT @FileID = FileID FROM Test WHERE TestID = @TestID;--4184

	INSERT INTO @T_Filters(ColumnID, [Value], Expr, ColType)
	SELECT 
		ColumnID, 
		[Value], 
		Expr, 
		ColType 
	FROM OPENJSON(@Filters) WITH
	(
		ColumnID	VARCHAR(20)		'$.Col',
		[Value]		NVARCHAR(255)	'$.Val',
		Expr		NVARCHAR(50)	'$.Expr',
		ColType		VARCHAR(20)		'$.ColType'
	);
	--get list of columns which are used in filters only for narrow down the resultset
	SELECT 
		@Columns = COALESCE(@Columns + ',', '') + QUOTENAME(ColumnID)
	FROM @T_Filters;

	IF(ISNULL(@Columns, '') = '') BEGIN
		WITH CTE AS
		(
			SELECT 
				RowID		
			FROM VW_IX_Cell 
			WHERE FileID = @FileID
			AND ([Value] <> '' AND [Value] IS NOT NULL)
		), CTE_COUNT AS
		(
			SELECT COUNT(RowID) TotalRows FROM CTE
		)
		INSERT INTO @Rows(RowID, TotalRows)
		SELECT 
			RowID, 
			TotalRows
		FROM CTE, CTE_COUNT
		ORDER BY RowID
		OFFSET @OffSet ROWS
		FETCH NEXT @PageSize ROWS ONLY;
	END
	ELSE BEGIN
		SET @SQL = N'
				WITH CTE AS
				(
					SELECT 
						P.*
					FROM
					(
						SELECT 
							C.RowID,
							C.ColumnID,
							C.[Value]
						FROM [VW_IX_Cell] C 
						WHERE FileID = @FileID
						AND ([Value] <> '''' AND [Value] IS NOT NULL)
					) T
					PIVOT
					(
						MAX([Value])
						FOR ColumnID IN (' + @Columns + N')
					) P
				), CTE_COUNT AS
				(
					SELECT COUNT(RowID) TotalRows FROM CTE
				)				
				SELECT CTE.RowID, CTE_COUNT.TotalRows
				FROM CTE, CTE_COUNT
				WHERE ' + dbo.FN_ApplyFilters(@T_Filters) + N'
				ORDER BY CTE.RowID
				OFFSET @OffSet ROWS
				FETCH NEXT @PageSize ROWS ONLY';

		SET @OffSet = @PageSize * (@Page -1);

		INSERT INTO @Rows(RowID, TotalRows)		
		EXEC sp_executesql @SQL, N'@Rows TVP_Rows READONLY, @FileID INT, @OffSet INT, @PageSize INT', @Rows, @FileID, @OffSet, @PageSize;
	END
	--Get total Rows
	SELECT TOP 1 @TotalRows = TotalRows FROM @Rows;

	SELECT 
		@Columns2 = COALESCE(@Columns2 + ',', '') + QUOTENAME(ColumnID)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumnID, ColumnNr
	ORDER BY ColumnNr;

	SET @SQL = N'SELECT * FROM
				(
					SELECT 
						C.RowID,
						C.ColumnID,
						C.[Value]
					FROM @Rows R 
					JOIN [VW_IX_Cell] C ON C.RowID = R.RowID 
					WHERE C.FileID = @FileID
					AND (C.[Value] <> '''' AND C.[Value] IS NOT NULL)
				) T
				PIVOT
				(
					MAX([Value])
					FOR ColumnID IN (' + @Columns2 + N')
				) P';

	EXEC sp_executesql @SQL, N'@Rows TVP_Rows READONLY, @FileID INT', @Rows, @FileID;

	SELECT 
		C.ColumnID,
		ColumnLabel = C.ColumLabel,
		ColType = 'NVARCHAR',
		Fixed = CASE WHEN C.ColumLabel IN('Crop', 'GID', 'Plantnr', 'Plant name') THEN 1 ELSE 0 END
	FROM
	(
		SELECT 
			ColumnID = MIN(ColumnID),
			ColumnNr = MIN(ColumnNr),
			ColumLabel
		FROM [Column]
		WHERE FileID = @FileID
		GROUP BY ColumLabel
	) C
	ORDER BY ColumnNr;
END
GO