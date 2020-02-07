/*
Author:			KRISHNA GAUTAM
Created Date:	2017-11-23
Description:	Import Excel data to database. */
ALTER PROCEDURE [dbo].[PR_Insert_ExcelData]
(
	@CropCode				NVARCHAR(10),
	@BreedingStationCode     NVARCHAR(10),
	@TestTypeID				INT,
	@UserID					NVARCHAR(100),
	@FileTitle				NVARCHAR(200),
	@TVPColumns TVP_Column	READONLY,
	@TVPRow TVP_Row			READONLY,
	@TVPCell TVP_Cell		READONLY,
	@PlannedDate			DATETIME,
	@MaterialStateID		INT,
	@MaterialTypeID			INT,
	@ContainerTypeID		INT,
	@Isolated				BIT,
	@Source					NVARCHAR(4),
	@TestID					INT OUTPUT
)
AS BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		IF(ISNULL(@TestTypeID,0)=0) BEGIN
			EXEC PR_ThrowError 'Invalid test type ID.';
			RETURN;
		END

		DECLARE @RowData TABLE([RowID] int,	[RowNr] int	);
		DECLARE @ColumnData TABLE([ColumnID] int,[ColumnNr] int);
		DECLARE @FileID INT;

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime])
		VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE());
		--Get Last inserted fileid
		SELECT @FileID = SCOPE_IDENTITY();

		INSERT INTO [Row] ( [RowNr], [MaterialKey], [FileID])
		OUTPUT INSERTED.[RowID],INSERTED.[RowNr] INTO @RowData
		SELECT T.RowNr,T.MaterialKey,@FileID FROM @TVPRow T;

		INSERT INTO [Column] ([ColumnNr], [TraitID], [ColumLabel], [FileID], [DataType])
		OUTPUT INSERTED.[ColumnID], INSERTED.[ColumnNr] INTO @ColumnData
		SELECT T.[ColumnNr], T.[TraitID], T.[ColumLabel], @FileID, T.[DataType] FROM @TVPColumns T;

		INSERT INTO [Cell] ( [RowID], [ColumnID], [Value])
		SELECT [RowID], [ColumnID], [Value] 
		FROM @TVPCell T1
		JOIN @RowData T2 ON T2.RowNr = T1.RowNr
		JOIN @ColumnData T3 ON T3.ColumnNr = T1.ColumnNr;	

		--CREATE TEST
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode])
		VALUES(@TestTypeID, @FileID, @Source, @UserID, LEFT(@FileTitle, LEN(@FileTitle) - 5), GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, @Isolated,@BreedingStationCode);
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

/*
	EXEC PR_GetDeterminations 'Kathmandu\dsuvedi','LT', 1, 62
*/
ALTER PROCEDURE [dbo].[PR_GetDeterminations]
(
	@UserID		NVARCHAR(50),
	@CropCode	NVARCHAR(10),
	@TestTypeID	INT,
	@TestID		INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(20);

	SELECT 
		T1.DeterminationID,
		T1.DeterminationName,
		T1.DeterminationAlias,
		T2.ColumnLabel
	FROM Determination T1
	JOIN
	(
		SELECT DISTINCT
			T1.CropCode,
			T1.DeterminationID,
			T1.ColumnLabel,
			T2.ColumnNr
		FROM RelationTraitDetermination T1
		JOIN 
		(
			SELECT 
				C.TraitID,
				C.ColumnNr,
				T.RequestingSystem
			FROM [Column] C
			JOIN [File] F ON F.FileID = C.FileID
			JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
			WHERE T.TestID = @TestID 
			AND F.UserID = @UserID			
		) T2 ON T2.TraitID = T1.TraitID AND T2.RequestingSystem = T1.[Source]
	) T2 ON T2.CropCode = T1.CropCode AND T2.DeterminationID = T1.DeterminationID
	WHERE T1.CropCode = @CropCode AND T1.TestTypeID = @TestTypeID
	ORDER BY T2.ColumnNr;
END
