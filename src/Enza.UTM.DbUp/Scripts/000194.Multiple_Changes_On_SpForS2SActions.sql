
DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaterialWithMarker_ForS2s]
GO


/*

Author					Date				Description
KRISHNA GAUTAM			2019-MAY-03			Get Material and with assigned Marker data.
KRISHNA GAUTAM			2019-MAY-08			Marker and determinations is fetched from New table created for S2S which is S2SDonorMarkerScore

=================Example===============
EXEC PR_GetMaterialWithMarker_ForS2s 4295,1, 150, ''

*/
CREATE PROCEDURE [dbo].[PR_GetMaterialWithMarker_ForS2s]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Columns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX),@Columns4 NVARCHAR(MAX), @ColumnIDS4 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(50), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));


	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT) * 2) -1
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
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
	SELECT DeterminationID, TraitID, ColumLabel, 10, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT)) * 2
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('score_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
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


	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 2, (MAX(ColumnNr) + @Total), MAX(DataType)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	
	--get Get Determination Column
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	--get score column
	SELECT 
		@Columns4  = COALESCE(@Columns4 + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs4  = COALESCE(@ColumnIDs4 + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 10
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
	WHERE ColumnType IN (1,10)
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType NOT IN (1,10)
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, M.MaterialKey, NrOfSamples, ' + @Columns3 + N'
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
			SELECT M.MaterialID, T1.RowNr, M.MaterialKey, NrOfSamples, ' + @Columns3 + N'
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
					WHERE T1.TestID = @TestID
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

		update @TblColumns set ColumnType = 1 where ColumnType = 10;

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY Columntype,ColumnNr;
END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_Import_s2s_Material]
GO

/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			SP Created to Import material for S2S process.

========Example=============

*/

CREATE PROCEDURE [dbo].[PR_Import_s2s_Material]
(
	@CropCode						NVARCHAR(10),
	@BreedingStationCode			NVARCHAR(10),
	@SyncCode						NVARCHAR(2),
	@TestTypeID						INT,
	@UserID							NVARCHAR(100),
	@FileTitle						NVARCHAR(200),
	@TestName						NVARCHAR(200),
	@TVPColumns TVP_Column			READONLY,
	@TVPRow TVP_Row					READONLY,
	@TVPCell TVP_Cell				READONLY,
	@PlannedDate					DATETIME,
	@MaterialStateID				INT,
	@MaterialTypeID					INT,
	@ContainerTypeID				INT,
	@Isolated						BIT,
	@Source							NVARCHAR(50),
	@TestID							INT OUTPUT,
	@ObjectID						NVARCHAR(100),
	@ExpectedDate					DATETIME,
	@Cumulate						BIT,
	@ImportLevel					NVARCHAR(20),
	@TVPList TVP_List				READONLY,
	@TVPCapacityS2s TVPCapacityS2s	READONLY,
	@FileID							INT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @CapacitySlotID INT;

		--import data as new test/file
		IF(ISNULL(@FileID,0) = 0) 
		BEGIN
			SELECT @CapacitySlotID = CapacitySlotID FROM @TVPCapacityS2s;

			IF(ISNULL(@CapacitySlotID,0)=0) BEGIN
				EXEC PR_ThrowError 'Invalid Capacity Slot';
				RETURN;
			END
			IF EXISTS(SELECT FileTitle FROM [File] F 
			JOIN Test T ON T.FileID = F.FileID WHERE T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode AND F.FileTitle =@FileTitle) BEGIN
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

			INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
			VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE());
			--Get Last inserted fileid
			SELECT @FileID = SCOPE_IDENTITY();

			INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
			OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
			SELECT T.RowNr,T.MaterialKey,@FileID, 1 FROM @TVPRow T;

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
			INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],
				[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode],[Cumulate], [ImportLevel],CapacitySlotID)
			VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, 
				@Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode, @Cumulate, @ImportLevel,@CapacitySlotID);
			--Get Last inserted testid
			SELECT @TestID = SCOPE_IDENTITY();

			--CREATE Materials if not already created

			IF(@Source = 'Phenome') BEGIN
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey,Max(L.RowID) as RowID
					FROM @TVPRow R
					JOIN @TVPList L ON R.GID = L.GID --AND R.EntryCode = L.EntryCode
					GROUP BY R.MaterialKey
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal,BreedingStationCode)
					VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID,@BreedingStationCode)
				WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
					UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID ,BreedingStationCode = @BreedingStationCode;

			END
			ELSE BEGIN
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey
					FROM [Row] R
					WHERE FileID = @FileID		
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode)
					VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode);

			END

		END

		--import data to existing test/file
		ELSE BEGIN
			--SELECT * FROM Test
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TempTVP_Row TVP_Row, @TVP_Material TVP_Material, @TVP_Well TVP_Material,@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,@PlateID INT,@TotalRows INT,@AssignedWellTypeID INT, @EmptyWellTypeID INT,@TotalMaterial INT;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);
			DECLARE @RowData1 TABLE(RowNr INT,RowID INT,MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeRowTable AS TABLE(OldRowNr INT, NewRowNr INT);
			DECLARE @StatusCode INT;

			DECLARE @CropCode1 NVARCHAR(10),@BreedingStationCode1 NVARCHAR(10),@SyncCode1 NVARCHAR(2);

			SELECT 
				@CropCode1 = F.CropCode,
				@BreedingStationCode1 = T.BreedingStationCode,
				@SyncCode1 = T.SyncCode,
				@TestTypeID = T.TestTypeID,
				@UserID = T.RequestingUser,
				@FileTitle = F.FileTitle,
				@TestName = T.TestName,
				@PlannedDate = T.PlannedDate,
				@MaterialStateID = T.MaterialStateID,
				@MaterialTypeID = T.MaterialTypeID,
				@ContainerTypeID = T.ContainerTypeID,
				@Isolated = T.Isolated,
				@Source = T.RequestingSystem,
				@ExpectedDate = T.ExpectedDate,
				@Cumulate = T.Cumulate,
				@TestID = T.TestID,
				@CapacitySlotID = T.CapacitySlotID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID

			SELECT @StatusCode = Statuscode FROM Test WHERE TestID = @TestID

			IF(@StatusCode >=200) BEGIN
				EXEC PR_ThrowError 'Cannot import material to this test after plate is requested on LIMS.';
				RETURN;
			END
	
			IF(ISNULL(@CropCode1,'')<> ISNULL(@CropCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different crop  to this test.';
				RETURN;
			END
			IF(ISNULL(@BreedingStationCode1,'')<> ISNULL(@BreedingStationCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different breeding station to this test.';
				RETURN;
			END
			IF(ISNULL(@SyncCode1,'')<> ISNULL(@SyncCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different sync code code to this test.';
				RETURN;
			END
			SELECT @AssignedWellTypeID = WellTypeID 
			FROM WellType WHERE WellTypeName = 'A';

			SELECT @EmptyWellTypeID = WellTypeID 
			FROM WellType WHERE WellTypeName = 'E';


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

			SET @LastRowNr = @LastRowNr + 1;
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
				SELECT T1.MaterialKey FROM @TempTVP_Row T1
				WHERE NOT EXISTS
				(
					SELECT R1.MaterialKey FROM [Row] R1 
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

				--DELETE T FROM @TempTVP_Cell T
				--WHERE NOT EXISTS
				--(
				--	SELECT T1.OldRowNr FROM @BridgeRowTable T1
				--	WHERE T1.OldRowNr = T.RowNr
				--)


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
								

				IF(@Source = 'Phenome') BEGIN
					MERGE INTO Material T 
					USING
					(
						SELECT R.MaterialKey,Max(L.RowID) as RowID
						FROM @TVPRow R
						LEFT JOIN @TVPList L ON R.GID = L.GID --AND R.EntryCode = L.EntryCode
						GROUP BY R.MaterialKey
					) S	ON S.MaterialKey = T.MaterialKey
					WHEN NOT MATCHED THEN 
						INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal, BreedingStationCode)
						VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID, @BreedingStationCode)
					WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
						UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID, BreedingStationCode= @BreedingStationCode;
					

				END
				ELSE BEGIN
					MERGE INTO Material T 
					USING
					(
						SELECT R.MaterialKey
						FROM [Row] R
						WHERE FileID = @FileID		
					) S	ON S.MaterialKey = T.MaterialKey
					WHEN NOT MATCHED THEN 
						INSERT(MaterialType, MaterialKey, [Source], CropCode)
						VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode);

				END

				--recalculate platefilling screen now
				IF EXISTS (SELECT * FROM @RowData1) BEGIN
								
					IF(@ImportLevel = 'LIST') BEGIN
						EXEC PR_PlateFillingForGroupTesting @TestID
					END
					ELSE BEGIN
						SELECT @PlatesCreated = COUNT(PlateID)
						FROM Plate P
						JOIN Test T ON T.TestID = P.TestID
						WHERE T.TestID = @TestID;
					END
				END

		END

		MERGE INTO S2SCapacitySlot T
		USING @TVPCapacityS2s S
		ON S.CapacitySlotID = T.CapacitySlotID
		WHEN NOT MATCHED THEN 
		INSERT (CapacitySlotID,MaxPlants,CordysStatus,DH0Location,AvailPlants)
		VALUES(S.CapacitySlotID,S.MaxPlants,S.CordysStatus,S.DH0Location,S.AvailPlants)
		WHEN MATCHED THEN 
		UPDATE SET MaxPlants = S.MaxPlants,CordysStatus = S.CordysStatus,AvailPlants = S.AvailPlants;


		COMMIT;

	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END

GO



DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithQuery_ForS2S]
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForS2S]
GO

DROP TYPE IF EXISTS [dbo].[TVP_TMD_WithScore]
GO

CREATE TYPE [dbo].[TVP_TMD_WithScore] AS TABLE(
	[MaterialID] [int] NOT NULL,
	[DeterminationID] [int] NOT NULL,
	[Selected] [bit] NULL,
	[Score] [nvarchar](max) NULL
)
GO

/*
Author					Date				Description
KRISHNA GAUTAM			2018-JAN-11			Save test material determination.

=================Example===============
EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
EXEC [PR_GetDataWithMarkers1] 4260, 1, 1000, ''

=================Example===============

*/
CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
(
	@TestTypeID							INT,
	@TestID								INT,
	@Columns							NVARCHAR(MAX) = NULL,
	@Filter								NVARCHAR(MAX) = NULL,
	@TVPM TVP_TMD_WithScore				READONLY,	
	@Determinations TVP_Determinations	READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileName NVARCHAR(100);
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @CropCode	NVARCHAR(10),@TestType1 INT,@StatusCode INT;
	DECLARE @FileID		INT;


	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle,
			@CropCode = CropCode,
			@TestType1 = T.TestTypeID,
			@StatusCode = T.StatusCode
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID --AND F.UserID = @UserID;

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END
		IF(ISNULL(@CropCode,'')='')
		BEGIN
			EXEC PR_ThrowError 'Specified crop not found';
			RETURN;
		END
		--Prevent changing testType when user choose different type of test after creating test.
		IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestType1,0)) BEGIN
			EXEC PR_ThrowError 'Cannot assign different test type for already created test.';
			RETURN;
		END
		--Prevent asigning determination when status is changed to point of no return
		IF(ISNULL(@StatusCode,0) >=400) BEGIN
			EXEC PR_ThrowError 'Cannot assign determination for confirmed test.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM @Determinations) BEGIN			
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForS2S @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
			EXEC PR_SaveTestMaterialDeterminationWithTVP_ForS2S @CropCode, @TestID, @TVPM
		END

		IF EXISTS(SELECT TestID FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
			EXEC PR_Update_TestStatus @TestID, 350;
		END
		SELECT TestID, StatusCode 
		FROM Test WHERE TestID = @TestID;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END
GO




/*
Author					Date				Description
KRISHNA GAUTAM			2019-Apr-23			Stored procedure created

=================Example===============
DECLARE @T1 TVP_Determinations
INSERT INTO @T1 VALUES(1);
INSERT INTO @T1 VALUES(6);
PR_SaveTestMaterialDeterminationWithQuery_ForS2S 4052, 1, '''712'',''715'',''Lotnr''', '', @T1
*/

CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithQuery_ForS2S]
(
	@FileID			INT,	
	--@UserID			NVARCHAR(50),
	@CropCode		NVARCHAR(10),
	@TestID			INT,
	@Columns		NVARCHAR(MAX) = NULL,
	@Filter	NVARCHAR(MAX) = NULL,
	@Determinations TVP_Determinations READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @ColumnQuery	NVARCHAR(MAX);
	DECLARE @Query			NVARCHAR(MAX);
	DECLARE @FilterClause	NVARCHAR(MAX)
	DECLARE @ColumnIDs		NVARCHAR(MAX);
	DECLARE @SelectColumns	NVARCHAR(MAX);
	DECLARE @TraitIDs		NVARCHAR(MAX);
	DECLARE @Tbl			TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @ColumnTable	TABLE([ColumnID] INT, [ColumnName] NVARCHAR(100));
	DECLARE @MaterialTable	TABLE(MaterialKey NVARCHAR(100));


	IF(ISNULL(@Filter,'') <> '') BEGIN
		SET @FilterClause = ' AND '+ @Filter
	END
	ELSE BEGIN
		SET @FilterClause = '';
	END
	IF(ISNULL(@Columns,'') <> '') BEGIN
		SET @ColumnQuery = N'
			SELECT ColumnID,ColumnName 
			FROM 
			(
				SELECT ColumnID,COALESCE(CAST(TraitID AS NVARCHAR) ,ColumLabel,'''') as ColumnName FROM [COLUMN]
				WHERE FileID = @FileID 
			) AS T			
			WHERE ColumnName in ('+@Columns+');';

			--PRINT @ColumnQuery;

		INSERT INTO @ColumnTable ([ColumnID],[ColumnName])
		EXEC sp_executesql @ColumnQuery, N'@FileID INT', @FileID;
		
		SELECT 
			@SelectColumns  = COALESCE(@SelectColumns + ',', '') + QUOTENAME([ColumnID])+ ' AS ' + QUOTENAME([ColumnName]),
			@ColumnIDs = COALESCE(@ColumnIDs + ',', '') + QUOTENAME([ColumnID])
		FROM @ColumnTable
		
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
					WHERE T2.FileID = @FileID
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '';

		--PRINT @Query

		INSERT INTO @MaterialTable ([MaterialKey])		
		--EXEC sp_executesql @Query, N'@FileID INT, @UserID NVARCHAR(100)', @FileID,@UserID;
		EXEC sp_executesql @Query, N'@FileID INT', @FileID;
	END
	ELSE BEGIN 
		INSERT INTO @MaterialTable ([MaterialKey])
		SELECT R.[MaterialKey]
		FROM [ROW] R
		WHERE R.FileID = @FileID	
	END;

	INSERT INTO @Tbl (MaterialID , MaterialKey)
	SELECT M.MaterialID, M.MaterialKey 
	FROM Material M
	JOIN @MaterialTable M2 ON M2.MaterialKey = M.MaterialKey;

		
	MERGE INTO S2SDonorMarkerScore T
	USING 
	( 
		SELECT 
			M.MaterialID, D.DeterminationID 
		FROM @Tbl M 
		CROSS JOIN 
		(
			SELECT DeterminationID  
			FROM @Determinations 
			GROUP BY DeterminationID
		) D 
		
	) S
	ON T.MaterialID = S.MaterialID AND T.TestID = @TestID AND T.DeterminationID = S.DeterminationID
	WHEN NOT MATCHED THEN 
	INSERT(TestID,MaterialID,DeterminationID) VALUES(@TestID,S.MaterialID,s.DeterminationID);
		
END
GO


/*
Author					Date				Description
KRISHNA GAUTAM			2019-Apr-23			Stored procedure created

=================Example===============

*/

CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForS2S]
(	
	@CropCode		NVARCHAR(15),
	@TestID			INT,	
	@TVPM TVP_TMD_WithScore	READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));

	INSERT INTO @Tbl (MaterialID, MaterialKey)
	SELECT M.MaterialID, M.MaterialKey
	FROM Material M
	JOIN
	(
		SELECT DISTINCT MaterialID 
		FROM @TVPM 
		--WHERE Selected = 1
	) M2 ON M2.MaterialID = M.MaterialID;

	--insert or delete statement for merge
	MERGE INTO S2SDonorMarkerScore T 
	USING 
	(
		SELECT T2.MaterialID,T1.DeterminationID,T1.Selected,T1.Score FROM @TVPM T1
		LEFT JOIN @Tbl T2 ON T1.MaterialID = T2.MaterialID			
	) S
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.Score,'') != ISNULL(S.Score,'')
		THEN UPDATE SET T.Score = S.Score
		--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,Score) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.Score);
END

GO


