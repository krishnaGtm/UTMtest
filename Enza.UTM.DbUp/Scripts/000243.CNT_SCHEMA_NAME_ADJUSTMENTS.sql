DROP PROCEDURE IF EXISTS PR_Import_CNTMaterials
GO

DROP PROCEDURE IF EXISTS PR_CNT_ImportMaterials
GO

CREATE PROCEDURE [dbo].[PR_CNT_ImportMaterials]
(
	@TestID				  INT OUTPUT,
	@CropCode				  NVARCHAR(10),
	@BrStationCode			  NVARCHAR(10),
	@SyncCode				  NVARCHAR(10),
	@CountryCode			  NVARCHAR(10),
	@UserID				  NVARCHAR(100),
	@TestName				  NVARCHAR(200),
	@Source				  NVARCHAR(50),
	@ObjectID				  NVARCHAR(100),
	@ImportLevel			  NVARCHAR(20),
	@TVPColumns TVP_Column	  READONLY,
	@TVPRow TVP_Row		  READONLY,
	@TVPCell TVP_Cell		  READONLY,	
	@TVPList TVP_List		  READONLY
)
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @FileID INT, @TestTypeID INT;
    
    SELECT 
	   @FileID = FileID,
	   @TestTypeID = TestTypeID
    FROM Test WHERE TestID = @TestID;

    BEGIN TRY
	   BEGIN TRANSACTION;

	   --import data as new test/file
	   IF(ISNULL(@FileID, 0) = 0) 
	   BEGIN
		  IF(ISNULL(@TestTypeID, 0) = 0) BEGIN
			 EXEC PR_ThrowError 'Invalid test type ID.';
		  END

		  DECLARE @RowData TABLE([RowID] int, [RowNr] int);
		  DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);

		  INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
		  VALUES(@CropCode, @TestName, @UserID, GETUTCDATE());
		  --Get Last inserted fileid
		  SELECT @FileID = SCOPE_IDENTITY();

		  INSERT INTO [Row] ([RowNr], [MaterialKey], [FileID], NrOfSamples)
		  OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		  SELECT T.RowNr,T.MaterialKey,@FileID, 1 
		  FROM @TVPRow T
		  ORDER BY T.RowNr;

		  INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		  OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		  SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] 
		  FROM @TVPColumns T
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
		  INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[BreedingStationCode],
		  [SyncCode], [ImportLevel], CountryCode)
		  VALUES(@TestTypeID, @FileID, @Source, @UserID, @TestName, GETUTCDATE(), 100, @BrStationCode, @SyncCode, @ImportLevel, @CountryCode);
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
				    VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID,@BrStationCode)
			 WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
				    UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID ,BreedingStationCode = @BrStationCode;
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
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TempTVP_Row TVP_Row, @TVP_Material TVP_Material, @TVP_Well TVP_Material,
			@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,
			@PlateID INT,@TotalRows INT,@AssignedWellTypeID INT, @EmptyWellTypeID INT,@TotalMaterial INT;
			
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100), [DataType] VARCHAR(15),[NewColumnNr] INT);
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
				@TestName = T.TestName,
				@Source = T.RequestingSystem,
				@TestID = T.TestID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID

			SELECT @StatusCode = Statuscode FROM Test WHERE TestID = @TestID;
			IF(@StatusCode >= 200) BEGIN
				EXEC PR_ThrowError 'Cannot import material to this test after plate is requested on LIMS.';
				RETURN;
			END
	
			IF(ISNULL(@CropCode1,'') <> ISNULL(@CropCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different crop  to this test.';
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
			 OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID, RowNr, MaterialKey)
			 SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
			 ORDER BY T.RowNr;

			 --now insert new columns if available which are not already available on table
			 INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
			 SELECT T1.[NewColumnNr], T.[TraitID], T1.[ColumLabel], @FileID, T1.[DataType] 
			 FROM @NewColumns T1
			 LEFT JOIN 
			 (
				    SELECT CT.TraitID,T.TraitName, T.ColumnLabel
				    FROM Trait T 
				    JOIN CropTrait CT ON CT.TraitID = T.TraitID
				    WHERE CT.CropCode = @CropCode AND T.Property = 0
			 )
			 T ON T.ColumnLabel = T1.ColumLabel;

			 INSERT INTO @BridgeColumnTable(OldColNr,NewColNr)
			 SELECT T.ColumnNr,C.ColumnNr FROM 
			 [Column] C
			 JOIN @TempTVP_Column T ON T.ColumLabel = C.ColumLabel
			 WHERE C.FileID = @FileID;

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
			 JOIN @TVPRow T2 ON T1.MaterialKey = T2.MaterialKey;

			 UPDATE T1 SET
				    T1.RowNr = T2.NewRowNr
			 FROM @TempTVP_Cell T1
			 JOIN @BridgeRowTable T2 ON T1.RowNr = T2.OldRowNr;

			 INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
			 SELECT T2.[RowID], T3.[ColumnID], T1.[Value] 
			 FROM @TempTVP_Cell T1
			 JOIN @RowData1 T2 ON T2.RowNr = T1.RowNr
			 JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
			 WHERE ISNULL(T1.[Value], '') <> '';

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
				    VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID, @BrStationCode)
				WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
				    UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID, BreedingStationCode= @BrStationCode;
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
	   IF @@TRANCOUNT > 0 
		ROLLBACK;
	   THROW;
	END CATCH
END
GO





DROP PROCEDURE IF EXISTS [dbo].[PR_SaveCnTTypes]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveCnTStartMaterials]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveCnTProcess]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_SaveCnTLABLocations]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCnTTypes]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCnTStartMaterials]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCntProcesses]
GO
DROP PROCEDURE IF EXISTS [dbo].[PR_GetCnTLABLocations]
GO


CREATE PROCEDURE [dbo].[PR_CNT_GetLABLocations]
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        L.LabLocationID,
        L.LabLocationName,
	   S.StatusName,
	   Active = CAST(CASE WHEN L.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTLABLocation L
    JOIN [Status] S ON S.StatusCode = L.StatusCode AND S.StatusTable = 'CnTLABLocation'
    ORDER BY L.LabLocationName;
END
GO

CREATE PROCEDURE [dbo].[PR_CNT_GetProcesses]
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        P.ProcessID,
        P.ProcessName,
	   S.StatusName,
	   Active = CAST(CASE WHEN P.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTProcess P
    JOIN [Status] S ON S.StatusCode = P.StatusCode AND S.StatusTable = 'CnTProcess'
    ORDER BY P.ProcessName;
END
GO

CREATE PROCEDURE [dbo].[PR_CNT_GetStartMaterials]
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        SM.StartMaterialID,
        SM.StartMaterialName,
	   S.StatusName,
	   Active = CAST(CASE WHEN SM.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTStartMaterial SM
    JOIN [Status] S ON S.StatusCode = SM.StatusCode AND S.StatusTable = 'CnTStartMaterial'
    ORDER BY SM.StartMaterialName;
END
GO

CREATE PROCEDURE [dbo].[PR_CNT_GetTypes]
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        T.TypeID,
        T.TypeName,
	   S.StatusName,
	   Active = CAST(CASE WHEN T.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTType T
    JOIN [Status] S ON S.StatusCode = T.StatusCode AND S.StatusTable = 'CnTType'
    ORDER BY T.TypeName;
END
GO

/*
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":null,"LabLocationName":"NL","Active":true,"Action":"I"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":5,"LabLocationName":"NL","Active":true,"Action":"U"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":5,"LabLocationName":"NL","Active":true,"Action":"D"}]';
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":null,"LabLocationName":"NL","Active":true,"Action":"I"}]';
    EXEC PR_CNT_SaveLABLocations @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_CNT_SaveLABLocations]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @LabLocationNames   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(LabLocationID INT, LabLocationName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(LabLocationID, LabLocationName, Active, [Action])
    SELECT LabLocationID, LabLocationName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   LabLocationID   INT,
	   LabLocationName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTLABLocation(LabLocationName, StatusCode)
	   SELECT 
		  T.LabLocationName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTLABLocation L ON L.LabLocationName = T.LabLocationName
	   WHERE T.[Action] = 'I'
	   AND L.LabLocationName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @LabLocationNames = COALESCE(@LabLocationNames + N',', N'') + S.LabLocationName
	   FROM CnTLABLocation T
	   JOIN @Tbl S ON S.LabLocationName = T.LabLocationName
	   WHERE S.LabLocationID <> T.LabLocationID;

	   IF(ISNULL(@LabLocationNames, '') <> '') BEGIN
		  SET @LabLocationNames = N'Duplicate records found for the following: ' + @LabLocationNames;
		  EXEC PR_ThrowError @LabLocationNames;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.LabLocationName = S.LabLocationName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTLABLocation T
	   JOIN @Tbl S ON S.LabLocationID = T.LabLocationID
	   WHERE S.[Action]  = 'U'

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

/*
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":null,"ProcessName":"Doubled Haploid","Active":true,"Action":"I"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":5,"ProcessName":"Doubled Haploid1","Active":true,"Action":"U"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":5,"ProcessName":"Doubled Haploid1","Active":true,"Action":"D"}]';
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":null,"ProcessName":"Doubled Haploid2","Active":true,"Action":"I"}]';
    EXEC PR_CNT_SaveProcess @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_CNT_SaveProcess]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcessNames   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(ProcessID INT, ProcessName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(ProcessID, ProcessName, Active, [Action])
    SELECT ProcessID, ProcessName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   ProcessID   INT,
	   ProcessName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTProcess(ProcessName, StatusCode)
	   SELECT 
		  T.ProcessName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CntProcess P ON P.ProcessName = T.ProcessName
	   WHERE T.[Action] = 'I'
	   AND P.ProcessName IS NULL;

	   ----New item added but it was already exists but in delete state, make is active
	   --UPDATE T SET 
		  --T.StatusCode = 100
	   --FROM CnTProcess T
	   --JOIN @Tbl S ON S.ProcessName = T.ProcessName
	   --WHERE T.StatusCode = 200 
	   --AND S.Act = 'I';	 
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @ProcessNames = COALESCE(@ProcessNames + N',', N'') + S.ProcessName
	   FROM CnTProcess T
	   JOIN @Tbl S ON S.ProcessName = T.ProcessName
	   WHERE S.ProcessID <> T.ProcessID;

	   IF(ISNULL(@ProcessNames, '') <> '') BEGIN
		  SET @ProcessNames = N'Duplicate records found for the following: ' + @ProcessNames;
		  EXEC PR_ThrowError @ProcessNames;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.ProcessName = S.ProcessName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTProcess T
	   JOIN @Tbl S ON S.ProcessID = T.ProcessID
	   WHERE S.[Action]  = 'U'

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"StartMaterialID":null,"StartMaterialName":"NL","Active":true,"Action":"I"}]';
    EXEC PR_CNT_SaveStartMaterials @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_CNT_SaveStartMaterials]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @StartMaterials   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(StartMaterialID INT, StartMaterialName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(StartMaterialID, StartMaterialName, Active, [Action])
    SELECT StartMaterialID, StartMaterialName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   StartMaterialID   INT,
	   StartMaterialName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTStartMaterial(StartMaterialName, StatusCode)
	   SELECT 
		  T.StartMaterialName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTStartMaterial SM ON SM.StartMaterialName = T.StartMaterialName
	   WHERE T.[Action] = 'I'
	   AND SM.StartMaterialName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @StartMaterials = COALESCE(@StartMaterials + N',', N'') + S.StartMaterialName
	   FROM CnTStartMaterial SM
	   JOIN @Tbl S ON S.StartMaterialName = SM.StartMaterialName
	   WHERE S.StartMaterialID <> SM.StartMaterialID;

	   IF(ISNULL(@StartMaterials, '') <> '') BEGIN
		  SET @StartMaterials = N'Duplicate records found for the following: ' + @StartMaterials;
		  EXEC PR_ThrowError @StartMaterials;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.StartMaterialName = S.StartMaterialName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTStartMaterial T
	   JOIN @Tbl S ON S.StartMaterialID = T.StartMaterialID
	   WHERE S.[Action]  = 'U';

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"TypeID":null,"TypeName":"NL","Active":true,"Action":"I"}]';
    EXEC [PR_CNT_SaveTypes] @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_CNT_SaveTypes]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Types   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(TypeID INT, TypeName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(TypeID, TypeName, Active, [Action])
    SELECT TypeID, TypeName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   TypeID   INT,
	   TypeName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTType(TypeName, StatusCode)
	   SELECT 
		  T.TypeName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTType SM ON SM.TypeName = T.TypeName
	   WHERE T.[Action] = 'I'
	   AND SM.TypeName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @Types = COALESCE(@Types + N',', N'') + S.TypeName
	   FROM CnTType SM
	   JOIN @Tbl S ON S.TypeName = SM.TypeName
	   WHERE S.TypeID <> SM.TypeID;

	   IF(ISNULL(@Types, '') <> '') BEGIN
		  SET @Types = N'Duplicate records found for the following: ' + @Types;
		  EXEC PR_ThrowError @Types;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.TypeName = S.TypeName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTType T
	   JOIN @Tbl S ON S.TypeID = T.TypeID
	   WHERE S.[Action]  = 'U';

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

DROP PROCEDURE IF EXISTS PR_CNT_ImportMaterials
GO

CREATE PROCEDURE [dbo].[PR_CNT_ImportMaterials]
(
	@TestID				  INT OUTPUT,
	@CropCode				  NVARCHAR(10),
	@BrStationCode			  NVARCHAR(10),
	@SyncCode				  NVARCHAR(10),
	@CountryCode			  NVARCHAR(10),
	@UserID				  NVARCHAR(100),
	@TestTypeID			  INT,
	@TestName				  NVARCHAR(200),
	@Source				  NVARCHAR(50),
	@ObjectID				  NVARCHAR(100),
	@ImportLevel			  NVARCHAR(20),
	@TVPColumns TVP_Column	  READONLY,
	@TVPRow TVP_Row		  READONLY,
	@TVPCell TVP_Cell		  READONLY,	
	@TVPList TVP_List		  READONLY
)
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @FileID INT;
    
    SELECT 
	   @FileID = FileID
    FROM Test WHERE TestID = @TestID;

    BEGIN TRY
	   BEGIN TRANSACTION;

	   --import data as new test/file
	   IF(ISNULL(@FileID, 0) = 0) 
	   BEGIN
		  IF(ISNULL(@TestTypeID, 0) = 0) BEGIN
			 EXEC PR_ThrowError 'Invalid test type ID.';
		  END

		  DECLARE @RowData TABLE([RowID] int, [RowNr] int);
		  DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);

		  INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
		  VALUES(@CropCode, @TestName, @UserID, GETUTCDATE());
		  --Get Last inserted fileid
		  SELECT @FileID = SCOPE_IDENTITY();

		  INSERT INTO [Row] ([RowNr], [MaterialKey], [FileID], NrOfSamples)
		  OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		  SELECT T.RowNr,T.MaterialKey,@FileID, 1 
		  FROM @TVPRow T
		  ORDER BY T.RowNr;

		  INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		  OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		  SELECT T.[ColumnNr], T1.[TraitID], T.[ColumLabel], @FileID, T.[DataType] 
		  FROM @TVPColumns T
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
		  INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[BreedingStationCode],
		  [SyncCode], [ImportLevel], CountryCode)
		  VALUES(@TestTypeID, @FileID, @Source, @UserID, @TestName, GETUTCDATE(), 100, @BrStationCode, @SyncCode, @ImportLevel, @CountryCode);
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
				    VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID,@BrStationCode)
			 WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
				    UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID ,BreedingStationCode = @BrStationCode;
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
			DECLARE @TempTVP_Cell TVP_Cell, @TempTVP_Column TVP_Column, @TempTVP_Row TVP_Row, @TVP_Material TVP_Material, @TVP_Well TVP_Material,
			@TVP_MaterialWithWell TVP_TMDW;
			DECLARE @LastRowNr INT =0, @LastColumnNr INT = 0,@PlatesCreated INT,@PlatesRequired INT,@WellsPerPlate INT,@LastPlateID INT,
			@PlateID INT,@TotalRows INT,@AssignedWellTypeID INT, @EmptyWellTypeID INT,@TotalMaterial INT;
			
			DECLARE @NewColumns TABLE([ColumnNr] INT,[TraitID] INT,[ColumLabel] NVARCHAR(100), [DataType] VARCHAR(15),[NewColumnNr] INT);
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
				@TestName = T.TestName,
				@Source = T.RequestingSystem,
				@TestID = T.TestID
			FROM [File] F
			JOIN Test T ON T.FileID = F.FileID
			WHERE F.FileID = @FileID

			SELECT @StatusCode = Statuscode FROM Test WHERE TestID = @TestID;
			IF(@StatusCode >= 200) BEGIN
				EXEC PR_ThrowError 'Cannot import material to this test after plate is requested on LIMS.';
				RETURN;
			END
	
			IF(ISNULL(@CropCode1,'') <> ISNULL(@CropCode,'')) BEGIN
				EXEC PR_ThrowError 'Cannot import material with different crop  to this test.';
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
			 OUTPUT INSERTED.[RowID],INSERTED.[RowNr],INSERTED.MaterialKey INTO @RowData1(RowID, RowNr, MaterialKey)
			 SELECT T.RowNr+ @LastRowNr,T.MaterialKey,@FileID, 1 FROM @TempRow T
			 ORDER BY T.RowNr;

			 --now insert new columns if available which are not already available on table
			 INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
			 SELECT T1.[NewColumnNr], T.[TraitID], T1.[ColumLabel], @FileID, T1.[DataType] 
			 FROM @NewColumns T1
			 LEFT JOIN 
			 (
				    SELECT CT.TraitID,T.TraitName, T.ColumnLabel
				    FROM Trait T 
				    JOIN CropTrait CT ON CT.TraitID = T.TraitID
				    WHERE CT.CropCode = @CropCode AND T.Property = 0
			 )
			 T ON T.ColumnLabel = T1.ColumLabel;

			 INSERT INTO @BridgeColumnTable(OldColNr,NewColNr)
			 SELECT T.ColumnNr,C.ColumnNr FROM 
			 [Column] C
			 JOIN @TempTVP_Column T ON T.ColumLabel = C.ColumLabel
			 WHERE C.FileID = @FileID;

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
			 JOIN @TVPRow T2 ON T1.MaterialKey = T2.MaterialKey;

			 UPDATE T1 SET
				    T1.RowNr = T2.NewRowNr
			 FROM @TempTVP_Cell T1
			 JOIN @BridgeRowTable T2 ON T1.RowNr = T2.OldRowNr;

			 INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
			 SELECT T2.[RowID], T3.[ColumnID], T1.[Value] 
			 FROM @TempTVP_Cell T1
			 JOIN @RowData1 T2 ON T2.RowNr = T1.RowNr
			 JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
			 WHERE ISNULL(T1.[Value], '') <> '';

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
				    VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode,S.RowID,@ObjectID, @BrStationCode)
				WHEN MATCHED AND ISNULL(S.RowID,0) <> ISNULL(T.OriginrowID,0) THEN 
				    UPDATE  SET T.OriginrowID = S.RowID,T.RefExternal = @ObjectID, BreedingStationCode= @BrStationCode;
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
	   IF @@TRANCOUNT > 0 
		ROLLBACK;
	   THROW;
	END CATCH
END
GO