

/*
EXEC  PR_Get_Files 'ON', 'NLEN'
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
	ORDER BY FileID DESC
	OPTION (RECOMPILE);
END

GO

-- =============================================  
-- Author:  Binod Gurung  
-- Create date: 12/14/2017  
-- Description: Get List of Test to fill combo box   
-- =============================================  
-- EXEC [PR_GetTestsLookup] 'ON', 'NLEN'  
ALTER PROCEDURE [dbo].[PR_GetTestsLookup]   
(    
    @CropCode NVARCHAR(10),  
    @BreedingStationCode NVARCHAR(10)  
)  
AS  
BEGIN  
  
    SET NOCOUNT ON;  
  
	DECLARE @FixedWellTypeID INT,@BlockedWellTpeID iNT
    DECLARE @TotalWells INT;  
    DECLARE @tbl1 TABLE(TestID INT, TotalFixed INT);
    --DECLARE @tbl2 TABLE(TestID INT, ReplicatedCount INT);
    DECLARE @tbl3 TABLE(TestTypeID INT, Blocked INT);

	SELECT @BlockedWellTpeID = WellTypeID FROM WellType WHERE WellTypeName = 'B';
	SELECT @FixedWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'F';
    
  
    SELECT 
	   @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))  
    FROM PlateType;

    INSERT INTO @tbl1(TestID, TotalFixed)
    SELECT 
	   T.TestID, 
	   COUNT(W.WellTypeID) AS TotalFixed  
    FROM Well W
    JOIN Plate P ON P.PlateID = W.PlateID  
    JOIN Test T ON T.TestID = P.TestID  
    JOIN [File] F ON F.FileID = T.FileID  
    WHERE 
		W.WellTypeID = @FixedWellTypeID AND
		T.BreedingStationCode = @BreedingStationCode AND 
		F.CropCode = @CropCode  
    GROUP BY T.TestID;

    INSERT INTO @tbl3(TestTypeID, Blocked)
    SELECT 
	   TT.TestTypeID,
	   Blocked = COUNT(TT.TestTypeID)
    FROM TestType TT  
    LEFT JOIN WellTypePosition WTP ON TT.TestTypeID = WTP.TestTypeID  
    LEFT JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID  
    WHERE WT.WellTypeName = 'B'  
    GROUP BY TT.TestTypeID,WTP.WellTypeID;
   
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
	 MaterialReplicated = CAST(0 AS BIT),-- CAST((CASE WHEN ISNULL(T2.ReplicatedCount,1) = 1 THEN 0 ELSE 1 END) AS BIT),  
	 T.PlannedDate,  
	 T.Isolated,  
	 ST1.SlotID,  
	 WellsPerPlate = CASE WHEN (TT.TestTypeID = 1 OR (ISNULL(T.ExcludeControlPosition,0) = 1 AND T.TestTypeID = 2)) THEN  @TotalWells - ISNULL(T3.Blocked,0) ELSE @TotalWells END,  
	 T.BreedingStationCode,  
	 F.CropCode,  
	 T.ExpectedDate,  
	 S1.SlotName,  
	 T.LabPlatePlanName,  
	 T.RequestingSystem,  
	 T.Cumulate,  
	 T.ImportLevel  
	FROM [File] F  
	JOIN Test T ON T.FileID = F.FileID  
	JOIN TestType TT ON T.TestTypeID = TT.TestTypeID  
	LEFT JOIN [Status] ST ON ST.StatusCode = T.StatusCode AND ST.StatusTable = 'Test'  
	LEFT JOIN @tbl1 T1 ON T1.TestID = T.TestID  
	--LEFT JOIN @tbl2 T2 ON T2.TestID = T.TestID  
	LEFT JOIN SlotTest ST1 ON ST1.TestID = T.TestID  
	LEFT JOIN Slot S1 ON S1.SlotID = ST1.SlotID  
	LEFT JOIN @tbl3 T3 ON T3.TestTypeID = T.TestTypeID  
	WHERE
		F.CropCode = @CropCode AND 
		T.BreedingStationCode = @BreedingStationCode AND 
		T.StatusCode <= 600  
	ORDER BY TestID DESC  
	OPTION (RECOMPILE);
END  
  

GO