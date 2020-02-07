CREATE TYPE TVP_3GBMaterial AS TABLE
(
	MaterialID NVARCHAR(MAX),
	Selected BIT
)
GO

/*
	DECLARE @TVP_3GBMaterial TVP_3GBMaterial
	EXEC PR_AddMaterialTO3GB 2049,4,'','',@TVP_3GBMaterial
*/

CREATE PROCEDURE [dbo].[PR_AddMaterialTO3GB]
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
			SET @FilterClause = '';

		--Assign material from TVP
		IF EXISTS (SELECT 1 FROM @TVP_3GBMaterial) BEGIN
			PRINT 'HERE'
			MERGE INTO [Row] T
			USING @TVP_3GBMaterial S ON S.MaterialID = T.MaterialKey
			WHEN MATCHED THEN
			UPDATE SET T.To3GB = S.Selected;
		END

		--Assign material from Query
		ELSE IF(ISNULL(@Columns,'')<>'') BEGIN
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
					SELECT PT.[MaterialKey], PT.[RowNr], ' + @SelectColumns + ' 
					FROM
					(
						SELECT *
						FROM 
						(
							SELECT 
								T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
							FROM [Cell] T1
							JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
							JOIN [Row] T3 ON T3.RowID = T1.RowID
							JOIN [FILE] T4 ON T4.FileID = T3.FileID
							WHERE T2.FileID = @FileID --AND T4.UserID = @UserID
						) SRC
						PIVOT
						(
							Max([Value])
							FOR [ColumnID] IN (' + @ColumnIDs + ')
						) PIV
					) AS PT 					
				) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '';
		END

		PRINT @Query;

		INSERT INTO @TVP_3GBMaterialTemp(MaterialID)
			EXEC sp_executesql @Query, N'@FileID INT', @FileID;

		MERGE INTO [Row] T
		USING @TVP_3GBMaterialTemp S ON S.MaterialID = T.MaterialKey
		WHEN MATCHED THEN
		UPDATE SET T.To3GB = 1;
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
	EXEC PR_GET_3GBSelected_Data 2049,1,100
*/

CREATE PROCEDURE [dbo].[PR_GET_3GBSelected_Data]
(
	@TestID INT,
	--@User NVARCHAR(100),
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
		SELECT R.[RowNr], R.To3GB, ' + @Columns2 + ' 
		FROM [ROW] R 
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], PT.[RowNr], ' + @Columns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT 
						T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T2.FileID = @FileID 
					--AND T4.UserID = @User
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '
	), Count_CTE AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE) 					
	SELECT CTE.To3GB, '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	--PRINT @Query;
	--EXEC sp_executesql @Query, N'@FileID INT, @User NVARCHAR(100)', @FileID,@User;
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT [TraitID], [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column]  WHERE [FileID]= @FileID
	UNION ALL
	SELECT [TraitID] = NULL, [ColumLabel] = 'To3GB', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
	ORDER BY ColumnNr;



END

GO


ALTER PROCEDURE [dbo].[PR_ImportFromPhenomeFor3GB]
(
	@CropCode				NVARCHAR(10),
	@BrStationCode			NVARCHAR(10),
	@SyncCode				NVARCHAR(2),
	@TestTypeID				INT,
	@TestName				NVARCHAR(200),	
	@Source					NVARCHAR(50),
	@ObjectID				NVARCHAR(100),
	@ThreeGBTaskID			INT,
	@UserID					NVARCHAR(100),
	@TVPColumns TVP_Column	READONLY,
	@TVPRow TVP_Row			READONLY,
	@TVPCell TVP_Cell		READONLY,
	@TestID					INT OUTPUT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		IF EXISTS(SELECT FileTitle FROM [File] F 
		JOIN Test T ON T.FileID = F.FileID WHERE T.BreedingStationCode = @BrStationCode AND F.CropCode = @CropCode AND F.FileTitle = @TestName) BEGIN
			EXEC PR_ThrowError 'File already exists.';
			RETURN;
		END

		IF(ISNULL(@TestTypeID,0)=0) BEGIN
			EXEC PR_ThrowError 'Invalid test type ID.';
			RETURN;
		END

		DECLARE @RowData TABLE([RowID] int,	[RowNr] int	);
		DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);
		DECLARE @FileID INT;

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime], [RefExternal])
		VALUES(@CropCode, @TestName, @UserID, GETUTCDATE(), @ObjectID);
		--Get Last inserted fileid
		SELECT @FileID = SCOPE_IDENTITY();

		INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID])
		OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		SELECT T.RowNr,T.MaterialKey,@FileID FROM @TVPRow T;

		INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		LEFT JOIN Trait T1 ON T1.TraitName = T.ColumLabel
		LEFT JOIN CropTrait CT ON CT.TraitID = T.TraitID AND CT.CropCode = @CropCode
		
		

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[BreedingStationCode],[SyncCode], ThreeGBTaskID)
		VALUES(@TestTypeID, @FileID, @Source, @UserID, @TestName , GETUTCDATE(), 100,@BrStationCode,@SyncCode, @ThreeGBTaskID);
		--Get Last inserted testid
		SELECT @TestID = SCOPE_IDENTITY();

		--CREATE Materials if not already created
		MERGE INTO Material T 
		USING
		(
			SELECT R.MaterialKey
			FROM [Row] R
			WHERE FileID = @FileID		
		) S	ON S.MaterialKey = T.MaterialKey
		WHEN NOT MATCHED THEN 
			INSERT(MaterialType, MaterialKey, [Source], CropCode)
			VALUES ('PLT', S.MaterialKey, @Source, @CropCode);
			
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END

GO

