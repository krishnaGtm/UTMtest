
DROP PROCEDURE IF EXISTS [dbo].[PR_GET_3GBSelected_Data]
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_AddMaterialTO3GB]
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_AddMaterial]
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_GET_Selected_Data]
GO

/*
Authror					Date				Description
KRIAHNA GAUTAM			2019-APril-05		New stored procedure created to make it generic (earllier it was PR_AddMaterialTo3GB)


=================Example===============
DECLARE @TVP_3GBMaterial TVP_3GBMaterial;
--INSERT INTO @TVP_3GBMaterial
--VALUES('245625',0)
--EXEC PR_AddMaterial 2062,'','',@TVP_3GBMaterial
EXEC PR_AddMaterial 2061,'[plant name] like '%'','',@TVP_3GBMaterial


declare @p4 dbo.TVP_3GBMaterial

exec PR_AddMaterial @TestID=2061,@Filter=N'[Plant name]   LIKE  ''%-2%''',@Columns=N'''Plant name''',@TVP_3GBMaterial=@p4

*/

CREATE PROCEDURE [dbo].[PR_AddMaterial]
(
	@TestID INT,
	@Filter NVARCHAR(MAX),
	@Columns NVARCHAR(MAX),
	@TVP_3GBMaterial TVP_3GBMaterial READONLY
) 
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @FileName NVARCHAR(100),@FileID INT, @TVP_3GBMaterialTemp TVP_3GBMaterial, @ColumnQuery NVARCHAR(MAX),@Query NVARCHAR(MAX),@SelectColumns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX),@FilterClause	NVARCHAR(MAX);
		DECLARE @ColumnTable TABLE([ColumnID] INT, [ColumnName] NVARCHAR(100));

		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END

		IF(ISNULL(@Filter,'') <> '') BEGIN
			SET @FilterClause = ' AND '+ @Filter
			
		END
		ELSE BEGIN
			SET @FilterClause = ' ';
		END

		--Assign material from TVP
		IF EXISTS (SELECT TOP 1 * FROM @TVP_3GBMaterial) BEGIN
			MERGE INTO [Row] T
			USING @TVP_3GBMaterial S ON S.MaterialID = T.MaterialKey
			WHEN MATCHED AND T.FileID = @FileID THEN
			UPDATE SET T.Selected = S.Selected;
		END
		
		--Assign material from Query
		ELSE BEGIN
			IF(ISNULL(@Columns,'')<>'') BEGIN
				SET @ColumnQuery = N'
					SELECT ColumnID,ColumnName 
					FROM 
					(
						SELECT ColumnID,COALESCE(CAST(TraitID AS NVARCHAR) ,ColumLabel,'''') as ColumnName FROM [COLUMN]
						WHERE FileID = @FileID 
					) AS T			
					WHERE ColumnName in ('+@Columns+');';

				INSERT INTO @ColumnTable ([ColumnID],[ColumnName])
					EXEC sp_executesql @ColumnQuery, N'@FileID INT', @FileID;

				SELECT 
					@SelectColumns  = COALESCE(@SelectColumns + ',', '') + QUOTENAME([ColumnID])+ ' AS ' + QUOTENAME([ColumnName]),
					@ColumnIDs = COALESCE(@ColumnIDs + ',', '') + QUOTENAME([ColumnID])
				FROM @ColumnTable
			END
			IF(ISNULL(@SelectColumns, '') =  '') BEGIN
				SET @Query = N'		
						SELECT R.[MaterialKey]
						FROM [ROW] R
						WHERE R.FileID = @FileID'
			END
			ELSE BEGIN
				SET @Query = N'		
					SELECT R.[MaterialKey]
					FROM [ROW] R		
					LEFT JOIN 
					(
						SELECT PT.[RowID], ' + @SelectColumns + ' 
						FROM
						(
							SELECT *
							FROM 
							(
								SELECT * FROM dbo.VW_IX_Cell
								WHERE FileID = @FileID 
							) SRC
							PIVOT
							(
								Max([Value])
								FOR [ColumnID] IN (' + @ColumnIDs + ')
							) PIV
						) AS PT 					
					) AS T1	ON R.[RowID] = T1.RowID  				
				WHERE R.FileID = @FileID ' + @FilterClause + '';
			END


			INSERT INTO @TVP_3GBMaterialTemp(MaterialID)
				EXEC sp_executesql @Query, N'@FileID INT', @FileID;

			MERGE INTO [Row] T
			USING @TVP_3GBMaterialTemp S ON S.MaterialID = T.MaterialKey
			WHEN MATCHED AND T.FileID = @FileID THEN
			UPDATE SET T.Selected = 1;
			
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END

GO



/*
Authror					Date				Description
KRIAHNA GAUTAM			2018-DEC-22			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 
KRIAHNA GAUTAM			2019-APril-05		SP Renamed from PR_GET_3GBSelected_Data to PR_GET_Selected_Data To make generic stored procedure to fetch data for 3GB, GMAS and DNA test type


=================Example===============
EXEC PR_GET_Selected_Data 2049,1,100
	
*/

CREATE PROCEDURE [dbo].[PR_GET_Selected_Data]
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
	SELECT @FileID = FileID 
	FROM Test 
	WHERE TestID = @TestID;
	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'Invalid file or test.';
		RETURN;
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
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY
	OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))';
					
	
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT CAST([TraitID] AS NVARCHAR(MAX)), [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column]  WHERE [FileID]= @FileID
	UNION ALL
	SELECT [TraitID] = 'D_Selected', [ColumLabel] = 'Selected', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
	ORDER BY ColumnNr;



END



