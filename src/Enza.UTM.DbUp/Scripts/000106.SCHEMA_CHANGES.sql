
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Row]') 
         AND name = 'NrOfSamples'
) BEGIN
ALTER TABLE [Row]
ADD NrOfSamples INT;
END
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Test]') 
         AND name = 'ImportLevel'
) BEGIN
	ALTER TABLE Test
	ADD ImportLevel NVARCHAR(20)

END
GO

UPDATE Test SET ImportLevel = 'PLT'
WHERE ISNULL(ImportLevel, '') = '';
GO



/*
Author:			KRISHNA GAUTAM
Created Date:	2017-11-24
Description:	Get transposed data. */

/*
=================Example===============

EXEC PR_GET_Data 56,'KATHMANDU\dsuvedi', 1, 3, '[Lotnr]   LIKE  ''%9%''   and [Crop]   LIKE  ''%LT%'''
EXEC PR_GET_Data 2090, 1, 100, ''
*/
ALTER PROCEDURE [dbo].[PR_GET_Data]
(
	@TestID INT,
	--@User NVARCHAR(100),
	@Page INT,
	@PageSize INT,
	@FilterQuery NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;
	DECLARE @FilterClause NVARCHAR(MAX);
	DECLARE @Offset INT;
	DECLARE @Query NVARCHAR(MAX);
	DECLARE @Columns2 NVARCHAR(MAX)
	DECLARE @Columns NVARCHAR(MAX);	
	DECLARE @ColumnIDs NVARCHAR(MAX);

	IF(ISNULL(@FilterQuery,'')<>'')
	BEGIN
		SET @FilterClause = ' AND '+ @FilterQuery
	END
	ELSE
	BEGIN
		SET @FilterClause = '';
	END

	SET @Offset = @PageSize * (@Page -1);

	--get file id based on testid
	SELECT @FileID = FileID 
	FROM Test 
	WHERE TestID = @TestID;
	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'Invalid file or test.';
		RETURN;
	END
	
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(MAX(ColumnID)) +' AS '+ MAX(Datatype) +')' + ' AS ' + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID),QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	--ORDER BY [ColumnNr] ASC;

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END

	SET @Query = N' ;WITH CTE AS 
	(
		SELECT R.RowID, R.[RowNr], ' + @Columns2 + ' 
		FROM [ROW] R 
		LEFT JOIN 
		(
			SELECT PT.[MaterialKey], PT.[RowNr], ' + @Columns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT 
						T3.[MaterialKey],T3.RowNr,T1.[ColumnID], T1.[Value]
					FROM [Cell] T1
					JOIN [Column] T2 ON T1.ColumnID = T2.ColumnID
					JOIN [Row] T3 ON T3.RowID = T1.RowID
					JOIN [FILE] T4 ON T4.FileID = T3.FileID
					WHERE T2.FileID = @FileID 
					--AND T4.UserID = @User
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[MaterialKey] = T1.MaterialKey  				
			WHERE R.FileID = @FileID ' + @FilterClause + '
	), Count_CTE AS (SELECT COUNT([RowNr]) AS [TotalRows] FROM CTE) 					
	SELECT CTE.RowID, '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	--PRINT @Query;
	--EXEC sp_executesql @Query, N'@FileID INT, @User NVARCHAR(100)', @FileID,@User;
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;		
	SELECT [TraitID], [ColumLabel] as ColumnLabel, DataType = MAX([DataType]),ColumnNr = MAX([ColumnNr]),CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	Fixed = CASE WHEN [ColumLabel] = 'Crop' OR [ColumLabel] = 'GID' OR [ColumLabel] = 'Plantnr' OR [ColumLabel] = 'Plant name' THEN 1 ELSE 0 END
	FROM [Column] 
	WHERE [FileID]= @FileID
	GROUP BY ColumLabel,TraitID
	ORDER BY ColumnNr;	

END
GO

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
		T.ImportLevel
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
-- EXEC [PR_GetTestsLookup] 'ON', 'NLEN'
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
		T.Cumulate,
		T.ImportLevel
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

/*
	DECLARE @DATA NVARCHAR(MAX) = '[{"id": 21520, "nr": 5}]';
	EXEC PR_SaveNrOfSamples 3075, @DATA
*/
CREATE PROCEDURE PR_SaveNrOfSamples
(
	@FileID		INT,
	@DATA		NVARCHAR(MAX) 
) AS BEGIN
	SET NOCOUNT ON;

	UPDATE R SET 
		NrOfSamples = D.NrOfSamples
	FROM [Row] R
	JOIN OPENJSON(@DATA) WITH 
	(   
		RowID		 INT   '$.id',  
		NrOfSamples  INT   '$.nr'
	) D ON D.RowID = R.RowID
	WHERE R.FileID = @FileID;
END
GO