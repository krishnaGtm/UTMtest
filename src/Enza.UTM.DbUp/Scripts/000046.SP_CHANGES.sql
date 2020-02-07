/*
DECLARE @p1 INT, @p2 NVARCHAR(200);
EXEC PR_GetPunchList 52, @p1 OUT, @p2 OUT;
PRINT @P1
PRINT @P2;
*/
ALTER PROCEDURE [dbo].[PR_GetPunchList]
(
	@TestID INT,
	@PlatePlanID INT OUT,
	@PlatePlanName NVARCHAR(200) OUT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Table Table
	(	MaterialKey NVARCHAR(100),
		Position NVARCHAR(5),
		BgColor NVARCHAR(30),
		FgColor NVARCHAR(30),
		PlateID INT,
		PlateName NVARCHAR(150)
	);

	DECLARE @PlatntNrTable TABLE
	(	
		MaterialID INT,
		PlantNr NVARCHAR(100)
	);

	DECLARE @TotalPlates INT, @Count INT = 0, @PlateID INT = 0,@TestType INT,@PlateName NVARCHAR(150),@FileID INT,@PlantNrColumnID NVARCHAR(MAX),@SQL NVARCHAR(MAX), @FileTitle NVARCHAR(MAX);
	DECLARE @Columnlabel NVARCHAR(MAX),@Source NVARCHAR(MAX);
	--DECLARE @PlatePlanID INT, @PlatePlanName NVARCHAR(200);

	SELECT @PlatePlanID = LabPlatePlanID,
	@PlatePlanName = LabPlatePlanName 
	FROM Test WHERE TestID = @TestID;
			
	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate
	WHERE TestID = @TestID; 

	SELECT @TestType = TestTypeID,@Source = RequestingSystem 
	FROM Test
	WHERE TestID = @TestID;

	SELECT @FileID = T.FileID ,
		   @FileTitle = F.FileTitle
	FROM [File] F
	JOIN Test T on T.FileID = F.FileID
	WHERE T.TestID = @TestID;

	IF(@Source = 'Phenome')
		SET @Columnlabel = 'Plant name';
	ELSE
		SET @Columnlabel = 'Plantnr';

	SELECT @PlantNrColumnID = QUOTENAME(ColumnID)
	FROM [Column] C
	JOIN [File] F ON F.FileID = C.FileID
	WHERE F.FileID = @FileID AND C.ColumLabel = @Columnlabel;

	SET @SQL = N'		
		SELECT MaterialID,'+@PlantNrColumnID +' AS Plantnr  FROM 
		(
			SELECT M.MaterialID,C.ColumnID,c.[Value]
			FROM [Cell] C
			JOIN [Column] C1 ON C1.ColumnID = C.ColumnID
			JOIN [Row] R ON R.RowID = C.RowID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN [File] F ON F.FileID = C1.FileID
			WHERE F.FIleID = '+CAST(@FileID AS NVARCHAR(10))+'
		) SRC
		PIVOT
		(
			MAX([Value])
			FOR [ColumnID] IN ('+@PlantNrColumnID+')
		) PV'

	INSERT INTO @PlatntNrTable(MaterialID,PlantNr) EXEC sp_executesql @SQL;
		 
	INSERT INTO @Table(Position,PlateID,PlateName,MaterialKey,BgColor,FgColor)
	SELECT
	W.Position,W.PlateID,P.PlateName, 
	--M.MaterialKey,
	M.Plantnr,
	WT.BGColor,WT.FGColor
	FROM Well W
	LEFT JOIN TestMaterialDeterminationWell TMDW ON W.WellID = TMDW.WellID
	--LEFT JOIN Material M ON M.MaterialID = TMDW.MaterialID
	LEFT JOIN @PlatntNrTable M ON M.MaterialID = TMDW.MaterialID	
	JOIN WellType WT ON Wt.WellTypeID = W.WellTypeId		
	JOIN Plate P ON P.PlateID = W.PlateID
	WHERE P.TestID = @TestID

	--SELECT * FROM @Table;
	WHILE(@Count < @TotalPlates) BEGIN
		SELECT @PlateID = PlateID,@PlateName = PlateName
		FROM Plate 
		WHERE TestID = @TestID
		ORDER BY PlateID
		OFFSET @Count ROWS
		FETCH NEXT 1 ROWS ONLY;

		INSERT INTO @Table(Position,PlateID,PlateName,MaterialKey,BgColor,FgColor)
		SELECT PositionOnPlate,@PlateID,@PlateName,'QC',WT.BGColor,FGColor
		FROM WellTypePosition WTP
		JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		WHERE TestTypeID = @TestType;

		SET @Count = @Count +1;
	END
	SELECT PlateID,PlateName,MaterialKey,Position,BgColor,FgColor,Position2 as [Row], Position1 as [Column], @FileTitle FROM
	( 
		SELECT *,CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
		,LEFT(Position,1) as Position2
		FROM @Table
	) T ORDER BY PlateID,Position2,Position1

END



GO

/*
	EXEC PR_GetPlantsLookup 42, 'KATHMANDU\PBantwa',  'nl'
*/
ALTER PROCEDURE [dbo].[PR_GetPlantsLookup]
(
	@TestID		INT,
	@UserID		NVARCHAR(100),
	@Query		NVARCHAR(1024) = NULL
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @Column NVARCHAR(MAX);

	SELECT @Source = [RequestingSystem] FROM Test WHERE TestID = @TestID
	
	IF(@Source = 'Phenome') BEGIN
		SET @Column = 'plant name';
	END
	ELSE BEGIN
		SET @Column = 'Plantnr';
	END

	SELECT DISTINCT TOP 20
		M.MaterialID, 
		MaterialKey = CE.Value 
	FROM Material M
	JOIN [Row] R ON R.MaterialKey = M.MaterialKey
	JOIN [Column] C ON C.FileID = R.FileID
	JOIN [Cell] CE ON CE.ColumnID = C.ColumnID AND CE.RowID = R.RowID
	JOIN Test T ON T.FileID = R.FileID

	WHERE T.TestID = @TestID AND C.ColumLabel = @Column AND CE.[Value] LIKE '%' + ISNULL(@Query, '') + '%'
	ORDER BY CE.Value;	
END

GO