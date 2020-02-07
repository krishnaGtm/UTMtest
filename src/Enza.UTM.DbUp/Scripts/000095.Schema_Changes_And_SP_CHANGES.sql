ALTER TABLE Test
ADD Cumulate BIT;

GO

ALTER TABLE CropRD
ADD InvalidPer Decimal(5,2);

GO

ALTER PROCEDURE [dbo].[PR_GetTestsLookup] 
(
	--@UserID nvarchar(100)
	@CropCode NVARCHAR(10),
	@BreedingStationCode NVARCHAR(10)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TotalWells INT,@BlockedWells INT;

	SELECT @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))
	FROM PlateType

    SELECT 
		T.TestID, 
		T.TestName, 
		TT.TestTypeID, 
		TT.TestTypeName,
		T.Remark,
		TT.RemarkRequired,
		T.StatusCode,
		FixedPositionAssigned = CAST((CASE WHEN ISNULL(T1.TotalFixed,0) = 0 THEN 0 ELSE 1 END) AS BIT),
		T.MaterialStateID,
		T.MaterialTypeID,
		T.ContainerTypeID,
		MaterialReplicated = CAST((CASE WHEN ISNULL(T2.ReplicatedCount,1) = 1 THEN 0 ELSE 1 END) AS BIT),
		T.PlannedDate,
		T.Isolated,
		ST1.SlotID,
		WellsPerPlate = @TotalWells - ISNULL(T3.Blocked,0),
		T.BreedingStationCode,
		F.CropCode,
		T.ExpectedDate,
		S1.SlotName,
		T.LabPlatePlanName,
		T.RequestingSystem,
		T.Cumulate
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID
	JOIN TestType TT ON T.TestTypeID = TT.TestTypeID
	LEFT JOIN [Status] ST ON ST.StatusCode = T.StatusCode AND ST.StatusTable = 'Test'
	LEFT JOIN
	(
		SELECT T.TestID, COUNT(WT.WellTypeID) AS TotalFixed
		FROM Well W
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN Plate P ON P.PlateID = W.PlateID
		JOIN Test T ON T.TestID = P.TestID
		JOIN [File] F ON F.FileID = T.FileID
		WHERE WT.WellTypeName   = 'F' AND 
		       --T.RequestingUser = @UserID
			   T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode
		GROUP BY T.TestID
	) T1 ON T1.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT T.TestID, COUNT(MaterialID) AS ReplicatedCount FROM
		[File] F 
		JOIN Test T ON T.FileID = T.FileID
		JOIN Plate P ON P.TestID = T.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
		JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID		
		WHERE --T.RequestingUser = @UserID
			--AND 
			WT.WellTypeName <> 'F'
			AND F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode
			GROUP BY T.TestID
			HAVING COUNT(MaterialID) > 1
	) T2 ON T2.TestID = T.TestID
	LEFT JOIN SlotTest ST1 ON ST1.TestID = T.TestID
	LEFT JOIN Slot S1 ON S1.SlotID = ST1.SlotID
	LEFT JOIN 
	(
		SELECT Blocked = COUNT(TT.TestTypeID),TT.TestTypeID
		FROM TestType TT
		LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID
		LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE WT.WellTypeName = 'B'
		GROUP BY TT.TestTypeID,WTP.WellTypeID
	) T3 ON T3.TestTypeID = T.TestTypeID
	WHERE --T.RequestingUser = @UserID
	F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode
	AND T.StatusCode <= 600
	ORDER BY TestID DESC;

END

GO


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
	DECLARE @MarkerNeeded BIT = 0, @AssignedDetermination INT =0;
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


ALTER PROCEDURE [dbo].[PR_Get_Files]
(
	--@UserID NVARCHAR(100),
	@CropCode NVARCHAR(10),
	@BreedingStationCode NVARCHAR(10),
	@TestID INT = NULL
) AS
BEGIN
	
	DECLARE @TotalWells INT,@BlockedWells INT;
	IF(ISNULL(@TestID,0)<> 0) BEGIN
		SELECT @BreedingStationCode = T.BreedingStationCode,@CropCode = F.CropCode FROM 
		[File] F 
		JOIN Test T ON T.FileID = F.FileID WHERE T.TestID = @TestID
	END

	SELECT @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))
	FROM PlateType;

	SELECT                  
		F.FileID, 	                        
		F.CropCode, 
		F.FileTitle, 
		F.UserID, 
		F.ImportDateTime,
		T.TestID,
		T.TestTypeID,
		T.Remark,
		TT.RemarkRequired,
		T.StatusCode,
		T.MaterialStateID,
		T.MaterialTypeID,
		T.ContainerTypeID,
		T.Isolated,
		T.PlannedDate,
		ST.SlotID,
		WellsPerPlate = @TotalWells - ISNULL(T1.Blocked,0),
		T.BreedingStationCode,
		T.ExpectedDate,
		T.LabPlatePlanName,
		T.RequestingSystem,
		T.Cumulate
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID	
	JOIN TestType TT ON TT.TestTypeID = T.TestTypeID
	LEFT JOIN SlotTest ST ON ST.TestID = T.TestID
	LEFT JOIN 
	(
		SELECT Blocked = COUNT(TT.TestTypeID),TT.TestTypeID
		FROM TestType TT
		LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID
		LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE WT.WellTypeName = 'B'
		GROUP BY TT.TestTypeID,WTP.WellTypeID
	) T1 ON T1.TestTypeID = T.TestTypeID
	WHERE --F.UserID = @UserID
	F.CropCode = @CropCode
	AND T.BreedingStationCode = @BreedingStationCode
	AND T.StatusCode <= 600 
	AND (ISNULL(@TestID, 0) = 0 OR T.TestID = @TestID)
	ORDER BY FileID DESC;
END
