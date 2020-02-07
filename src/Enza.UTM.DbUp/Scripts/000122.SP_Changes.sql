
ALTER PROCEDURE [dbo].[PR_Insert_ExcelData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(2),
	@TestTypeID				INT,
	@UserID					NVARCHAR(100),
	@FileTitle				NVARCHAR(200),
	@TestName				NVARCHAR(200),
	@TVPColumns TVP_Column	READONLY,
	@TVPRow TVP_Row			READONLY,
	@TVPCell TVP_Cell		READONLY,
	@PlannedDate			DATETIME,
	@MaterialStateID		INT,
	@MaterialTypeID			INT,
	@ContainerTypeID		INT,
	@Isolated				BIT,
	@Source					NVARCHAR(50),
	@TestID					INT OUTPUT,
	@ObjectID				NVARCHAR(100),
	@ExpectedDate			DATETIME,
	@Cumulate				BIT,
	@ImportLevel			NVARCHAR(20),
	@TVPList TVP_List		READONLY,
	@FileID					INT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		--import data as new test/file
		IF(ISNULL(@FileID,0) = 0) BEGIN
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
			JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

			--CREATE TEST
			INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],
				[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode],[Cumulate], [ImportLevel])
			VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, 
				@Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode, @Cumulate, @ImportLevel);
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
					INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal)
					VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID)
				WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
					UPDATE  SET T.OriginrowID = S.RowID;

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
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TVP_Material TVP_Material, @TVP_Well TVP_Material,@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,@PlateID INT,@TotalRows INT,@AssignedWellTypeID INT, @EmptyWellTypeID INT,@TotalMaterial INT;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);

			SELECT 
				@CropCode = F.CropCode,
				@BreedingStationCode=T.BreedingStationCode,
				@SyncCode=T.SyncCode,
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
				@TestID = T.TestID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID
	
			SELECT @AssignedWellTypeID = WellTypeID 
			FROM WellType WHERE WellTypeName = 'A';

			SELECT @EmptyWellTypeID = WellTypeID 
			FROM WellType WHERE WellTypeName = 'E';


			INSERT INTO @TempTVP_Cell(RowNr,ColumnNr,[Value])
			SELECT RowNr,ColumnNr,[Value] FROM @TVPCell

			INSERT INTO @TempTVP_Column(ColumnNr,ColumLabel,DataType,TraitID)
			SELECT ColumnNr,ColumLabel,DataType,TraitID FROM @TVPColumns;

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
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr] - @LastRowNr INTO @RowData
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


				UPDATE T1 SET 
					 T1.ColumnNr = T2.NewColNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeColumnTable T2 ON T1.ColumnNr = T2.OldColNr;

				INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
				SELECT [RowID], [ColumnID], [Value] 
				FROM @TempTVP_Cell T1
				JOIN @RowData T2 ON T2.RowNr - 1 = T1.RowNr
				JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;


				

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
						INSERT(MaterialType, MaterialKey, [Source], CropCode,Originrowid,RefExternal)
						VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID);
					

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
				IF EXISTS (SELECT * FROM @RowData) BEGIN					
					IF(@ImportLevel = 'LIST') BEGIN
						EXEC PR_PlateFillingForGroupTesting @TestID
					END
					ELSE BEGIN
						SELECT @PlatesCreated = COUNT(PlateID)
						FROM Plate P
						JOIN Test T ON T.TestID = P.TestID
						WHERE T.TestID = @TestID;

						--if plate is not created then it will be created at the time of calling Stored procedure PR_CreatePlateAndWell
						--this will be called first time when we open plate filling screen.
						--otherwise we have to call recalculation logic again
						IF(ISNULL(@PlatesCreated,0)> 0) BEGIN
							
							SELECT TOP 1 @LastPlateID = PlateID, @PlateID = PlateID FROM Plate
							WHERE TestID = @TestID
							ORDER BY PlateID DESC;

							SELECT @WellsPerPlate = COUNT(WellID) FROM Well
							WHERE PlateID = @LastPlateID;
							
							--calculate palte required here
							SELECT @TotalRows = COUNT(TestMaterialDeterminationWellID)
							FROM TestMaterialDeterminationWell TMDW
							JOIN Well W ON W.WellID = TMDW.WellID
							JOIN Plate P ON P.PlateID = W.PlateID
							WHERE P.TestID = @TestID;

							SELECT @TotalRows = @TotalRows + COUNT(RowID)
							FROM @RowData


							SELECT @PlatesRequired = CEILING (CAST(@TotalRows AS FLOAT) / CAST(@WellsPerPlate AS FLOAT))

							--while begin
							WHILE(@PlatesCreated < @PlatesRequired) BEGIN
								INSERT INTO Plate (PlateName,TestID)
								VALUES(@CropCode +'_' + @FileTitle + '_000_' +RIGHT('000'+CAST(@PlatesCreated +1 AS NVARCHAR),2) ,@TestID);
								SELECT @LastPlateID = @@IDENTITY;
								
								INSERT INTO Well(PlateID,Position,WellTypeID)
								SELECT @LastPlateID,W.Position,@AssignedWellTypeID FROM Well W
								JOIN Plate P ON p.PlateID = W.PlateID
								WHERE P.PlateID = @PlateID;

								SET @PlatesCreated = @PlatesCreated + 1;
							END
							--while end

							--insert already existing material to temp material table
							INSERT INTO @TVP_Material(MaterialID)
							SELECT MaterialID
							FROM 
							(
								SELECT MaterialID
								,Position,Position2,Position1,PlateID
								FROM 
								(
									SELECT DISTINCT Position, MaterialID,W.PlateID,
									CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1, -- this is column number
									CAST(ASCII(LEFT(Position,1)) -65 AS INT) as Position2 -- this is row number
									FROM Well W
									JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
									JOIN Plate P ON P.PlateID = W.PlateID
									WHERE P.TestID = @TestID 
					
								) T 
							) T1 ORDER BY PlateID, Position2, Position1	

							--Insert new material into temp material table
							MERGE @TVP_Material T
							USING
							(
								SELECT MaterialID FROM Material M 
								JOIN @TempRow T1 ON T1.MaterialKey = M.MaterialKey
							) S ON S.MaterialID = T.MaterialID
							WHEN NOT MATCHED THEN
							INSERT(materialID)
							VALUES(S.MaterialID);

							--insert well into temp well table
							INSERT INTO @TVP_Well(MaterialID)
							SELECT T.WellID
							FROM 
							(
								SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
								,LEFT(Position,1) as Position2
								FROM Well W
								JOIN Plate P ON P.PlateID = W.PlateID
								WHERE P.TestID = @TestID
							) T
							ORDER BY PlateID,Position2,Position1

							
							SELECT @TotalMaterial = COUNT(RowNR) FROM @TVP_Material

							--get this temptable to merge into table testmaterialdeterminationwell
							INSERT INTO @TVP_MaterialWithWell(MaterialID,WellID)
							SELECT M.MaterialID, W.MaterialID FROM @TVP_Material M
							JOIN @TVP_Well W ON W.RowNr = M.RowNr


							MERGE TestMaterialDeterminationWell T
							USING @TVP_MaterialWithWell S
							ON T.WellID = S.WellID
							WHEN NOT MATCHED THEN 
							INSERT (MaterialID,WellID)
							VALUES (S.MaterialID,S.WellID);

							UPDATE W
							SET W.WellTypeID = @AssignedWellTypeID
							FROM Well W 
							JOIN @TVP_MaterialWithWell MW ON MW.WellID = W.WellID
							WHERE W.WellTypeID != @AssignedWellTypeID;
							

							UPDATE W
							SET W.WellTypeID = @EmptyWellTypeID
							FROM Well W 
							JOIN @TVP_Well TW ON TW.MaterialID = W.WellID
							WHERE TW.RowNr >@TotalMaterial AND W.WellTypeID != @EmptyWellTypeID;

							

						END
					END
				END

		END
			
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
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
				INSERT(MaterialType, MaterialKey, [Source], CropCode,[RefExternal])
				VALUES ('PLT', S.MaterialKey, @Source, @CropCode,@ObjectID);
			
		END
		ELSE BEGIN
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);

			SELECT 
				@CropCode = F.CropCode,
				@BrStationCode=T.BreedingStationCode,
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

			INSERT INTO @TempTVP_Cell(RowNr,ColumnNr,[Value])
			SELECT RowNr,ColumnNr,[Value] FROM @TVPCell


			INSERT INTO @TempTVP_Column(ColumnNr,ColumLabel,DataType,TraitID)
			SELECT ColumnNr,ColumLabel,DataType,TraitID FROM @TVPColumns;
			
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
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr] - @LastRowNr INTO @RowData
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


				UPDATE T1 SET 
					 T1.ColumnNr = T2.NewColNr
				FROM @TempTVP_Cell T1
				JOIN @BridgeColumnTable T2 ON T1.ColumnNr = T2.OldColNr;

				INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
				SELECT [RowID], [ColumnID], [Value] 
				FROM @TempTVP_Cell T1
				JOIN @RowData T2 ON T2.RowNr - 1 = T1.RowNr
				JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;
					
				MERGE INTO Material T 
				USING
				(
					SELECT R.MaterialKey
					FROM [Row] R
					WHERE FileID = @FileID		
				) S	ON S.MaterialKey = T.MaterialKey
				WHEN NOT MATCHED THEN 
					INSERT(MaterialType, MaterialKey, [Source], CropCode,[RefExternal])
					VALUES ('PLT', S.MaterialKey, @Source, @CropCode,@ObjectID);
		END

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END



GO




--EXEC PR_UpdateAndVerifyTraitDeterminationResult 'Phenome',0
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL,
	@SendResult BIT =0
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @tbl1 AS TABLE 
	(
		DeterminationID INT
		
	);

	DECLARE @tbl2 AS TABLE
	(
		TestID INT,
		TestName NVARCHAR(MAX),
		Obsvaluechar NVARCHAR(MAX),
		croptraitid INT,
		traitname NVARCHAR(MAX),
		TraitValue NVARCHAR(MAX),
		determinationid INT,
		DeterminationName NVARCHAR(MAX),
		OriginRowID NVARCHAR(MAX),
		MaterialKey NVARCHAR(MAX),
		CropCode NVARCHAR(MAX),
		Cummulate BIT,
		InvalidPer DECIMAL(5,2),
		FieldID NVARCHAR(MAX),
		RequestingUser NVARCHAR(MAX),
		StatusCode INT,
		isvalid BIT
	)

	INSERT INTO @tbl1
	(
		DeterminationID
	)
	SELECT TR.DeterminationID
	FROM dbo.TestResult TR 
	JOIN Well W ON W.WellID = TR.WellID
	
	JOIN Plate P ON P.PlateID = W.PlateID
	JOIN Test T ON T.TestID = P.TestID
	JOIN dbo.[File] F ON F.FileID = T.FileID
	
	JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode AND D.TestTypeID = T.TestTypeID
	JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
	JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = F.CropCode
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
	GROUP BY TR.DeterminationID
	HAVING COUNT(RTD.CropTraitID) > 1

	INSERT INTO @tbl2
	(
		TestID, TestName, Obsvaluechar,	croptraitid, traitname, TraitValue, determinationid, DeterminationName, OriginRowID, MaterialKey,	CropCode, Cummulate, InvalidPer, FieldID, RequestingUser, StatusCode, isvalid 
	)
	SELECT 
		T.TestID,
		T.TestName,
		TR.ObsValueChar,
		RTD.CropTraitID,
		T1.ColumnLabel,
		TDR.TraitResChar,
		T2.DeterminationID,
		D.DeterminationName,
		M.Originrowid,
		M.MaterialKey,
		F.CropCode,
		T.Cumulate,
		CRD.InvalidPer,
		M.RefExternal,
		T.RequestingUser,
		T.StatusCode,
		CASE 
			WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
			WHEN ISNULL(T2.DeterminationID,0) = 0 THEN 1 
			ELSE 0 END
	FROM TestResult TR
	JOIN Well W ON W.WellID = TR.WellID
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
	JOIN Plate P ON P.PlateID = W.PlateID
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN CropRD CRD ON CRD.CropCode = F.CropCode
	JOIN dbo.Material M ON m.MaterialID = TMDW.MaterialID
	JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode AND D.TestTypeID = T.TestTypeID
	LEFT JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
	LEFT JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	LEFT JOIN dbo.Trait T1 ON T1.TraitID = CT.TraitID
	LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
	LEFT JOIN @tbl1 T2 ON T2.DeterminationID = TR.DeterminationID
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
	

	;
	WITH CTE AS
	(
	SELECT T1.determinationid FROM 
	(
		SELECT determinationid,croptraitid, MIN(ISNULL(TraitValue,'')) AS Valid
		 FROM @tbl2
		WHERE isvalid = 0 
		GROUP BY determinationid,croptraitid
	) T1
	WHERE ISNULL(Valid,'') <> '' 
	GROUP BY determinationid 
	)
	UPDATE T1 SET T1.isvalid = 1
	FROM @tbl2 T1
	JOIN CTE T2 ON T1.determinationid = T2.determinationid

	--this select statement is done earlier because we are sending email based on status of test. Email should to be sent only once.
	if(ISNULL(@SendResult,0)= 0) BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid FROM @tbl2 WHERE isvalid = 0
	END
	ELSE BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid FROM @tbl2;
	END
	

	--update to status 625 if mapping of determinations and traits for test not present.
	UPDATE T1 SET T1.StatusCode = 625
	FROM Test T1
	WHERE EXISTS
	(
		SELECT TestID 
		FROM @tbl2 T2 
		WHERE T1.TestID = T2.TestID AND T2.isvalid = 0
		GROUP BY T2.TestID
	)

END

GO


DROP PROCEDURE IF EXISTS [dbo].[PR_UpdateAndVerifyTraitDeterminationResult1]
GO

