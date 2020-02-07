
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
	@TestID					INT OUTPUT,
	@FileID					INT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		IF(ISNULL(@FileID,0)=0) BEGIN
			
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
			--DECLARE @FileID INT;

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
			LEFT JOIN 
			(
				SELECT CT.TraitID,T.TraitName, T.ColumnLabel
				FROM Trait T 
				JOIN CropTrait CT ON CT.TraitID = T.TraitID
				WHERE CT.CropCode = @CropCode AND T.Property = 0
			)
			T1 ON T1.ColumnLabel = T.ColumLabel
		
		

			INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
			SELECT [RowID], [ColumnID], [Value] 
			FROM @TVPCell T1
			JOIN @RowData T2 ON T2.RowNr = T1.RowNr
			JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
			WHERE ISNULL(T1.[Value],'')<>'';	

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
				INSERT(MaterialType, MaterialKey, [Source], CropCode,[RefExternal],[BreedingStationCode])
				VALUES ('PLT', S.MaterialKey, @Source, @CropCode,@ObjectID,@BrStationCode);
			
		END
		ELSE BEGIN
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column,@TempTVP_Row TVP_Row;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);
			DECLARE @RowData1 TABLE(RowNr INT,RowID INT,MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeRowTable AS TABLE(OldRowNr INT, NewRowNr INT);
			DECLARE @CropCode1 NVARCHAR(10);

			SELECT 
				@CropCode1 = F.CropCode,
				@SyncCode=T.SyncCode,
				@TestTypeID = T.TestTypeID,
				@UserID = T.RequestingUser,
				@TestName = F.FileTitle,
				@TestName = T.TestName,
				@Source = T.RequestingSystem,
				@TestID = T.TestID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID

			if(ISNULL(@CropCode1,'') <> ISNULL(@CropCode,'')) BEGIN
				EXEC PR_ThrowError 'Material cannot be imported for different crop on this test.';
				RETURN;
			END

			INSERT INTO @TempTVP_Cell(RowNr,ColumnNr,[Value])
			SELECT RowNr,ColumnNr,[Value] FROM @TVPCell


			INSERT INTO @TempTVP_Column(ColumnNr,ColumLabel,DataType,TraitID)
			SELECT ColumnNr,ColumLabel,DataType,TraitID FROM @TVPColumns;

			INSERT INTO @TempTVP_Row(RowNr,MaterialKey)
			SELECT RowNr,Materialkey FROM @TVPRow;
			
			--get maximum column number inserted in column table.
			SELECT @LastColumnNr = ISNULL(MAX(ColumnNr), 0)
			FROM [Column] 
			WHERE FileID = @FileID;

			--get maximum row number inserted on row table.
			SELECT @LastRowNr = ISNULL(MAX(RowNr),0)
			FROM [Row] R 
			WHERE FileID = @FileID;

			SET @LastColumnNr = @LastRowNr + 1;
			SET @LastColumnNr = @LastColumnNr + 1;

			--get only new columns which are not imported already
			INSERT INTO @NewColumns (ColumnNr, TraitID, ColumLabel, DataType, NewColumnNr)
				SELECT 
					ColumnNr,
					TraitID, 
					ColumLabel, 
					DataType,
					ROW_NUMBER() OVER(ORDER BY ColumnNr) + @LastColumnNr
				FROM @TVPColumns T1
				WHERE NOT EXISTS
				(
					SELECT ColumnID 
					FROM [Column] C 
					WHERE C.ColumLabel = T1.ColumLabel AND C.FileID = @FileID
				)
				ORDER BY T1.ColumnNr;

				--insert into new temp row table
				INSERT INTO @TempRow(MaterialKey)
				SELECT T1.MaterialKey FROM @TVPRow T1
				WHERE NOT EXISTS
				(
					SELECT R1.MaterialKey FROM [Row] R1 
					JOIN @TVPRow R2 ON R2.MaterialKey = R1.MaterialKey
					WHERE R1.FileID = @FileID AND T1.MaterialKey = R1.MaterialKey
				);

				--now insert into row table if material is not availale 
				INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID,RowNr,MaterialKey)
				SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T;

				--now insert new columns if available which are not already available on table
				INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
				--OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
				SELECT T1.[NewColumnNr], T.[TraitID], T1.[ColumLabel], @FileID, T1.[DataType] 
				FROM @NewColumns T1
				LEFT JOIN 
				(
					SELECT CT.TraitID,T.TraitName, T.ColumnLabel
					FROM Trait T 
					JOIN CropTrait CT ON CT.TraitID = T.TraitID
					WHERE CT.CropCode = @CropCode AND T.Property = 0
				)
				T ON T.ColumnLabel = T1.ColumLabel


				INSERT INTO @BridgeColumnTable(OldColNr,NewColNr)
				SELECT T.ColumnNr,C.ColumnNr FROM 
				[Column] C
				JOIN @TempTVP_Column T ON T.ColumLabel = C.ColumLabel
				WHERE C.FileID = @FileID

				INSERT INTO @ColumnData(ColumnID,ColumnNr)
				SELECT ColumnID, ColumnNr FROM [Column] 
				WHERE FileID = @FileID;


				--update this to match previous column with new one if column order changed or new columns inserted.
				UPDATE T1 SET 
					 T1.ColumnNr = T2.NewColNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeColumnTable T2 ON T1.ColumnNr = T2.OldColNr;

				--update row number if new row added which are already present for that file or completely new row are available on  SP Parameter TVP_ROw
				INSERT INTO @BridgeRowTable(NewRowNr,OldRowNr)
				SELECT T1.RowNr,T2.RowNr FROM @RowData1 T1
				JOIN @TVPRow T2 ON T1.MaterialKey = T2.MaterialKey


				UPDATE T1 SET
					T1.RowNr = T2.NewRowNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeRowTable T2 ON T1.RowNr = T2.OldRowNr;


				INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
				SELECT T2.[RowID], T3.[ColumnID], T1.[Value] 
				FROM @TempTVP_Cell T1
				JOIN @RowData1 T2 ON T2.RowNr = T1.RowNr
				JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
				WHERE ISNULL(T1.[Value],'')<>'';
					
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey
					FROM [Row] R
					WHERE FileID = @FileID		
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode,[RefExternal],[BreedingStationcode])
					VALUES ('PLT', S.MaterialKey, @Source, @CropCode,@ObjectID,@BrStationCode);
		END

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END

GO



/*
Authror					Date				Description
KRISHNA GAUTAM			2018-OCT-01			Get Material and with assigned Marker data for external test.
KRIAHNA GAUTAM			2018-DEC-22			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 

=================Example===============
	
*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarkerForExternalTest]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));

	
	SELECT @FileID = F.FileID
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID 


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnLabel)
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T.ColumnLabel AS ColumnLabel			
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID			
		WHERE T1.TestID = @TestID		
		GROUP BY T1.DeterminationID,T.ColumnLabel	
	) V1
	ORDER BY V1.ColumnLabel;
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
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType <> 1
	ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(

					SELECT MaterialKey,RowNr,ColumnID,Value
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
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(
					SELECT MaterialKey,RowNr,ColumnID,Value
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
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY;';

		SET @Offset = @PageSize * (@Page -1);

		PRINT @QUERY;

		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY ColumnNr;
END

GO




/*

Authror					Date				Description
KRISHNA GAUTAM			2017-DEC-04			Get Material and with assigned Marker data.
KRIAHNA GAUTAM			2018-FEB-26			Performance optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup

=================Example===============
EXEC [PR_GetMaterialWithMarker] 3095,1, 150, ''

*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarker]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(50), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));


	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR)
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
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
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID,ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	--ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType <> 1
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, NrOfSamples, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, NrOfSamples, ' + @Columns2 + N'  FROM 
				(
					SELECT MaterialKey,RowNr,NrOfSamples,ColumnID,Value
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
					
					SELECT MaterialKey,RowNr,NrOfSamples,ColumnID,Value
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
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, NrOfSamples, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY;';

		SET @Offset = @PageSize * (@Page -1);

		
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		

		--add columns for NrOfSamples
		IF(@ImportLevel = 'LIST') BEGIN
			INSERT INTO @TblColumns(ColumnLabel, ColumnType, DataType, ColumnNr)
			VALUES('NrOfSamples', 2, 'NVARCHAR(255)', 0);
		END

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY ColumnNr;
END

GO


/*
Authror					Date				Description
KRISHNA GAUTAM			2019-JAN-21			Get data of external test.
KRIAHNA GAUTAM			2019-MAR-27			Performance Optimization and code cleanup 

=================Example===============
EXEC PR_GetExternalTestDataForExport 2071,0
*/

ALTER PROCEDURE [dbo].[PR_GetExternalTestDataForExport]
(
	@TestID INT,
	@MarkAsExported BIT = 0
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @MarkerColumns NVARCHAR(MAX), @MarkerColumnIDs NVARCHAR(MAX), @Columns NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @Query NVARCHAR(MAX);
	DECLARE @TblMarkerColumns TABLE(ColumnID INT, ColumnLabel NVARCHAR(100));
	DECLARE @TblColumns TABLE(ColumnID INT, ColumnLabel NVARCHAR(100));
	DECLARE @FileID INT;

	SELECT @FileID = FileID 
	FROM Test WHERE TestID = @TestID;

	--Get Markers columns only
	INSERT INTO @TblMarkerColumns(ColumnID, ColumnLabel)
	SELECT DISTINCT
		TMD.DeterminationID,
		D.DeterminationName
	FROM TestMaterialDetermination TMD
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TMD.DeterminationID
	JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	WHERE TMD.TestID = @TestID;

	--Get columns of imported file
	INSERT INTO @TblColumns(ColumnID, ColumnLabel)
	SELECT 
		C.ColumnID,
		C.ColumLabel
	FROM [Column] C
	JOIN Test T ON T.FileID = C.FileID
	WHERE T.TestID = @TestID;

	--Get columns of markers
	SELECT 
		@MarkerColumnIDs  = COALESCE(@MarkerColumnIDs + ',', '') + QUOTENAME(ColumnID) + ' AS ' + QUOTENAME('D_' + CAST(ColumnID AS VARCHAR(10))),
		@MarkerColumns  = COALESCE(@MarkerColumns + ',', '') + QUOTENAME(ColumnID)
	FROM @TblMarkerColumns;

	--Get columns of test
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns;

	IF(ISNULL(@Columns,'') = '') BEGIN
		EXEC PR_ThrowError 'Didn''t find any data to export';
		RETURN;
	END

	IF(ISNULL(@MarkerColumns,'') = '') BEGIN
		EXEC PR_ThrowError 'Didn''t find any determinations to export';
		RETURN;
	END

	SET @Query = N'SELECT V1.*, '  + @MarkerColumnIDs + '  FROM
	(
		SELECT MaterialKey, ' + @Columns + N' 
		FROM 
		(
			SELECT MaterialKey,ColumnID,[Value] FROM dbo.VW_IX_Cell_Material
			WHERE FileID = @FileID
			AND ISNULL([Value],'''')<>'''' 

		) SRC
		PIVOT
		(
			Max([Value])
			FOR [ColumnID] IN (' + @Columns + N')
		) PV
	) V1
	LEFT JOIN 
	(
		SELECT *
		FROM 
		(
			SELECT
				M.MaterialKey,
				D.DeterminationID,
				Result = TR.ObsValueChar	
			FROM Test T
			JOIN [Row] R ON R.FileID = T.FileID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN Plate P ON P.TestID = T.TestID
			JOIN Well W ON W.PlateID = P.PlateID
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
			JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
			JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
			JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
			WHERE T.TestID = @TestID
			--AND T.StatusCode >= 600
		) SRC 
		PIVOT
		(
			MAX(Result)
			FOR [DeterminationID] IN (' + @MarkerColumns + N')
		) PV
	) V2 ON V2.MaterialKey = V1.MaterialKey';

	PRINT @Query;

	EXEC sp_executesql @Query, N'@TestID INT, @FileID INT', @TestID, @FileID;

	--get colums informations
	SELECT 
		ColumnID = CAST(C1.ColumnID AS VARCHAR(10)),
		C1.ColumnLabel
	FROM @TblColumns C1
	UNION ALL
	SELECT 
		CONCAT('D_', CAST(C2.ColumnID AS VARCHAR(10))),
		C2.ColumnLabel 
	FROM @TblMarkerColumns C2;

	--update test with today's date if it was marked as exported
	IF(@MarkAsExported = 1) BEGIN
		UPDATE Test SET StatusCode = 700 WHERE TestID = @TestID;
	END
END

Go




/*
Authror					Date				Description
KRISHNA GAUTAM			2018-OCT-01			Get Material and with assigned Marker data
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 

=================Example===============
EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
EXEC [PR_GetDataWithMarkers] 1030, 1, 200, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(50), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15),MateriallblColumn BIT);
	DECLARE @PlateAndWellAssigned BIT = 0; --here we have to check whether well and plate is assigned previously or not.. for now we set it to false 
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = '';
	DECLARE @FixedWellTypeID INT,@DeadWellTypeID INT;

	SELECT @FixedWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'F';
	SELECT @DeadWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'D';

	SELECT @FileID = F.FileID, @FileName = T.TestName, @Crop = CropCode, @Source = T.RequestingSystem
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID AND T.RequestingUser = F.UserID;

	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'File or test doesn''t exist.';
		RETURN;
	END

	--CREATE PLATE AND WELLS IF REQUIRED
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
				T4.ColumLabel,
				ColumnNR = MAX(T4.ColumnNR)
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
	END
	ELSE BEGIN
		INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
			SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnLabel),0
			FROM
			(	
				SELECT 
					T1.DeterminationID,
					CONCAT('D_', T1.DeterminationID) AS TraitID,
					T.ColumnLabel			
				FROM TestMaterialDetermination T1
				JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
				JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
				JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
				JOIN Trait T ON T.TraitID = CT.TraitID				
				WHERE T1.TestID = @TestID			
				GROUP BY T1.DeterminationID,T.ColumnLabel	
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
	
	--get dynamic columns
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType <> 1
	ORDER BY [ColumnNr] ASC;

	SET @SQL = N';WITH CTE AS 
	(
		SELECT V1.MaterialID, V1.MaterialKey, V1.PlateID, V1.Plate, V1.WellID, V1.Well,
		V1.WellTypeID, V1.Fixed,
		' + @Columns3 + N'
		FROM 
		(
			SELECT
				MaterialID, 
				MaterialKey,
				PlateID, 
				Plate, 
				WellID,
				Well,				
				WellTypeID,
				Fixed = CAST((CASE WHEN (WellTypeID = @FixedWellTypeID OR WellTypeID = @DeadWellTypeID) THEN 1 ELSE 0 END) AS BIT)
			FROM dbo.VW_IX_TMDW_Mat_Well
			WHERE TestID = @TestID
			
		) V1
		JOIN 
		(
			--trait and property columns
			SELECT MaterialKey, ' + @Columns2 + N'  FROM 
			(
				SELECT MaterialKey,ColumnID,Value FROM dbo.VW_IX_Cell_Material
				WHERE FileID = @FileID
				AND ISNULL([Value],'''')<>'''' 
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
	), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
	SELECT CTE.MaterialID,CTE.WellTypeID, CTE.WellID, CTE.Fixed, CTE.Plate, CTE.Well, --[Replica] = CASE WHEN  ISNULL(CTE.ReplicaCount,0)> 0 THEN 1 ELSE 0 END, 
	' + @Columns3 + N', CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY PlateID, Well
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;';
	
	SET @Offset = @PageSize * (@Page -1);
	
	EXEC sp_executesql @SQL , N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT, @FixedWellTypeID INT, @DeadWellTypeID INT', @FileID, @Offset, @PageSize, @TestID, @FixedWellTypeID, @DeadWellTypeID;

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

GO



/*
Authror					Date				Description
KRISHNA GAUTAM			2018-NOv-24			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 

=================Example===============
EXEC PR_GET_Data 56,'KATHMANDU\dsuvedi', 1, 3, '[Lotnr]   LIKE  ''%9%''   and [Crop]   LIKE  ''%LT%'''
EXEC PR_GET_Data 2090, 1, 100, ''
*/
ALTER PROCEDURE [dbo].[PR_GET_Data]
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
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(MAX(ColumnID)) +' AS '+ MAX(Datatype) +')' + ' AS ' + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	--ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END

	SET @Query = N' ;WITH CTE AS 
	(
		SELECT R.RowID, R.[RowNr], ' + @Columns2 + ' 
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
	), Count_CTE AS (SELECT COUNT([RowID]) AS [TotalRows] FROM CTE) 					
	SELECT CTE.RowID, '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT [TraitID], [ColumLabel] as ColumnLabel, DataType = MAX([DataType]),ColumnNr = MAX([ColumnNr]),CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column] 
	WHERE [FileID]= @FileID
	GROUP BY ColumLabel,TraitID
	ORDER BY ColumnNr;
	

END

GO


/*
Authror					Date				Description
KRIAHNA GAUTAM			2018-DEC-22			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 

=================Example===============
EXEC PR_GET_3GBSelected_Data 2049,1,100
	
*/

ALTER PROCEDURE [dbo].[PR_GET_3GBSelected_Data]
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
		SELECT R.[RowNr], D_To3GB = R.To3GB, R.MaterialKey, ' + @Columns2 + ' 
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
	SELECT CTE.MaterialKey, CTE.D_To3GB , '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT CAST([TraitID] AS NVARCHAR(MAX)), [ColumLabel] as ColumnLabel, [DataType],[ColumnNr],CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column]  WHERE [FileID]= @FileID
	UNION ALL
	SELECT [TraitID] = 'D_to3GB', [ColumLabel] = 'To3GB', [DataType] = 'NVARCHAR(255)', [ColumnNr] = 0,IsTraitColumn = 0, Fixed = 1
	ORDER BY ColumnNr;



END

GO