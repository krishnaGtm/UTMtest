--EXEC PR_UpdateAndVerifyTraitDeterminationResult 'Phenome'
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @tbl TABLE (TestID INT, DeterminationID INT, DeterminationValue NVARCHAR(255));
	INSERT INTO @tbl(TestID, DeterminationID, DeterminationValue)
	SELECT DISTINCT 
		T3.TestID, T1.DeterminationID, T1.ObsValueChar
	FROM TestResult T1
	JOIN Well T2 ON T2.WellID = T1.WellID
	JOIN Plate T3 ON T3.PlateID = T2.PlateID
	JOIN Test T ON T.TestID =T3.TestID
	WHERE NOT EXISTS
	(
		SELECT 
			TraitDeterminationResultID  
		FROM TraitDeterminationResult TDR
		JOIN RelationTraitDetermination RTD ON RTD.RelationID = TDR.RelationID
		WHERE DeterminationID = T1.DeterminationID
		AND DetResChar = T1.ObsValueChar --compare determination and its values in both table and if matches, send traitid and its values to Phenome
	)
	AND T.RequestingSystem  = @Source
	AND T.StatusCode BETWEEN 600 AND 625;
	

	--UPDATE T1 SET 
	--	T1.StatusCode = 650
	--FROM Test T1
	--JOIN
	--(
	--	SELECT DISTINCT TestID FROM @tbl
	--) T2 ON T2.TestID = T1.TestID;

	SELECT 
		T1.TestID, 
		T2.TestName,
		T1.DeterminationID,
		T3.DeterminationName,
		T1.DeterminationValue,
		T2.RequestingUser,
		T2.StatusCode
	FROM @tbl T1
	JOIN Test T2 ON T2.TestID = T1.TestID
	JOIN Determination T3 ON T3.DeterminationID = T1.DeterminationID;

	--update to status 650 if all mapping of determinations and traits for test exists
	UPDATE T1 SET 
		T1.StatusCode = 650
	FROM Test T1
	WHERE NOT EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.RequestingSystem = @Source AND T1.StatusCode BETWEEN 600 AND 625

	--update to status 625 if mapping of determinations and traits for test not present.
	UPDATE T1 SET 
		T1.StatusCode = 625
	FROM Test T1
	WHERE EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.StatusCode != 625
END

GO

/*
Author:			KRISHNA GAUTAM
Created Date:	2017-11-23
Description:	Import Excel data to database. */
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
	@ExpectedDate			DATETIME
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

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
		DECLARE @FileID INT;

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime], [RefExternal])
		VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE(), @ObjectID);
		--Get Last inserted fileid
		SELECT @FileID = SCOPE_IDENTITY();

		INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID])
		OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		SELECT T.RowNr,T.MaterialKey,@FileID FROM @TVPRow T;

		INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		SELECT T.[ColumnNr], CT.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T
		LEFT JOIN Trait T1 ON T1.TraitName = T.ColumLabel
		LEFT JOIN CropTrait CT ON CT.TraitID = T.TraitID AND CT.CropCode = @CropCode
		
		

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate],[SyncCode])
		VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, @Isolated,@BreedingStationCode, @ExpectedDate,@SyncCode);
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