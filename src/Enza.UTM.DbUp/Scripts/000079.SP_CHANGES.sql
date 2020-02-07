
/*
EXEC  PR_Get_Files 'KATHMANDU\krishna'
*/
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
		T.LabPlatePlanName
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

GO

-- =============================================
-- Author:		Binod Gurung
-- Create date: 12/14/2017
-- Description:	Get List of Test to fill combo box 
-- =============================================
-- EXEC [PR_GetTestsLookup] 'kathmandu\krishna'
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
		T.LabPlatePlanName
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