DROP INDEX IF EXISTS [IX_Period_Test] ON [dbo].[AvailCapacity]
GO

CREATE NONCLUSTERED INDEX [IX_Period_Test] ON [dbo].[AvailCapacity]
(
	[PeriodID] DESC,
	[TestProtocolID] ASC
)
GO



DROP INDEX IF EXISTS [IX_Row_Column] ON [dbo].[Cell]
GO

CREATE NONCLUSTERED INDEX [IX_Row_Column] ON [dbo].[Cell]
(
	[RowID] ASC,
	[ColumnID] ASC
)
GO


DROP INDEX IF EXISTS [IX_Cell_WIth_value] ON [dbo].[Cell]
GO

CREATE NONCLUSTERED INDEX [IX_Cell_WIth_value] ON [dbo].[Cell]
(
	[RowID] DESC,
	[ColumnID] DESC
)
INCLUDE ( 	[Value]) 
GO



DROP INDEX IF EXISTS [IX_FileCol] ON [dbo].[Column]
GO

CREATE NONCLUSTERED INDEX [IX_FileCol] ON [dbo].[Column]
(
	[FileID] ASC,
	[ColumnNr] ASC
)
GO



DROP INDEX IF EXISTS [IX_File_Crop] ON [dbo].[File]
GO

CREATE NONCLUSTERED INDEX [IX_File_Crop] ON [dbo].[File]
(
	[CropCode] ASC
)
GO



DROP INDEX IF EXISTS [IX_Material] ON [dbo].[Material]
GO

CREATE NONCLUSTERED INDEX [IX_Material] ON [dbo].[Material]
(
	[MaterialKey] DESC
)
GO



DROP INDEX IF EXISTS [IX_Test]  ON [dbo].[Plate]
GO

CREATE NONCLUSTERED INDEX [IX_Test] ON [dbo].[Plate]
(
	[TestID] DESC
)
GO


DROP INDEX IF EXISTS [IX_TraitDeter] ON [dbo].[RelationTraitDetermination]
GO

CREATE NONCLUSTERED INDEX [IX_TraitDeter] ON [dbo].[RelationTraitDetermination]
(
	[CropTraitID] ASC,
	[DeterminationID] ASC
)
GO

DROP INDEX IF EXISTS [IX_SlotProtocol] ON [dbo].[ReservedCapacity]
GO

CREATE NONCLUSTERED INDEX [IX_SlotProtocol] ON [dbo].[ReservedCapacity]
(
	[SlotID] ASC,
	[TestProtocolID] ASC
)
GO



DROP INDEX IF EXISTS [IX_File] ON [dbo].[Row]
GO

CREATE NONCLUSTERED INDEX [IX_File] ON [dbo].[Row]
(
	[FileID] DESC
)
GO



DROP INDEX IF EXISTS [IX_Row_FileID_RowID_MaterialKey] ON [dbo].[Row]
GO

CREATE NONCLUSTERED INDEX [IX_Row_FileID_RowID_MaterialKey] ON [dbo].[Row]
(
	[FileID] ASC
)
INCLUDE ( 	[RowID],
	[MaterialKey]) 
GO



DROP INDEX IF EXISTS [IX_Slot] ON [dbo].[Slot]
GO
CREATE NONCLUSTERED INDEX [IX_Slot] ON [dbo].[Slot]
(
	[CropCode] DESC,
	[PeriodID] DESC,
	[MaterialTypeID] ASC,
	[BreedingStationCode] ASC,
	[Isolated] ASC,
	[StatusCode] ASC
)
GO



DROP INDEX IF EXISTS [IX_FileSync] ON [dbo].[Test]
GO

CREATE NONCLUSTERED INDEX [IX_FileSync] ON [dbo].[Test]
(
	[FileID] DESC,
	[BreedingStationCode] ASC,
	[StatusCode] ASC
)
GO



DROP INDEX IF EXISTS [IX_Status] ON [dbo].[Test]
GO
CREATE NONCLUSTERED INDEX [IX_Status] ON [dbo].[Test]
(
	[StatusCode] ASC
)
GO



DROP INDEX IF EXISTS [IX_Test] ON [dbo].[TestMaterialDetermination]
GO

CREATE NONCLUSTERED INDEX [IX_Test] ON [dbo].[TestMaterialDetermination]
(
	[TestID] DESC,
	[MaterialID] ASC,
	[DeterminationID] ASC
)
GO



DROP INDEX IF EXISTS [IX_TMDW] ON [dbo].[TestMaterialDeterminationWell]
GO

CREATE NONCLUSTERED INDEX [IX_TMDW] ON [dbo].[TestMaterialDeterminationWell]
(
	[WellID] ASC
)
GO



DROP INDEX IF EXISTS [IX_Well] ON [dbo].[TestMaterialDeterminationWell]
GO

CREATE NONCLUSTERED INDEX [IX_Well] ON [dbo].[TestMaterialDeterminationWell]
(
	[WellID] DESC
)
GO



DROP INDEX IF EXISTS [IX_Well] ON [dbo].[TestResult]
GO

CREATE NONCLUSTERED INDEX [IX_Well] ON [dbo].[TestResult]
(
	[WellID] DESC,
	[DeterminationID] ASC,
	[ObsValueChar] ASC
)
GO



DROP INDEX IF EXISTS [IX_ColLabel] ON [dbo].[Trait]
GO

CREATE NONCLUSTERED INDEX [IX_ColLabel] ON [dbo].[Trait]
(
	[ColumnLabel] ASC
)
GO



DROP INDEX IF EXISTS [IX_RelationDeter] ON [dbo].[TraitDeterminationResult]
GO
CREATE NONCLUSTERED INDEX [IX_RelationDeter] ON [dbo].[TraitDeterminationResult]
(
	[RelationID] ASC,
	[DetResChar] ASC
)
GO


DROP INDEX IF EXISTS [IX_TraitValue] ON [dbo].[TraitValue]
GO
CREATE NONCLUSTERED INDEX [IX_TraitValue] ON [dbo].[TraitValue]
(
	[TraitID] ASC,
	[TraitValueCode] ASC
)
GO




DROP INDEX IF EXISTS [IX_Well] ON [dbo].[Well]
GO
CREATE NONCLUSTERED INDEX [IX_Well] ON [dbo].[Well]
(
	[PlateID] ASC
)
GO



DROP INDEX IF EXISTS [IX_well_Plate] ON [dbo].[Well]
GO

CREATE NONCLUSTERED INDEX [IX_well_Plate] ON [dbo].[Well]
(
	[PlateID] ASC
)
INCLUDE ( 	[WellID],
	[WellTypeID],
	[Position])
GO



DROP VIEW IF EXISTS [dbo].[VW_IX_Cell_Material]
GO

CREATE VIEW [dbo].[VW_IX_Cell_Material]
AS
	SELECT 
		R.FileID, 
		R.[RowID],
		R.MaterialKey,
		R.NrOfSamples,
		R.RowNr,
		C.ColumnID,
		C1.[Value] 
	FROM [dbo].[Row] R
	JOIN [Column] C ON C.FileID = R.FileID
	JOIN [Cell] C1 ON C1.RowID = R.RowID AND C1.ColumnID = C.ColumnID

GO

DROP VIEW IF EXISTS [dbo].[VW_IX_Cell]
GO


CREATE VIEW [dbo].[VW_IX_Cell]
AS
	SELECT 
		R.FileID, 
		R.[RowID],
		C.ColumnID,
		C1.[Value] 
	FROM [dbo].[Row] R
	JOIN [Column] C ON C.FileID = R.FileID
	JOIN [Cell] C1 ON C1.RowID = R.RowID AND C1.ColumnID = C.ColumnID  
GO



DROP VIEW IF EXISTS [dbo].[VW_IX_TMDW_Mat_Well]
GO


CREATE VIEW [dbo].[VW_IX_TMDW_Mat_Well]
AS

SELECT
				M.MaterialID, 
				M.MaterialKey,
				P.PlateID, 
				P.PlateName AS Plate, 
				W.WellID,
				W.Position AS Well,
				W.WellTypeID,
				P.TestID
				
			FROM Plate P
			JOIN Well W ON W.PlateID = P.PlateID
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
			JOIN Material M ON M.MaterialID = TMDW.MaterialID
GO




DROP PROCEDURE IF EXISTS [dbo].[PR_Insert_ExcelData]
GO



CREATE PROCEDURE [dbo].[PR_Insert_ExcelData]
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
		COMMIT;

	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END

GO



/*
	EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
	EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
	EXEC [PR_GetDataWithMarkers] 1030, 1, 200, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	--@User			NVARCHAR(100),
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT--, @SameTestCount INT =1;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15),MateriallblColumn BIT);
	DECLARE @PlateAndWellAssigned BIT = 0; --here we have to check whether well and plate is assigned previously or not.. for now we set it to false 
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = ''; -- ,@SameTestCount NVARCHAR(5);
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
	--EXEC PR_CreatePlateAndWell @TestID,@User
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
				--JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
				WHERE T1.TestID = @TestID
				--AND T4.FileID = @FileID			
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
	--ORDER BY ColumnNr;
	
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
				AND Value <> ''''
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

	--EXEC sp_executesql @SQL , N'@FileID INT, @User NVARCHAR(100), @Offset INT, @PageSize INT, @TestID INT', @FileID, @User, @Offset, @PageSize, @TestID;
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

