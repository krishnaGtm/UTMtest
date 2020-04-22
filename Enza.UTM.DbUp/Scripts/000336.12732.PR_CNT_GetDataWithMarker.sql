/*
=========Changes====================
Changed By			DATE				Description
Krishna Gautam		2019-Mar-25			#12732: Fixed issue on importing on existing file gives error.


========Example=============

*/

ALTER PROCEDURE [dbo].[PR_CNT_ImportMaterials]
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
	@TVPList TVP_List		  READONLY,
    @DonorNrColumnName      NVARCHAR(200) = NULL,
	@FileID					INT
)
AS BEGIN
    SET NOCOUNT ON;

    --DECLARE @FileID INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TblDonor TABLE(RowID INT, DonorNr NVARCHAR(200));
    
    --SELECT 
	   --@FileID = FileID
    --FROM Test WHERE TestID = @TestID;

    BEGIN TRY
	   BEGIN TRANSACTION;

	   --import data as new test/file
	   IF(ISNULL(@FileID, 0) = 0) 
	   BEGIN
		  IF(ISNULL(@TestTypeID, 0) = 0) BEGIN
			 EXEC PR_ThrowError 'Invalid test type ID.';
			 RETURN;
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
			IF NOT EXISTS (SELECT * FROM [File] WHERE FileID = @FileID)
			BEGIN
				EXEC PR_ThrowError 'Invalid FileID.';
				RETURN;
			END	
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

        --Update donor nr based on import level
        IF(@ImportLevel = 'LIST')
            SET @DonorNrColumnName = 'Entry Code';

        SET @SQL = N'
        SELECT 
            RowID,
            DonorNr = ' + QUOTENAME(@DonorNrColumnName) + N'
        FROM
        (
            SELECT
                R.RowID,
                C.ColumLabel,
                C2.[Value]
            FROM [Row] R
            JOIN [Column] C ON C.FileID = R.FileID
            JOIN Cell C2 ON C2.RowID = R.RowID AND C2.ColumnID = C.ColumnID
            WHERE R.FileID = @FileID
        ) V1 
        PIVOT
        (
            MAX([Value])
            FOR [ColumLabel] IN (' + QUOTENAME(@DonorNrColumnName) + N')
        ) P ';

        INSERT @TblDonor(RowID, DonorNr)
        EXEC sp_executesql @SQL, N'@FileID INT', @FileID;

        --update donor information in DonorInfo table
		MERGE INTO CnTInfo T
		USING
		(
			SELECT
            T1.RowID,
            T1.DonorNr
			FROM @TblDonor T1
			LEFT JOIN
			(
				SELECT 
					R.RowID 
				FROM CnTInfo C
				JOIN [Row] R ON R.RowID = C.RowID   
				WHERE R.FileID = @FileID     
			) T2 ON T2.RowID = T1.RowID
		) S ON S.RowID = T.RowID
		WHEN MATCHED AND T.DonorNumber <> S.DonorNr
		THEN UPDATE SET T.DonorNumber = S.DonorNr
		WHEN NOT MATCHED THEN
		INSERT (RowID,DonorNumber)
		VALUES(S.RowID, S.DonorNr);
        
		
		--INSERT CnTInfo(RowID, DonorNumber)
  --      SELECT
  --          T1.RowID,
  --          T1.DonorNr
  --      FROM @TblDonor T1
  --      LEFT JOIN
  --      (
  --          SELECT 
  --              R.RowID 
  --          FROM CnTInfo C
  --          JOIN [Row] R ON R.RowID = C.RowID   
  --          WHERE R.FileID = @FileID     
  --      ) T2 ON T2.RowID = T1.RowID;

		COMMIT;
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT > 0 
		ROLLBACK;
	   THROW;
	END CATCH
END
