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
		LEFT JOIN Trait T1 ON T1.TraitName = T.ColumLabel OR T1.ColumnLabel = T.ColumLabel
		LEFT JOIN CropTrait CT ON CT.TraitID = T1.TraitID AND CT.CropCode = @CropCode
		
		

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

