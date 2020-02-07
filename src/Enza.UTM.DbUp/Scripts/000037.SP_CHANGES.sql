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
	@ObjectID				NVARCHAR(100)
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

		INSERT INTO [FILE] ([CropCode],[FileTitle],[UserID],[ImportDateTime], [RefExternal])
		VALUES(@CropCode, @FileTitle, @UserID, GETUTCDATE(), @ObjectID);
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
		INSERT INTO [Test]([TestTypeID],[FileID],[RequestingSystem],[RequestingUser],[TestName],[CreationDate],[StatusCode],[PlannedDate], [MaterialStateID],[MaterialTypeID], [ContainerTypeID],[Isolated],[BreedingStationCode],[ExpectedDate])
		VALUES(@TestTypeID, @FileID, @Source, @UserID,@TestName , GETUTCDATE(), 100,@PlannedDate,@MaterialStateID, @MaterialTypeID, @ContainerTypeID, @Isolated,@BreedingStationCode, DateAdd(Week,2,@PlannedDate));
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
	EXEC PR_Update_Test 76,'KATHMANDU\psindurakar',2,0,2,2,'2018-04-27',1
*/

ALTER PROCEDURE [dbo].[PR_Update_Test]
(
	@TestID INT,
	@UserID NVARCHAR(200),
	@ContainerTypeID INT,
	@Isolated BIT,
	@MaterialTypeID INT,
	@MaterialStateID INT,
	@PlannedDate DateTime,
	@TestTypeID INT,
	@SlotID INT = NULL --This value is not required for now 
)
AS
BEGIN
	DECLARE @ReturnValue INT;
	DECLARE @MarkerNeeded BIT = 0, @AssignedDetermination INT =0;
	IF(ISNULL(@TestID,0)=0) BEGIN
		EXEC PR_ThrowError 'Test doesn''t exist.';
		RETURN;
	END

	--check valid test.
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END
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

	--check if markers assigned and new test type doesnot require marker
	SELECT @AssignedDetermination = COUNT(TestMaterialDeterminationID) FROM TestMaterialDetermination WHERE TestID = @TestID;
	SELECT @MarkerNeeded = DeterminationRequired FROM TestType WHERE TestTypeID = @TestTypeID
	IF(@MarkerNeeded = 0 AND @AssignedDetermination > 0) BEGIN
		EXEC PR_ThrowError 'Cannot change ''Test Type''. Marker already assigned for this Test.';
		RETURN;
	END

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
			ExpectedDate = DATEADD(Week,2,@PlannedDate)
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
	@UserID NVARCHAR(100),
	@MaxPlates INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @SynCode CHAR(2), @CropCode CHAR(2), @TotalTests INT, @Isolated BIT, @ReturnValue INT, @RemarkRequired BIT, @DeterminationRequired INT,@DeadWellType INT,@TotalPlates INT;

	--Validate Test for corresponding user
	EXEC @ReturnValue = PR_ValidateTest @TestID, @UserID;
	IF(@ReturnValue <> 1) BEGIN
		RETURN;
	END

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


	SELECT TOP 1 @SynCode = (LEFT(M.MaterialKey,2)) , 
				 @CropCode = M.CropCode
	FROM Row R
	JOIN Test T ON T.FileID = R.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	WHERE T.TestID = @TestID
	  AND T.RequestingUser = @UserID;

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
	  AND T.RequestingUser = @UserID;

	--For Test type with Remarkrequired true is DNA Isolation type. For DNA Isolation type, Isolated value is true
	IF(@RemarkRequired = 1)
		SET @Isolated = 1

	--Determination should be used for Test type with DeterminatonRequired true
	IF(@TotalTests = 0 AND @DeterminationRequired = 1)
	BEGIN
		EXEC PR_ThrowError N'Please assign at least one marker.';
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
	 AND  T.RequestingUser = @UserID
	GROUP BY T.TestID, T.PlannedDate, T.Remark, MS.MaterialStateCode, MT.MaterialTypeCode, CT.ContainerTypeCode, T.Isolated,T.ExpectedDate;

END

GO

UPDATE TEST SET ExpectedDate = DATEADD(WEEK,2,PlannedDate);