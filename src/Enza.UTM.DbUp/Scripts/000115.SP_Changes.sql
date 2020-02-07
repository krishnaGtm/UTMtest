
/****** Object:  StoredProcedure [dbo].[PR_GetPunchList]    Script Date: 12/19/2018 1:11:46 PM ******/
DROP PROCEDURE  IF EXISTS [dbo].[PR_GetPunchList]
GO

/*
DECLARE @p1 INT, @p2 NVARCHAR(200);
EXEC PR_GetPunchList 52, @p1 OUT, @p2 OUT;
PRINT @P1
PRINT @P2;
*/
CREATE PROCEDURE [dbo].[PR_GetPunchList]
(
	@TestID INT,
	@PlatePlanID INT OUT,
	@PlatePlanName NVARCHAR(200) OUT,
	@SlotName NVARCHAR(MAX) OUT
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
	DECLARE @Columnlabel NVARCHAR(MAX),@Source NVARCHAR(MAX), @ImportLevel NVARCHAR(MAX);
	--DECLARE @PlatePlanID INT, @PlatePlanName NVARCHAR(200);

	SELECT @PlatePlanID = LabPlatePlanID,
	@PlatePlanName = LabPlatePlanName,
	@SlotName = S.SlotName 
	FROM Test T
	LEFT JOIN SlotTest ST ON ST.TestID = T.TestID
	LEFT JOIN Slot S ON S.SlotID = ST.SlotID  WHERE T.TestID = @TestID;
			
	SELECT @TotalPlates = COUNT(PlateID)
	FROM Plate
	WHERE TestID = @TestID; 

	SELECT @TestType = TestTypeID,@Source = RequestingSystem,@ImportLevel = ImportLevel 
	FROM Test
	WHERE TestID = @TestID;

	SELECT @FileID = T.FileID ,
		   @FileTitle = F.FileTitle
	FROM [File] F
	JOIN Test T on T.FileID = F.FileID
	WHERE T.TestID = @TestID;

	IF(@Source = 'Breezys') BEGIN
		SET @Columnlabel = 'Plantnr';
	END
	ELSE IF(@ImportLevel='LIST') BEGIN
		SET @Columnlabel = 'GID';
	END
	ELSE BEGIN
		SET @Columnlabel = 'plant name';
	END


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


DROP PROCEDURE IF EXISTS [dbo].[PR_SaveNrOfSamples]
GO


/*
	DECLARE @DATA NVARCHAR(MAX) = '[{"id": 21520, "nr": 5}]';
	EXEC PR_SaveNrOfSamples 3075, @DATA
*/
CREATE PROCEDURE [dbo].[PR_SaveNrOfSamples]
(
	@FileID		INT,
	@DATA		NVARCHAR(MAX) 
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @TestID INT,@ImportLevel NVARCHAR(MAX);

	SELECT @TestID = TestID,@ImportLevel = ImportLevel FROM Test  WHERE FileID = @FileID

	UPDATE R SET 
		NrOfSamples = D.NrOfSamples
	FROM [Row] R
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN OPENJSON(@DATA) WITH 
	(   
		MaterialID	 INT   '$.id',  
		NrOfSamples  INT   '$.nr'
	) D ON D.MaterialID = M.MaterialID
	WHERE R.FileID = @FileID;
	
	IF(@ImportLevel = 'LIST') BEGIN
		EXEC PR_PlateFillingForGroupTesting @TestID
	END
END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_PlateFillingForGroupTesting]
GO

CREATE PROCEDURE [dbo].[PR_PlateFillingForGroupTesting]
(
	@TestID INT
)
AS
BEGIN
	
	--Create plate and well if needed
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		DECLARE @PlatesRequired INT, @TotalNrSample INT = 0, @PlatesCreated INT=0, @TotalWellsPerPlate INT, @TempWellTable TVP_TempWellTable,@TVP_Well TVP_Material, @TVP_Material TVP_Material,@MaterialWithWell TVP_TMDW;
		DECLARE @StartRow VARCHAR(2), @EndRow VARCHAR(2), @StartColumn INT, @EndColumn INT, @RowCounter INT, @ColumnCounter INT,@PlateID INT;
		DECLARE @FileName NVARCHAR(MAX), @SameTestCount NVARCHAR(MAX), @Crop NVARCHAR(MAX),@AssignedWellTypeID INT, @EmptyWellTypeID INT,@TotalMaterial INT,@Count INT= 1,@NrOfSample INT=1, @NrOfSampleCount INT =0, @MaterialID INT;
		
		DECLARE @TVP_MaterialsWithNrOfSample AS TABLE(ID INT IDENTITY(1,1),MaterialID INT, NrOfSample INT);

		SELECT @FileName = F.FileTitle, @Crop = F.CropCode 
		FROM Test T 
		JOIN [File] F ON F.FileID = T.FileID;

		SELECT @AssignedWellTypeID = WelltypeID 
		FROM WellType WHERE WellTypeName = 'A';
		
		SELECT @EmptyWellTypeID = WellTypeID
		FROM WellType WHERE WellTypeName = 'E'

		SELECT @SameTestCount = RIGHT('000' + CAST(COUNT(TestID) AS NVARCHAR(5)),2)
		FROM [Test] 
		WHERE TestID = @TestID;

		SELECT @StartRow = UPPER(StartRow), @EndRow = UPPER(EndRow), @StartColumn = StartColumn,@EndColumn = EndColumn
		FROM PlateType PT
		JOIN TestType TT ON TT.PlateTypeID = PT.PlateTypeID
		JOIN Test T ON T.TestTypeID = TT.TestTypeID
		WHERE T.TestID = @TestID;

		SET @RowCounter=Ascii(@StartRow)
		WHILE @RowCounter<=Ascii(@EndRow)	BEGIN
			SET @ColumnCounter = @StartColumn;
			WHILE(@ColumnCounter <= @EndColumn) BEGIN							
				INSERT INTO @TempWellTable(WellID)
					VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))
				SET @ColumnCounter = @ColumnCounter +1;
			END
			SET @RowCounter=@RowCounter+1
		END

		DELETE TT 
		FROM @TempWellTable TT
		JOIN WellTYpePosition WTP ON WTP.PositionOnPlate = TT.WellID
		JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
		JOIN Test T ON T.TestTypeID = WTP.TestTypeID
		WHERE T.TestID = @TestID AND WT.WellTypeName = 'B'

		SELECT @TotalWellsPerPlate = Count(NR) 
		FROM @TempWellTable TT1

		SELECT @TotalNrSample = SUM(ISNULL(NrOfSamples,1))
		FROM [ROW] R
		JOIN Test T ON T.FileID = R.FileID
		WHERE T.TestID = @TestID;

		SELECT @PlatesRequired = CEILING (CAST(@TotalNrSample AS FLOAT) / CAST(@TotalWellsPerPlate AS FLOAT))
		
		SELECT @PlatesCreated = COUNT(PlateID)
		FROM Plate P 
		JOIN Test T ON T.TestID = P.TestID;

		--create plate and well if not created
		WHILE(@PlatesCreated < @PlatesRequired) BEGIN
			--Create Plate here
			INSERT INTO Plate (PlateName,TestID)
			VALUES(@Crop +'_' + @FileName + '_' + @SameTestCount + '_' +RIGHT('000'+CAST(@PlatesCreated +1 AS NVARCHAR),2) ,@TestID);
			SELECT @PlateID = @@IDENTITY;
			
			--Create well here	
			INSERT INTO Well(PlateID,WellTypeID,Position)
			SELECT @PlateID,@AssignedWellTypeID, WellID FROM @TempWellTable ORDER BY Nr
			SET @PlatesCreated = @PlatesCreated + 1
		END

		INSERT INTO @TVP_MaterialsWithNrOfSample(MaterialID, NrOfSample) 
		SELECT MaterialID,ISNULL(R.NrOfSamples,1)
		FROM Material M 
		JOIN [Row] R ON R.MaterialKey = M.MaterialKey
		JOIN Test T ON T.FileID = R.FileID
		WHERE T.TestID = @TestID
		ORDER BY R.RowNr;


		SELECT @TotalMaterial = COUNT(MaterialID)
		FROM @TVP_MaterialsWithNrOfSample;

		--this loop is used to insert ordered material(list) into temptable
		WHILE(@Count <= @TotalMaterial) BEGIN

			SELECT @NrOfSample = NrOfSample, @MaterialID = MaterialID FROM @TVP_MaterialsWithNrOfSample WHERE ID = @Count;
			SET @NrOfSampleCount = 0;
			WHILE(@NrOfSampleCount < @NrOfSample) BEGIN
				
				INSERT INTO @TVP_Material(MaterialID)
				Values(@MaterialID)

				SET @NrOfSampleCount = @NrOfSampleCount +1
			END
			SET @Count = @Count +1
		END

		--insert ordered well into temptable
		INSERT INTO @TVP_Well(MaterialID)
		SELECT T.WellID
		FROM 
		(
			SELECT W.*, CAST(RIGHT(Position,LEN(Position)-1) AS INT) AS Position1
			,LEFT(Position,1) as Position2
			FROM Well W
			JOIN Plate P ON P.PlateID = W.PlateID
			WHERE P.TestID = @TestID
		) T
		ORDER BY PlateID,Position2,Position1

		--get this temptable to merge into table testmaterialdeterminationwell
		INSERT INTO @MaterialWithWell(MaterialID,WellID)
		SELECT M.MaterialID, W.MaterialID FROM @TVP_Material M
		JOIN @TVP_Well W ON W.RowNr = M.RowNr

		SELECT @TotalMaterial = COUNT(*) FROM @TVP_Material
		--delete last empty well which can be shifted forward on position.
		DELETE TMDW
		FROM TestMaterialDeterminationWell TMDW
		WHERE TMDW.WellID IN (SELECT MaterialID FROM @TVP_Well WHERE RowNr > @TotalMaterial)

		--insert or update data 
		MERGE TestMaterialDeterminationWell T
		USING @MaterialWithWell S
		ON T.WellID = S.WellID
		WHEN NOT MATCHED THEN 
		INSERT (MaterialID,WellID)
		VALUES (S.MaterialID,S.WellID)
		WHEN MATCHED AND T.MaterialID <> S.MaterialID THEN
		UPDATE SET T.MaterialID = S.MaterialID;

		--update welltype to assigned well type which contains material
		UPDATE W
		SET W.WellTypeID = @AssignedWellTypeID
		FROM Well W 
		JOIN @MaterialWithWell MW ON MW.WellID = W.WellID
		WHERE W.WellTypeID != @AssignedWellTypeID

		
		--update welltype to emtpy well which do not contain any meterial
		UPDATE W
		SET W.WellTypeID = @EmptyWellTypeID
		FROM Well W 
		JOIN @TVP_Well TW ON TW.MaterialID = W.WellID
		WHERE TW.RowNr > @TotalMaterial AND W.WellTypeID != @EmptyWellTypeID

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH



END
GO




