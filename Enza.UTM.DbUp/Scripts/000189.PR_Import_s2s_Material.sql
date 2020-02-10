DROP PROCEDURE IF EXISTS [dbo].[PR_Import_s2s_Material]
GO

DROP TYPE IF EXISTS [dbo].[TVPCapacityS2s]
GO

CREATE TYPE [dbo].[TVPCapacityS2s] AS TABLE(
	[CapacitySlotID] [int] NULL,
	[MaxPlants] [int] NULL,
	[CordysStatus] [nvarchar](max) NULL,
	[DH0Location] [nvarchar](max) NULL,
	[AvailPlants] [int] NULL
)
GO



/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-APR-25			SP Created to Import material for S2S process.

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

		SELECT @CapacitySlotID = CapacitySlotID FROM @TVPCapacityS2s;

		IF(ISNULL(@CapacitySlotID,0)=0) BEGIN
			EXEC PR_ThrowError 'Invalid Capacity Slot';
			RETURN;
		END

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
							FROM @RowData1


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


