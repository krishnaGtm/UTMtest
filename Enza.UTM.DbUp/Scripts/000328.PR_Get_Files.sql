DROP PROCEDURE IF EXISTS PR_Get_Files
GO

/*
EXEC  PR_Get_Files 'ON', 'NLEN'
*/
CREATE PROCEDURE [dbo].[PR_Get_Files]
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
		T.Cumulate,
		T.ImportLevel,
		ExcludeControlPosition = CAST(ISNULL(T.ExcludeControlPosition, 0) AS BIT)
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