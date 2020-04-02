DROP PROCEDURE IF EXISTS [dbo].[PR_GetPunchList]
GO

/*
DECLARE @p1 INT, @p2 NVARCHAR(200), @p3 nvarchar(MAX);
EXEC PR_GetPunchList 4430, @p1 OUT, @p2 OUT, @p3 OUT;
PRINT @P1
PRINT @P2;
PRINT @p3
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

	DECLARE @TotalPlates INT, @Count INT = 0, @PlateID INT = 0,@TestType INT,@PlateName NVARCHAR(150),@FileID INT,@PlantNrColumnID NVARCHAR(MAX),@SQL NVARCHAR(MAX), @FileTitle NVARCHAR(MAX), @ExcludeControlPosition BIT;
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

	SELECT @TestType = TestTypeID,@Source = RequestingSystem,@ImportLevel = ImportLevel, @ExcludeControlPosition = ExcludeControlPosition
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
		SET @Columnlabel = 'Entry code';
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

		IF(@TestTypeID = 1 OR (ISNULL(@ExcludeControlPosition,0) = 1 AND @TestTypeID = 2))
		BEGIN
			INSERT INTO @Table(Position,PlateID,PlateName,MaterialKey,BgColor,FgColor)
			SELECT PositionOnPlate,@PlateID,@PlateName,'QC',WT.BGColor,FGColor
			FROM WellTypePosition WTP
			JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
			WHERE TestTypeID = @TestType;
		END

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


DROP PROCEDURE IF EXISTS [dbo].[PR_GetTestsLookup]
GO


-- =============================================  
-- Author:  Binod Gurung  
-- Create date: 12/14/2017  
-- Description: Get List of Test to fill combo box   
-- =============================================  
-- EXEC [PR_GetTestsLookup] 'ON', 'NLEN'  
CREATE PROCEDURE [dbo].[PR_GetTestsLookup]   
(  
    --@UserID nvarchar(100)  
    @CropCode NVARCHAR(10),  
    @BreedingStationCode NVARCHAR(10)  
)  
AS  
BEGIN  
  
    SET NOCOUNT ON;  
  
    DECLARE @TotalWells INT,@BlockedWells INT;  
    DECLARE @tbl1 TABLE(TestID INT, TotalFixed INT);
    DECLARE @tbl2 TABLE(TestID INT, ReplicatedCount INT);
    DECLARE @tbl3 TABLE(TestTypeID INT, Blocked INT);
    
  
    SELECT 
	   @TotalWells = ((CAST(ASCII(EndRow) AS INT) - CAST(ASCII(StartRow) AS INT) +1)  * (EndColumn  - StartColumn + 1))  
    FROM PlateType;

    INSERT INTO @tbl1(TestID, TotalFixed)
    SELECT 
	   T.TestID, 
	   COUNT(WT.WellTypeID) AS TotalFixed  
    FROM Well W  
    JOIN WellType WT ON WT.WellTypeID = W.WellTypeID  
    JOIN Plate P ON P.PlateID = W.PlateID  
    JOIN Test T ON T.TestID = P.TestID  
    JOIN [File] F ON F.FileID = T.FileID  
    WHERE WT.WellTypeName   = 'F' AND   
    --T.RequestingUser = @UserID  
    T.BreedingStationCode = @BreedingStationCode AND F.CropCode = @CropCode  
    GROUP BY T.TestID;

    INSERT INTO @tbl2(TestID, ReplicatedCount)
    SELECT 
	   T.TestID, 
	   COUNT(MaterialID) AS ReplicatedCount 
    FROM [File] F   
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
    HAVING COUNT(MaterialID) > 1;

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
	 MaterialReplicated = CAST((CASE WHEN ISNULL(T2.ReplicatedCount,1) = 1 THEN 0 ELSE 1 END) AS BIT),  
	 T.PlannedDate,  
	 T.Isolated,  
	 ST1.SlotID,  
	 WellsPerPlate = CASE WHEN (@TestTypeID = 1 OR (ISNULL(@ExcludeControlPosition,0) = 1 AND @TestTypeID = 2)) THEN  @TotalWells - ISNULL(T3.Blocked,0) ELSE @TotalWells END,  
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
	LEFT JOIN @tbl2 T2 ON T2.TestID = T.TestID  
	LEFT JOIN SlotTest ST1 ON ST1.TestID = T.TestID  
	LEFT JOIN Slot S1 ON S1.SlotID = ST1.SlotID  
	LEFT JOIN @tbl3 T3 ON T3.TestTypeID = T.TestTypeID  
	WHERE --T.RequestingUser = @UserID  
	F.CropCode = @CropCode AND T.BreedingStationCode = @BreedingStationCode  
	AND T.StatusCode <= 600  
	ORDER BY TestID DESC;   
END  
  
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_GetWellPositionsLookup]
GO

-- =============================================
-- Author:		Binod Gurung
-- Create date: 12/15/2017
-- Description:	Get List of Test with TestTypeCode 
--EXEC PR_GetWellPositionsLookup 4556
-- =============================================
CREATE PROCEDURE [dbo].[PR_GetWellPositionsLookup] 
	( @TestID int )
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @Total1 INT;
	DECLARE @TempWellTable TVP_TempWellTable;

	DECLARE @TempWellTable1 TVP_TempWellTable;
	DECLARE @StartRow VARCHAR(2);
	DECLARE @EndRow VARCHAR(2);
	DECLARE @StartColumn INT;
	DECLARE @EndColumn INT;
	DECLARE @RowCounter INT;
	DECLARE @ColumnCounter INT;
	DECLARE @ExcludeControlPosition BIT;

	--fetch plate position according to PlateType
	SELECT @StartRow = UPPER(StartRow), @EndRow = UPPER(EndRow), @StartColumn = StartColumn,@EndColumn = EndColumn,@ExcludeControlPosition = TS.ExcludeControlPosition
		FROM PlateType PT
		JOIN TestType TT ON PT.PlateTypeID = TT.PlateTypeID 
		JOIN Test TS ON TT.TestTypeID = TS.TestTypeID
		WHERE TS.TestID = @TestID;
  
	SET @RowCounter=Ascii(@StartRow)
	WHILE @RowCounter<=Ascii(@EndRow) BEGIN
	SET @ColumnCounter = @StartColumn;
	WHILE(@ColumnCounter <= @EndColumn) BEGIN       
		INSERT INTO @TempWellTable1(WellID)
		VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--+CAST(@ColumnCounter AS VARCHAR))
		SET @ColumnCounter = @ColumnCounter +1;
	END
	SET @RowCounter=@RowCounter+1
	END

	--Exclude Positions for Reserved
	IF(@TestTypeID = 1 OR (ISNULL(@ExcludeControlPosition,0) = 1 AND @TestTypeID = 2))
	BEGIN
		DELETE TWT FROM @TempWellTable1 TWT
		JOIN WellTypePosition WTP ON WTP.PositionOnPlate = TWT.WellID 
		JOIN WellType WT ON WTP.WellTypeID = WT.WellTypeID
		JOIN Test T ON T.TestTypeID = WTP.TestTypeID
		WHERE WT.WellTypeName = 'B' AND T.TestID = @TestID;
	END

	--Exclude Positions for Fixed Plant
	DELETE TWT FROM @TempWellTable1 TWT
	JOIN Well W On W.Position = TWT.WellID
	JOIN WellType WT ON WT.WellTypeID = W.WellTypeID
	JOIN Plate P On P.PlateID = W.PlateID
	WHERE WT.WellTypeName = 'F' AND P.TestID = @TestID;

	SELECT @Total1 = Count(NR) FROM @TempWellTable1;

	INSERT INTO @TempWellTable(WellID)
		SELECT WEllID FROM  @TempWellTable1;
	
	SELECT WEllID FROM  @TempWellTable;

END

GO



DROP PROCEDURE IF EXISTS [dbo].[PR_GetDataWithMarkers]
GO


/*
Authror					Date				Description
KRISHNA GAUTAM			2018-OCT-01			Get Material and with assigned Marker data
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 
KRISHNA GAUTAM			2019-Mar-28			Change on process of creating plate and well for only material assigned to marker for 2GB and selected material for other test which do not require marker.
KRISHNA GAUTAM			2019-JUN-06			update rearrangePlatefilling value on test table
DIBYA				   2020-Feb-07			Adjusted column names for external tests. 
										GID and Plant name is changed to Numerical ID and Sample name respectively.

=================Example===============
EXEC [PR_GetDataWithMarkers] 48, 1, 200, '[700] LIKE ''v%'''
EXEC [PR_GetDataWithMarkers] 45, 1, 200, ''
EXEC [PR_GetDataWithMarkers] 4556, 1, 1000, ''
*/
CREATE PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT,@Rearrange BIT=1;
	DECLARE @ExcludeControlPosition BIT=0;
	DECLARE @Source NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX), @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(50), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15),MateriallblColumn BIT);	
	DECLARE @FileName NVARCHAR(100) = '', @Crop NVARCHAR(10) = '',@StatusCode INT,@PlateNameToCreate NVARCHAR(MAX);
	DECLARE @FixedWellTypeID INT,@DeadWellTypeID INT,@AssignedWellTypeID INT, @EmptyWellTypeID INT;
	DECLARE @DeterminationRequired BIT,@PlatesCreated INT =0,@FixedWellCount INT,@PlateRequired INT =0,@WellsPerPlate INT;
	DECLARE @MaxWell INT, @PlateID INT, @PlateIDNew INT =0, @PlateTypeID INT;
	DECLARE @ImportLevel NVARCHAR(MAX);
	--DECLARE @MaxRowOfMaterial1 INT;

	DECLARE @Material TVP_Material,@Material1 TVP_Material, @Well TVP_Material, @Well1 TVP_Material, @MaterialWithWell TVP_TMDW, @MaterialToRemove TVP_TMDW, @MaterialToAdd TVP_Material, @MaterialAll TVP_TMDW, @DeadMaterial TVP_TMDW, @DeadWell_New TVP_Material;
	DECLARE @FixedMaterial TABLE (MaterialID INT, Position NVARCHAR(MAX));	
	DECLARE @PlateToDelete TABLE(PlateID INT)

	SELECT @FixedWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'F';
	SELECT @DeadWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'D';
	SELECT @AssignedWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'A';
	SELECT @EmptyWellTypeID = WellTypeID FROM WellType WHERE WellTypeName = 'E';

	SELECT @FileID = F.FileID, @FileName = T.TestName, @Crop = CropCode, @Source = T.RequestingSystem, @StatusCode = StatusCode, @Rearrange = ISNULL(T.RearrangePlateFilling,1),@ImportLevel = ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID

	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'File or test doesn''t exist.';
		RETURN;
	END

	SELECT @DeterminationRequired = DeterminationRequired, @PlateTypeID = TT.PlateTypeID, @ExcludeControlPosition = ExcludeControlPosition FROM TestType TT
	JOIN Test T ON T.TestTypeID = TT.TestTypeID AND T.TestID = @TestID;

	

	IF(ISNULL(@PlateTypeID,0)<>0 AND @Rearrange = 1) 
	BEGIN	
		BEGIN TRY
				
				BEGIN /*Remove material from Plate region*/					
					DELETE @MaterialAll;
					/*get all material that is currently present in platefilling*/					
					INSERT INTO @MaterialAll(MaterialID,WellID)
						SELECT TMDW.MaterialID,TMDW.WellID FROM TestMaterialDeterminationWell TMDW
						JOIN Well W ON W.WellID = TMDW.WellID
						JOIN Plate P ON P.PlateID = W.PlateID				
						WHERE P.TestID = @TestID
						ORDER BY W.WellID; 
					/*check material that needs to be removed from plate*/
					IF(@DeterminationRequired = 1) 
					BEGIN
						INSERT INTO @MaterialToRemove(MaterialID,WellID)
						SELECT MaterialID, WellID FROM @MaterialAll M
						WHERE NOT EXISTS (SELECT MaterialID FROM TestMaterialDetermination TMD WHERE TestID = @TestID AND TMD.MaterialID = M.MaterialID GROUP BY TMD.MaterialID)

					END
					ELSE
					BEGIN
						INSERT INTO @MaterialToRemove(MaterialID,WellID)
						SELECT M.MaterialID, WellID FROM @MaterialAll M
						JOIN 
						(SELECT MaterialID FROM [File] F
										JOIN [Test] T ON T.FileID = F.FileID
										JOIN [Row] R ON R.FileID = T.FileID
										JOIN Material M1 ON M1.MaterialKey = R.MaterialKey									
										WHERE T.TestID = @TestID AND ISNULL(R.Selected,0) = 0
						) T1 ON T1.MaterialID = M.MaterialID						

					END
				

					IF EXISTS (SELECT TOP 1 * FROM @MaterialToRemove) 
						BEGIN
						/*change well type to Empty well that needs to be removed */
							UPDATE W SET W.WellTypeID= @AssignedWellTypeID
							FROM Well W 
							JOIN  @MaterialToRemove M ON M.WellID = W.WellID
						/*
						--insert sequetial material that needs to be arranged on plate. 
						--This should only include material except dead material because if plate contains a dead material on well on last position it should be shifted later on this process
						--material inbetween will not have any impact on re-arrance because we will exclude the material that is inside that well.
						*/
						INSERT INTO @Material(MaterialID)
						SELECT M.MaterialID FROM @MaterialAll M
						JOIN Well W ON W.WellID = M.WellID
						WHERE  NOT EXISTS (SELECT MaterialID FROM @MaterialToRemove T1 WHERE T1.MaterialID = M.MaterialID)
						--AND W.WellTypeID <> @DeadWellTypeID
						AND W.WellTypeID NOT IN (@DeadWellTypeID, @FixedWellTypeID)
						ORDER BY W.WellID				
	
						--insert sequential Well that needs to be arranged on plate.
						INSERT INTO @Well(MaterialID)
						SELECT W.WellID FROM Plate P
						JOIN Well W ON W.PlateID = P.PlateID
						WHERE P.TestID = @TestID
						--AND W.WellTypeID <> @DeadWellTypeID
						AND W.WellTypeID NOT IN (@DeadWellTypeID, @FixedWellTypeID)
						ORDER BY W.WellID

						--now create a temp table that contains materialid and well id which needs to be updated on TestMaterialDeterminationWell
						INSERT INTO @MaterialWithWell(MaterialID,WellID)
						SELECT M.MaterialID,W.MaterialID FROM @Material M
						JOIN @Well W ON W.RowNr = M.RowNr
						ORDER BY M.RowNr;
		
						--get dead materials
						--SELECT @MaxRowOfMaterial = ISNULL(MAX(RowNr),0) FROM @Material;
						SELECT @MaxWell = ISNULL(MAX(WellID),0) FROM @MaterialWithWell

						--get dead material in a well that will be the on last position
						INSERT INTO @DeadMaterial(MaterialID,WellID)
						SELECT MaterialID, W.WellID FROM Plate P 
						JOIN Well W ON W.PlateID = P.PlateID
						JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
						WHERE W.WellTypeID = @DeadWellTypeID AND W.WellID > @MaxWell
						AND P.TestID = @TestID
						ORDER BY WellID;


						--insert dead material in last
						INSERT INTO @Material1(MaterialID)
						SELECT MaterialID FROM @DeadMaterial

						INSERT INTO @Well1
						SELECT W.WellID FROM Plate P
						JOIN Well W ON W.PlateID = P.PlateID
						WHERE P.TestID = @TestID
						AND W.WellID > @MaxWell
						ORDER BY W.WellID

						--insert dead material to match to last order to well and material
						INSERT INTO @MaterialWithWell(MaterialID,WellID)
						SELECT M.MaterialID, W.MaterialID FROM @Material1 M 
						JOIN @Well1 W ON M.RowNr = W.RowNr
				

						--update last well to dead
						UPDATE W SET W.WellTypeID = @DeadWellTypeID
						FROM Well W
						WHERE WellID IN (SELECT W1.MaterialID FROM @Well1 W1 JOIN @Material1 M ON M.RowNr = W1.RowNr);

						--now merge data accordingly.
						MERGE INTO TestMaterialDeterminationWell T
						USING @MaterialWithWell S 
						ON T.WellID = S.WellID
						WHEN MATCHED AND T.MaterialID <> S.MaterialID
						THEN UPDATE SET T.MaterialID = S.MaterialID;

						--update last well to empty well so it will be shown empty on punchlist and sample list
						SELECT @MaxWell = ISNULL(MAX(WellID),0) FROM @MaterialWithWell --need to fetch it again because some materials are added in between

						--update previous dead well to Empty so that we can remove it from TMDW table and will not appear on Platefilling screen.
						UPDATE W SET W.WellTypeID = @EmptyWellTypeID 
						FROM Well W JOIN @Well TW ON TW.MaterialID = W.WellID
						WHERE TW.MaterialID > @MaxWell AND W.WellTypeID NOT IN(@FixedWellTypeID,@DeadWellTypeID);

						--remove last material from TestMaterialDeterminationWell table 

					
						DELETE TMDW 
						FROM TestMaterialDeterminationWell TMDW 
						JOIN Well W ON W.WellID = TMDW.WellID
						JOIN Plate P ON P.PlateID = W.PlateID
						WHERE P.TestID = @TestID AND W.WellID > @MaxWell AND W.WellTypeID <> @FixedWellTypeID;
				
						/*plate and well should be removed if plate contains only fixed material and empty well,if plate is not requested on LIMS*/
						IF(@StatusCode < 200) BEGIN	
					
							select TOP 1 @WellsPerPlate = COUNT(W.WellID) FROM Plate P 
							JOIN Well W ON W.PlateID = P.PlateID
							where P.TestID = @TestID
							GROUP BY P.PlateID
									
							INSERT INTO @PlateToDelete(PlateID)
							SELECT PlateID FROM
							(
								SELECT T.PlateID,SUM([Count]) AS [Count] FROM 
								(
									SELECT P.PlateID,WellTypeID,Count(WelltypeID) AS [Count] FROM Well W
												JOIN Plate P ON P.PlateID = W.PlateID
												WHERE P.TestID = @TestID
												GROUP BY P.PlateID,W.WellTypeID
								)T WHERE T.WellTypeID IN (@EmptyWellTypeID,@FixedWellTypeID)
								GROUP BY PlateID
							)T1 WHERE [Count] = @WellsPerPlate

							--delete from TestMaterialDeterminationWell if material present
							DELETE TMDW FROM TestMaterialDeterminationWell TMDW
							JOIN Well W ON W.WellID = TMDW.WellID
							JOIN @PlateToDelete P on P.PlateID = W.PlateID;

							--delete from well if all well are empty or fixed position
							DELETE W FROM Well W
							JOIN @PlateToDelete P ON P.PlateID = W.PlateID
				
							--delete plate no well is found
							DELETE P FROM Plate P 
							JOIN @PlateToDelete PD ON Pd.PlateID = P.PlateID;
						END
						/*END plate and well should be removed if plate contains only fixed material and empty well,if plate is not requested on LIMS*/

					END

				END 
				/*Remove material from Plate region end*/
				BEGIN /*BEGIN - Add material to Plate region*/

					/*get all material that is currently present in platefilling*/
					DELETE @MaterialAll;					
					INSERT INTO @MaterialAll(MaterialID,WellID)
						SELECT TMDW.MaterialID,TMDW.WellID FROM TestMaterialDeterminationWell TMDW
						JOIN Well W ON W.WellID = TMDW.WellID
						JOIN Plate P ON P.PlateID = W.PlateID				
						WHERE P.TestID = @TestID
						ORDER BY W.WellID; 
					/*check material that needs to be Added on last position on plate*/
					DELETE @MaterialToAdd;
					IF(@DeterminationRequired = 1)
					BEGIN
						
						IF(@ImportLevel = 'LIST') 
						BEGIN
								;WITH CTE1 AS
								(
									SELECT 
										TMD.MaterialID,
										NrOfSamples = MAX(R.NrOfSamples),
										RowNr = MAX(R.RowNr)
									FROM TestMaterialDetermination TMD
									JOIN Test T ON T.TestID = TMD.TestID
									JOIN Material M ON M.MaterialID = TMD.MaterialID
									JOIN [Row] R ON R.MaterialKey = M.MaterialKey AND R.FileID = T.FileID
									WHERE TMD.TestID = @TestID
									AND	NOT EXISTS 
									(	
										SELECT MaterialID 
											FROM Plate P 
										JOIN Well W ON W.PlateID = P.PlateID
										JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND P.TestID = @TestID AND TMD.TestID = @TestID AND TMDW.MaterialID = TMD.MaterialID
									)
									GROUP BY TMD.MaterialID
									--ORDER BY MAX(R.RowNr)
								),
								CTE2 AS
								(
									SELECT CTE1.MaterialID,CTE1.RowNr, CTE1.NrOfSamples AS Sample1, 1 as Sample2  FROM CTE1
									UNION ALL
									SELECT MaterialID,RowNr, Sample1,Sample2  + 1 as SAmple3 FROM CTE2
									WHERE CTE2.Sample2 < CTE2.sample1
								)
								INSERT INTO @MaterialToAdd(MaterialID)
								SELECT MaterialID FROM CTE2 order by RowNr
								OPTION (MAXRECURSION  4000)
						END

						ELSE
						BEGIN
							INSERT INTO @MaterialToAdd(MaterialID)
							SELECT 
								TMD.MaterialID 
							FROM TestMaterialDetermination TMD
							JOIN Test T ON T.TestID = TMD.TestID
							JOIN Material M ON M.MaterialID = TMD.MaterialID
							JOIN [Row] R ON R.MaterialKey = M.MaterialKey AND R.FileID = T.FileID
							WHERE TMD.TestID = @TestID
							AND	NOT EXISTS 
							(	
								SELECT MaterialID 
									FROM Plate P 
								JOIN Well W ON W.PlateID = P.PlateID
								JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND P.TestID = @TestID AND TMD.TestID = @TestID AND TMDW.MaterialID = TMD.MaterialID
							)
							GROUP BY TMD.MaterialID
							ORDER BY MAX(R.RowNr);
						END
					END

					ELSE
					BEGIN
						IF(@ImportLevel = 'LIST') 
						BEGIN
							;WITH CTE1 AS
							(
								SELECT 
									M.MaterialID,
									R.NrOfSamples,
									R.RowNr
								FROM [Test] T
								JOIN [File] F ON F.FileID = T.FileID
								JOIN [Row] R ON R.FileID = F.FileID
								JOIN Material M ON M.MaterialKey = R.MaterialKey
								WHERE T.TestID = @TestID
								AND ISNULL(R.Selected,0)=1
								AND NOT EXISTS
								(
									SELECT 
										MaterialID 
									FROM Plate P 
									JOIN Well W ON W.PlateID = P.PlateID
									JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND P.TestID = @TestID AND TMDW.MaterialID = M.MaterialID
									GROUP BY TMDW.MaterialID
								)
								--ORDER BY R.RowNr
							),
							CTE2 AS
							(
								SELECT CTE1.MaterialID,CTE1.RowNr, CTE1.NrOfSamples AS Sample1, 1 as Sample2  FROM CTE1
								UNION ALL
								SELECT MaterialID,RowNr, Sample1,Sample2  + 1 as SAmple3 FROM CTE2
								WHERE CTE2.Sample2 < CTE2.sample1
							)
							INSERT INTO @MaterialToAdd(MaterialID)
							SELECT MaterialID FROM CTE2 order by RowNr
							OPTION (MAXRECURSION  4000)
						
						END

						ELSE
						BEGIN
							INSERT INTO @MaterialToAdd(MaterialID)
							SELECT 
								M.MaterialID 
							FROM [Test] T
							JOIN [File] F ON F.FileID = T.FileID
							JOIN [Row] R ON R.FileID = F.FileID
							JOIN Material M ON M.MaterialKey = R.MaterialKey
							WHERE T.TestID = @TestID
							AND ISNULL(R.Selected,0)=1
							AND NOT EXISTS
							(
								SELECT 
									MaterialID 
								FROM Plate P 
								JOIN Well W ON W.PlateID = P.PlateID
								JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND P.TestID = @TestID AND TMDW.MaterialID = M.MaterialID
								GROUP BY TMDW.MaterialID
							)
							ORDER BY R.RowNr;		
						END
							
					END
				

					/*Rearrage record on plate and well if needed */
					IF EXISTS(SELECT TOP 1 * FROM  @MaterialToAdd) 
					BEGIN

						--if there is some material that needs to be added and material is imported from list then call another stored procedure
						

							--IF(@ImportLevel = 'LIST') 
							--BEGIN
								
							
							--END
				
						SELECT @FixedWellCount = COUNT(WellTypeID)
						FROM Plate P 
						JOIN Well W ON P.PlateID = W.PlateID
						WHERE P.TestID = @TestID AND W.WellTypeID = @FixedWellTypeID
						GROUP BY W.WellTypeID

						SELECT @PlatesCreated = COUNT(PlateID)
						FROM Plate WHERE TestID = @TestID;
				
						/*Create plate and well if no record is created*/
						IF(ISNULL(@PlatesCreated,0)=0) 
						BEGIN

							DECLARE @TempWellTable TVP_TempWellTable;	
							DECLARE @StartRow VARCHAR(2), @EndRow VARCHAR(2), @StartColumn INT, @EndColumn INT, @RowCounter INT, @ColumnCounter INT;
							DECLARE @TotalWellsPerPlate INT, @Cx INT =0;

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
										VALUES(CHAR(@RowCounter)+RIGHT('00'+CAST(@ColumnCounter AS VARCHAR),2))--CAST(@ColumnCounter AS VARCHAR))
									SET @ColumnCounter = @ColumnCounter +1;
								END
								SET @RowCounter=@RowCounter+1
							END

							IF(@TestTypeID = 1 OR (ISNULL(@ExcludeControlPosition,0) = 1 AND @TestTypeID = 2))
							BEGIN
								DELETE TT 
								FROM @TempWellTable TT
								JOIN WellTYpePosition WTP ON WTP.PositionOnPlate = TT.WellID
								JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
								JOIN Test T ON T.TestTypeID = WTP.TestTypeID
								WHERE T.TestID = @TestID AND WT.WellTypeName = 'B'
							END

							SELECT @TotalWellsPerPlate = Count(NR) FROM @TempWellTable TT1;

							SELECT @Cx = COUNT(MaterialID) FROM @MaterialToAdd;

							SELECT @PlateRequired = CEILING (CAST(@Cx AS FLOAT) / CAST(@TotalWellsPerPlate AS FLOAT))

							/*create plate and well record */
							WHILE (@PlatesCreated < @PlateRequired) BEGIN
						
								INSERT INTO Plate (PlateName,TestID)
								VALUES(@Crop +'_' + @FileName + '_' +RIGHT('000'+CAST(@PlatesCreated +1 AS NVARCHAR),2) ,@TestID);
								SELECT @PlateIDNew = SCOPE_IDENTITY();
								INSERT INTO Well(WellTypeID,Position,PlateID)
								SELECT @AssignedWellTypeID, WellID, @PlateIDNew
								FROM @TempWellTable ORDER BY WellID;

								SET @PlatesCreated = @PlatesCreated + 1;
							END
							/*END - create plate and well record */
						END
						/*END - Create plate and well if no record is created*/

						/*Check if new plate is required or not, if required then create it if status code is less than 200*/
						ELSE 
						BEGIN
							--throw error and stops processing
							IF(@StatusCode >=200 AND (@PlatesCreated < @PlateRequired)) 
							BEGIN
								EXEC PR_ThrowError 'More plates are needed than requested plates from LIMS. Remove some markers to arrange materials on plate.';
								RETURN;
							END
							SELECT TOP 1 @PlateID = PlateID FROM Plate WHERE TestID = @TestID;
							SELECT @TotalWellsPerPlate = Count(WellID) FROM Well WHERE PlateID = @PlateID;
							SELECT @Cx = ISNULL(COUNT(MaterialID),0) FROM @MaterialAll;								
							SELECT @Cx = @Cx + ISNULL(COUNT(MaterialID),0) FROM @MaterialToAdd;					
							SET @Cx = @Cx - ISNULL(@FixedWellCount,0);
							SELECT @PlateRequired = CEILING (CAST(@Cx AS FLOAT) / CAST(@TotalWellsPerPlate AS FLOAT))

							IF(ISNULL(@FixedWellCount,0)>0) 
							BEGIN
								INSERT INTO @FixedMaterial(MaterialID,Position)
								SELECT TMDW.MaterialID,W.Position FROM TestMaterialDeterminationWell TMDW 
								JOIN Well W ON W.WellID = TMDW.WellID
								JOIN Plate P ON P.PlateID = W.PlateID
								WHERE P.PlateID = @PlateID AND W.WellTypeID = @FixedWellTypeID
							END

					

							/*Create required plates and wells */
							WHILE(@PlatesCreated < @PlateRequired) 
							BEGIN
						
								SELECT TOP 1 @PlateNameToCreate =LEFT(PlateName, LEN(PlateName) -2) + RIGHT('000' + CAST((CAST(RIGHT(PlateName,2) AS INT) +1) AS NVARCHAR(5)),2) FROM Plate
								WHERE TestID = @TestID
								ORDER BY PlateID DESC;
								--crate plate
								INSERT INTO Plate(PlateName,TestID)
									VALUES(@PlateNameToCreate,@TestID)
								SELECT @PlateIDNew = SCOPE_IDENTITY();
								--Create well
								INSERT INTO Well(WellTypeID,Position,PlateID)
									SELECT 
										CASE	WHEN WellTypeID = @FixedWellTypeID THEN @FixedWellTypeID 
												ELSE @AssignedWellTypeID END
										,Position, 
										@PlateIDNew 
									FROM Well
									WHERE PlateID = @PlateID 
									ORDER BY WellID
									--create testmaterialdetermination record for fixed material inside well 
									IF(ISNULL(@FixedWellCount,0)>0) BEGIN
										INSERT INTO TestMaterialDeterminationWell
										SELECT M.MaterialID,W.WellID FROM Well W
										JOIN @FixedMaterial M ON M.Position = W.Position
										WHERE W.PlateID = @PlateIDNew
									END
								SET @PlatesCreated = @PlatesCreated + 1;

							END
							/*END- Create required plates and wells */
						END
						/*END -Check if new plate is required or not, if required then create it if status code is less than 200*/


						/*Rearrange material here*/

						SELECT @MaxWell = MAX(M.WellID) FROM @MaterialAll M
						JOIN Well W ON W.WellID = M.WellID WHERE W.WellTypeID NOT IN( @FixedWellTypeID, @DeadWellTypeID);

						--delete from Tempwell
						DELETE FROM  @Well;
						--insert into tempwell
						INSERT INTO @Well(MaterialID)
						SELECT WellID FROM Well W 
						JOIN Plate P ON P.PlateID = W.PlateID
						WHERE P.TestID = @TestID 
						--AND NOT EXISTS (SELECT * FROM @MaterialAll M1 WHERE M1.WellID = W.WellID)
						AND W.WellTypeID <> @FixedWellTypeID
						AND W.WellID > ISNULL(@MaxWell,0)
						ORDER BY WellID;

						INSERT INTO @MaterialWithWell(MaterialID, WellID)
						SELECT M.MaterialID,W.MaterialID FROM @MaterialToAdd M 
						JOIN @Well W ON W.RowNr = M.RowNr
						ORDER BY W.RowNr;

						--SELECT * FROM @MaterialWithWell;

						--update well type to assigned well type
						UPDATE W SET W.WellTypeID = @AssignedWellTypeID
						FROM Well W JOIN @MaterialWithWell M ON M.WellID = W.WellID AND W.WellTypeID <> @AssignedWellTypeID;


						MERGE INTO TestMaterialDeterminationWell T
						USING @MaterialWithWell S 
						ON S.WellID = T.WellID
						WHEN NOT MATCHED THEN 
						INSERT (WellID,MaterialID)
						VALUES(S.WellID,S.MaterialID);
						/*update well to empty well for last if it is not set to empty well*/

						SELECT @MaxWell = MAX(M.WellID) FROM @MaterialWithWell M
						JOIN Well W ON W.WellID = M.WellID WHERE W.WellTypeID NOT IN( @FixedWellTypeID, @DeadWellTypeID);

						UPDATE W SET W.WellTypeID = @EmptyWellTypeID
						FROM Well W JOIN @Well W1 ON W1.MaterialID = W.WellID 				
						WHERE W1.RowNr > @MaxWell AND W.WellTypeID <> @FixedWellTypeID;
				
						/*END - Rearrange material here*/
					END

					/*END - Rearrage record on plate and well if needed */

				END
				/*END - Add material to Plate regin*/
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK;
			THROW;
		END CATCH
	END
	
	
	--Determination columns (for external we have to show all assigned markers, for other only linked trait should be shown.
	IF(ISNULL(@Source,'') <> 'External') 
	BEGIN
		INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
		SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnNR),0
		FROM
		(	
			SELECT DISTINCT 
				T1.DeterminationID,
				CONCAT('D_', T1.DeterminationID) AS TraitID,
				T4.ColumLabel,
				ColumnNR = MAX(T4.ColumnNR)
			FROM TestMaterialDetermination T1
			JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
			JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
			JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
			JOIN Trait T ON T.TraitID = CT.TraitID
			JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0
			WHERE T1.TestID = @TestID
			AND T4.FileID = @FileID
			GROUP BY T1.DeterminationID,T4.ColumLabel	
		) V1
		ORDER BY V1.ColumnNr;
	END
	ELSE BEGIN
	   INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, MateriallblColumn)
	   SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnLabel),0
	   FROM
	   (	
		  SELECT 
				T1.DeterminationID,
				CONCAT('D_', T1.DeterminationID) AS TraitID,
				T.ColumnLabel			
		  FROM TestMaterialDetermination T1
		  JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID
		  JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
		  JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
		  JOIN Trait T ON T.TraitID = CT.TraitID				
		  WHERE T1.TestID = @TestID			
		  GROUP BY T1.DeterminationID,T.ColumnLabel	
	   ) V1
	   ORDER BY V1.ColumnLabel;
	END
	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT Max(ColumnID), TraitID, ColumLabel, 2, (Max(ColumnNr) + @Total), Max(DataType)
	FROM [Column]	
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID;

	UPDATE T SET
	   ColumnLabel = CASE 
				    WHEN @Source = 'External' THEN
					   CASE ColumnLabel
						  WHEN 'GID' THEN 'Numerical ID'
						  WHEN 'Plant name' THEN 'Sample Name'
						  ELSE ColumnLabel
					   END
				    ELSE
					   ColumnLabel
				END
	FROM @TblColumns T;
	
	--get dynamic columns
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType <> 1
	ORDER BY [ColumnNr] ASC;

	SET @SQL = N';WITH CTE AS 
	(
		SELECT V1.MaterialID, V1.MaterialKey, V1.PlateID, V1.Plate, V1.WellID, V1.Well,
		V1.WellTypeID, V1.Fixed,
		' + @Columns3 + N'
		FROM 
		(
			SELECT
				MaterialID, 
				MaterialKey,
				PlateID, 
				Plate, 
				WellID,
				Well,				
				WellTypeID,
				Fixed = CAST((CASE WHEN (WellTypeID = @FixedWellTypeID OR WellTypeID = @DeadWellTypeID) THEN 1 ELSE 0 END) AS BIT)
			FROM dbo.VW_IX_TMDW_Mat_Well
			WHERE TestID = @TestID
			
		) V1
		JOIN 
		(
			--trait and property columns
			SELECT MaterialKey, ' + @Columns2 + N'  FROM 
			(
				SELECT MaterialKey,ColumnID,Value FROM dbo.VW_IX_Cell_Material
				WHERE FileID = @FileID
				AND ISNULL([Value],'''')<>'''' 
			) SRC
			PIVOT
			(
				Max([Value])
				FOR [ColumnID] IN (' + @ColumnID2s + N')
			) PV
		) V2 ON V2.MaterialKey = V1.MaterialKey ';	
		
		IF(ISNULL(@Columns, '') <> '') BEGIN
			SET @SQL = @SQL + N'
			LEFT JOIN 
			(
				--markers info
				SELECT MaterialID, MaterialKey, ' + @Columns  + N'
				FROM 
				(
					SELECT T2.MaterialID,T2.MaterialKey, T1.DeterminationID
					FROM [TestMaterialDetermination] T1
					JOIN Material T2 ON T2.MaterialID = T1.MaterialID
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					COUNT(DeterminationID)
					FOR [DeterminationID] IN (' + @ColumnIDs + N')
				) AS T
			) V3 ON V3.MaterialID  = V1.MaterialID ';
		END	
		
		SET @SQL = @SQL + N' WHERE  1 = 1 ';	

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @SQL = @SQL + ' AND ' + @Filter
		END

	SET @SQL = @SQL + N'
	), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
	SELECT CTE.MaterialID,CTE.WellTypeID, CTE.WellID, CTE.Fixed, CTE.Plate, CTE.Well, --[Replica] = CASE WHEN  ISNULL(CTE.ReplicaCount,0)> 0 THEN 1 ELSE 0 END, 
	' + @Columns3 + N', CTE_COUNT.TotalRows 
	FROM CTE, CTE_COUNT
	ORDER BY WellID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ));';
	
	SET @Offset = @PageSize * (@Page -1);
	
	EXEC sp_executesql @SQL , N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT, @FixedWellTypeID INT, @DeadWellTypeID INT', @FileID, @Offset, @PageSize, @TestID, @FixedWellTypeID, @DeadWellTypeID;

	--insert well and plate column
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	VALUES(999991,NULL,'Plate',3,1,'NVARCHAR(255)'),(999992,NULL,'Well',3,2,'NVARCHAR(255)')
	--get columns information
	SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
	Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel IN('GID', 'Numerical ID') 
				OR ColumnLabel = 'Plantnr' OR ColumnLabel IN ('Plant name', 'Sample Name') THEN 1 ELSE 0 END,
	MateriallblColumn = CASE WHEN (ColumnLabel = 'Plantnr' AND @Source = 'Breezys') 
					   OR (ColumnLabel IN('Plant name', 'Sample Name') AND @Source <> 'Breezys') THEN 1 ELSE 0 END
	FROM @TblColumns T1
	order by ColumnNr;

	--now update RearrangePlateFilling value of test
	UPDATE Test SET RearrangePlateFilling = 0 WHERE TestID = @TestID;
END

GO


