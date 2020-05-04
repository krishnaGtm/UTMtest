/*
	Author					Date			Description
	Dibya					2020-01-30		Import external excel file into UTM
	Krishna Gautam			2020-03-12		#11373: Automatically assign marker based on marker name on columns (marker01, marker02, marker03,.....)
	Krishna Gautam			2020-05-04		#13094: Issue while importing fixed.
*/
ALTER PROCEDURE [dbo].[PR_Import_ExternalData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode    NVARCHAR(10),
	@SyncCode				NVARCHAR(10),
	@CountryCode			NVARCHAR(10),
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
	@ExcludeControlPosition BIT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @2GBTestType INT =0;
		DECLARE @TVPTMD TVP_TMD;

		DECLARE @FileID INT;

		--import data as new test/file
		  IF EXISTS(SELECT FileTitle 
				    FROM [File] F 
				    JOIN Test T ON T.FileID = F.FileID 
				    WHERE T.BreedingStationCode = @BreedingStationCode 
				    AND F.CropCode = @CropCode 
				    AND F.FileTitle =@FileTitle) 
		  BEGIN
			 EXEC PR_ThrowError 'File already exists.';
			 RETURN;
		  END

		  IF(ISNULL(@TestTypeID,0)=0) BEGIN
			 EXEC PR_ThrowError 'Invalid test type ID.';
			 RETURN;
		  END

		  SELECT @2GBTestType = TestTypeID FROM TestType WHERE TestTypeCode = 'MT';

		  DECLARE @RowData TABLE([RowID] int, [RowNr] int);
		  DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);

		  INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
		  VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE());
		  --Get Last inserted fileid
		  SELECT @FileID = SCOPE_IDENTITY();

		  INSERT INTO [Row] ([RowNr], [MaterialKey], [FileID], NrOfSamples)
		  OUTPUT INSERTED.[RowID], INSERTED.[RowNr] INTO @RowData
		  SELECT T.RowNr, T.MaterialKey, @FileID, 1 FROM @TVPRow T;
		  --Update MaterialKey with RowID since it is not coming from excel file for this external import
		  UPDATE R SET 
			 R.MaterialKey = R.RowID
		  FROM [Row] R
		  JOIN @RowData R2 ON R2.RowID = R.RowID;

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
		  T1 ON T1.ColumnLabel = T.ColumLabel;		

		  INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		  SELECT [RowID], [ColumnID], [Value] 
		  FROM @TVPCell T1
		  JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		  JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr
		  WHERE ISNULL(T1.[Value],'') <> '';	

		  --CREATE TEST
		  INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],
			 [MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode],[Cumulate], [ImportLevel], CountryCode, ExcludeControlPosition)
		  VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, 
			 @Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode, @Cumulate, @ImportLevel, @CountryCode, @ExcludeControlPosition);
		  --Get Last inserted testid
		  SELECT @TestID = SCOPE_IDENTITY();

		  --CREATE Materials if not already created
		  MERGE INTO Material T 
		  USING
		  (
				SELECT 
				    R.MaterialKey
				FROM [Row] R
				WHERE FileID = @FileID		
		  ) S	ON S.MaterialKey = T.MaterialKey
		  WHEN NOT MATCHED THEN 
			 INSERT(MaterialType, MaterialKey, [Source], CropCode, BreedingStationCode)
			 VALUES (@ImportLevel, S.MaterialKey, @Source, @CropCode, @BreedingStationCode);


		--change of #11373 starts here
		IF(@2GBTestType = @TestTypeID)
		BEGIN

			INSERT INTO @TVPTMD(MaterialID,DeterminationID,Selected)
			SELECT 
				M.MaterialID,
				D.DeterminationID,
				1 
			FROM [File] F
			JOIN [Row] R ON R.FileID = F.FileID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [Column] C ON C.FileID = F.FileID
			JOIN [Cell] C1 ON C1.RowID = R.RowID AND C1.ColumnID = C.ColumnID
			JOIN Determination D ON D.DeterminationName = C1.[Value] AND D.CropCode = F.CropCode
			JOIN TestTypeDetermination TTD ON TTD.DeterminationID = D.DeterminationID AND TTD.TestTypeID = @TestTypeID
			WHERE F.FileID = @FileID AND C.ColumLabel LIKE 'Marker%';

			
			EXEC  PR_SaveTestMaterialDeterminationWithTVP @CropCode, @TestID, @TVPTMD

			--set rearrange to true 
			UPDATE Test SET RearrangePlateFilling = 1 WHERE TestID = @TestID;

		END
		
		COMMIT;
	END TRY
	BEGIN CATCH
	   IF @@TRANCOUNT >0
		  ROLLBACK;
	   THROW;
	END CATCH
END
