/*
Authror					Date				Description 
KRISHNA GAUTAM			2019-Mar-28			Updated previous method to restrict user from changing testtypeid if plate is already created.
=================Example===============
EXEC PR_Update_Test 76,'KATHMANDU\psindurakar',2,0,2,2,'2018-04-27',1
*/

ALTER PROCEDURE [dbo].[PR_Update_Test]
(
	@TestID INT,
	--@UserID NVARCHAR(200),
	@ContainerTypeID INT,
	@Isolated BIT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@PlannedDate DateTime,
	@TestTypeID INT,
	@ExpectedDate DATETIME,
	@SlotID INT = NULL, --This value is not required for now 
	@Cumulate BIT
)
AS
BEGIN
	DECLARE @ReturnValue INT;
	DECLARE @TestTypeID_Prev INT;
	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	----check valid test.
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END
	--check status for validation of changed column
	IF EXISTS(SELECT StatusCode FROM Test WHERE StatusCode >= 400 AND TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Cannot change for this test.';
		RETURN;
	END

	--check if slot is assigned or not
	IF EXISTS(SELECT SlotID FROM Test T JOIN SlotTest ST ON ST.TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Cannot change test properties after assigning slot.';
		RETURN;
	END

	--Check if plate is created or not
	SELECT @TestTypeID_Prev = TestTypeID FROM Test WHERE TestID = @TestID;

	IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestTypeID_Prev,0))
	BEGIN
		EXEC PR_ThrowError 'Cannot change ''Test Type''.';
		RETURN;
	END

	--SELECT @AssignedDetermination = COUNT(TestMaterialDeterminationID) FROM TestMaterialDetermination WHERE TestID = @TestID;
	--SELECT @MarkerNeeded = DeterminationRequired FROM TestType WHERE TestTypeID = @TestTypeID
	--IF(@MarkerNeeded = 0 AND @AssignedDetermination > 0) BEGIN
	--	EXEC PR_ThrowError 'Cannot change ''Test Type''. Marker already assigned for this Test.';
	--	RETURN;
	--END

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
			UPDATE Test 
			SET 
			ContainerTypeID = @ContainerTypeID,
			Isolated = @Isolated,
			TestTypeID = @TestTypeID,
			PlannedDate = @PlannedDate,
			MaterialTypeID = @MaterialTypeID,
			MaterialStateID = @MaterialStateID,
			ExpectedDate = @ExpectedDate,
			Cumulate = @Cumulate
			WHERE TestID = @TestID;			
		COMMIT TRAN;
		END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH

END
GO


ALTER PROCEDURE [dbo].[PR_Insert_ExcelData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(10),
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
		IF(ISNULL(@FileID,0) = 0) 
		BEGIN
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
		ELSE 
			BEGIN
			--SELECT * FROM Test
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TempTVP_Row TVP_Row, @TVP_Material TVP_Material, @TVP_Well TVP_Material,@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,@PlateID INT,@TotalRows INT,@TotalMaterial INT;
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100),[DataType] VARCHAR(15),[NewColumnNr] INT);
			DECLARE @TempRow TABLE (RowNr INT IDENTITY(1,1),MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeColumnTable AS TABLE(OldColNr INT, NewColNr INT);
			DECLARE @RowData1 TABLE(RowNr INT,RowID INT,MaterialKey NVARCHAR(MAX));
			DECLARE @BridgeRowTable AS TABLE(OldRowNr INT, NewRowNr INT);
			DECLARE @StatusCode INT;

			DECLARE @CropCode1 NVARCHAR(10),@BreedingStationCode1 NVARCHAR(10),@SyncCode1 NVARCHAR(2), @CountryCode1 NVARCHAR(10);

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
				@TestID = T.TestID
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
				EXEC PR_ThrowError 'Cannot import material with different sync code to this test.';
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
				)
				ORDER BY T1.RowNr;

				--now insert into row table if material is not availale 
				INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID,RowNr,MaterialKey)
				SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
				ORDER BY T.RowNr;

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
	@SyncCode				NVARCHAR(10),
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

		IF(ISNULL(@FileID,0)=0) 
		BEGIN
			
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
		ELSE 
		BEGIN
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
				SELECT T1.MaterialKey FROM @TVPRow T1
				WHERE NOT EXISTS
				(
					SELECT R1.MaterialKey FROM [Row] R1 
					JOIN @TVPRow R2 ON R2.MaterialKey = R1.MaterialKey
					WHERE R1.FileID = @FileID AND T1.MaterialKey = R1.MaterialKey
				)
				ORDER BY T1.RowNr;

				--now insert into row table if material is not availale 
				INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID,RowNr,MaterialKey)
				SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
				ORDER BY T.RowNr;

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
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			SP Created to Import material for S2S process.

========Example=============

*/

ALTER PROCEDURE [dbo].[PR_Import_s2s_Material]
(
	@CropCode						NVARCHAR(10),
	@BreedingStationCode			NVARCHAR(10),
	@SyncCode						NVARCHAR(10),
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
			SELECT T.RowNr,T.MaterialKey,@FileID, 1 FROM @TVPRow T
			ORDER BY T.RowNr;

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

			MERGE INTO S2SDonorInfo T
			USING @RowData S
			ON S.RowID = T.RowID
			WHEN NOT MATCHED THEN
			INSERT (RowID)
			VALUES (S.RowID);

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
			--IF(ISNULL(@BreedingStationCode1,'')<> ISNULL(@BreedingStationCode,'')) BEGIN
			--	EXEC PR_ThrowError 'Cannot import material with different breeding station to this test.';
			--	RETURN;
			--END
			--IF(ISNULL(@SyncCode1,'')<> ISNULL(@SyncCode,'')) BEGIN
			--	EXEC PR_ThrowError 'Cannot import material with different sync code code to this test.';
			--	RETURN;
			--END
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
				)
				ORDER BY T1.RowNr;

				--now insert into row table if material is not availale 
				INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID], NrOfSamples)
				OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID,RowNr,MaterialKey)
				SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
				ORDER BY T.RowNr;

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
					
				MERGE INTO S2SDonorInfo T
				USING @RowData1 S
				ON S.RowID = T.RowID
				WHEN NOT MATCHED THEN
				INSERT (RowID)
				VALUES (S.RowID);			

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
		INSERT (CapacitySlotID,CapacitySlotName,MaxPlants,CordysStatus,DH0Location,AvailPlants)
		VALUES(S.CapacitySlotID,S.CapacitySlotName,S.MaxPlants,S.CordysStatus,S.DH0Location,S.AvailPlants)
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

-- =============================================
-- Author:		Binod Gurung
-- Create date: 2018/01/17
-- Description:	Pull Test Information
-- =============================================
/*
EXEC PR_GetTestInfoForLIMS 2,'KATHMANDU\PBantwa',40
EXEC PR_GetTestInfoForLIMS 90,'KATHMANDU\psindurakar',40
*/
ALTER PROCEDURE [dbo].[PR_GetTestInfoForLIMS]
(
	@TestID INT,
	--@UserID NVARCHAR(100),
	@MaxPlates INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SynCode CHAR(2), @CropCode CHAR(2), @TotalTests INT, @Isolated BIT, @ReturnValue INT, @RemarkRequired BIT, @DeterminationRequired INT,@DeadWellType INT,@TotalPlates INT;

	--Validate Test for corresponding user
	--EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	--IF(@ReturnValue <> 1) BEGIN
	--	RETURN;
	--END

	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate WHERE TestID = @TestID;

	IF(@TotalPlates > @MaxPlates) BEGIN
		DECLARE @Error NVARCHAR(MAX) = 'Reservation of Plate failed. Maximum of '+ CAST(@MaxPlates AS NVARCHAR(10)) + ' plates can be reserved for test. ';
		EXEC PR_ThrowError @Error;
		RETURN;			
	END

	--check if total tests and plates falls within range of total marker and palates for this test
	SET @ReturnValue = dbo.Validate_Capacity(@TestID);
	IF(@ReturnValue = 0) BEGIN
		EXEC PR_ThrowError N'Reservation Qouta exceed for tests or plates. Unassign some markers or change slot for this test.';
		RETURN 0;
	END


	SELECT TOP 1 @SynCode =  T.SyncCode,  
				 @CropCode = F.CropCode
	FROM Test T 
	JOIN [File] F ON F.FileID = T.FileID
	WHERE T.TestID = @TestID
	  --AND T.RequestingUser = @UserID;

	SELECT @DeadWellType = WellTypeID 
	FROM WEllType WHERE WellTypeName = 'D'
	
	--Amount of tests per plate CUMULATED for ALL plates together
	SELECT @TotalTests = COUNT(V2.DeterminationID)
	FROM
	(
		SELECT V.DeterminationID, V.PlateID
		FROM
		(
			SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID FROM TestMaterialDetermination TMD 
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
			WHERE TMD.TestID = @TestID AND W.WellTypeID <> @DeadWellType
		
		) V
		GROUP BY V.DeterminationID, V.PlateID
	) V2 ;	
	
	SELECT  @RemarkRequired = TT.RemarkRequired, 
			@DeterminationRequired = TT.DeterminationRequired 
	FROM TestType TT
	JOIN Test T ON T.TestTypeID = TT.TestTypeID
	WHERE T.TestID = @TestID
	  --AND T.RequestingUser = @UserID;

	--For Test type with Remarkrequired true is DNA Isolation type. For DNA Isolation type, Isolated value is true
	IF(@RemarkRequired = 1)
		SET @Isolated = 1

	--Determination should be used for Test type with DeterminatonRequired true
	IF(@TotalTests = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one Marker/Determination.';
		RETURN 0;
	END

	--For DNA Isolation type Markers are not used. Dummy value -1 is sent for now. Should be changed later
	IF(@Isolated = 1)
		SET @TotalTests = -1;

	SELECT	YEAR(T.PlannedDate)				AS PlannedYear, 
			COUNT(P.PlateID)				AS TotalPlates, 
			@TotalTests						AS TotalTests, 
			@SynCode						AS SynCode, 
			T.Remark						AS Remark, 
			--@Isolated						AS Isolated, 
			IsIsolated = CASE WHEN T.Isolated = 1 THEN 'T' ELSE 'F' END,
			@CropCode						AS CropCode, 
			DATEPART(WEEK, T.PlannedDate)	AS PlannedWeek,
			MS.MaterialStateCode,
			MT.MaterialTypeCode,
			CT.ContainerTypeCode,
			ExpecdedYear = YEAR(T.ExpectedDate),
			ExpectedWeek = DATEPART(WEEK, T.ExpectedDate)
	FROM Test T
	JOIN Plate P ON P.TestID = T.TestID
	LEFT JOIN MaterialState MS ON MS.MaterialStateID = T.MaterialStateID
	LEFT JOIN MaterialType MT ON MT.MaterialTypeID = T.MaterialTypeID
	LEFT JOIN ContainerType CT ON CT.ContainerTypeID = T.ContainerTypeID	
	WHERE T.TestID = @TestID
	 --AND  T.RequestingUser = @UserID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END
GO


DROP PROCEDURE IF EXISTS PR_S2S_GetMarkerTestData
GO

--EXEC PR_S2S_GetMarkerTestData 4378, 34277;
CREATE PROCEDURE PR_S2S_GetMarkerTestData
(
	@TestID				INT,
	@MaterialID			INT
) AS BEGIN
	SET NOCOUNT ON;

	SELECT
		DI.DonorNumber,
		MarkerNumber = DMS.DeterminationID,
		MarkerName = D.DeterminationName,
		DonorMarkerUse = 'Sel',
		HaploidMarkerUse = 'Sel',
		AutoSelectScore = DMS.Score
	FROM S2SCapacitySlot CS
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	JOIN S2SDonorMarkerScore DMS ON DMS.TestID = T.TestID AND DMS.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = DMS.DeterminationID
	WHERE T.TestID = @TestID
	AND M.MaterialID = @MaterialID;
END
GO