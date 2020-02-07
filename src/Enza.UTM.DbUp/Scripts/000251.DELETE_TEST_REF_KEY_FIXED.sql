DROP PROCEDURE IF EXISTS [dbo].[PR_Delete_Test]
GO

CREATE PROCEDURE [dbo].[PR_Delete_Test]
(
	@TestID INT,
	@Status INT OUT,
	@PlatePlanName NVARCHAR(MAX) OUT
)
AS BEGIN
	DECLARE @FileID INT;
	IF NOT EXISTS(SELECT TestID FROM Test WHERE TestID = @TestID) BEGIN
		EXEC PR_ThrowError 'Invalid test.';
		RETURN;
	END

	SELECT 
		@Status = ISNULL(StatusCode,0),
		@PlatePlanName = ISNULL(LabPlatePlanName,''),
		@FileID = ISNULL(FileID,0) 
	FROM Test WHERE TestID = @TestID;

	IF(@Status > 400) BEGIN
		EXEC PR_ThrowError 'Cannot delete test which is sent to LIMS.';
		RETURN;
	END
	
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DELETE I
		FROM CnTInfo I
		JOIN [Row] R ON R.RowID = I.RowID
		JOIN [File] F ON F.FileID = R.FileID
		JOIN Test T ON T.FileID = F.FileID
		WHERE T.TestID = @TestID;
		
		DELETE TMDW
		FROM TestMaterialDeterminationWell TMDW
		JOIN Well W ON W.WellID = TMDW.WellID
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE P.TestID = @TestID;

		--delete from well
		DELETE W
		FROM Well W 
		JOIN Plate P ON P.PlateID = W.PlateID
		WHERE P.TestID = @TestID;

		--delete from Plate
		DELETE Plate WHERE TestID = @TestID;

		--delete from slottest
		DELETE SlotTest WHERE TestID = @TestID;

		--delete from testmaterialdetermination
		DELETE TestMaterialDetermination WHERE TestID = @TestID;
		
		--delete Donor info for S2S 
		DELETE SD 
		FROM Test T 
		JOIN [Row] R ON R.FileID = T.FileID
		JOIN S2SDonorInfo SD ON SD.RowID = R.RowID
		WHERE T.TestID = @TestID;

		--delete marker score
		DELETE FROM S2SDonorMarkerScore WHERE TestID = @TestID;

		--delete test
		DELETE Test WHERE TestID = @TestID;

		--delete cell
		DELETE C FROM Cell C 
		JOIN Row R ON R.RowID = C.RowID
		WHERE R.FileID = @FileID;

		--delete column
		DELETE [Column] WHERE FileID = @FileID;

		--delete row
		DELETE [Row] WHERE FileID = @FileID;

		--delete file
		DELETE [File] WHERE FileID = @FileID;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH	
END
GO

ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
(
	@TestTypeID							INT,
	@TestID								INT,
	@Columns							NVARCHAR(MAX) = NULL,
	@Filter								NVARCHAR(MAX) = NULL,
	@TVPM TVP_TMD_WithScore				READONLY,	
	@Determinations TVP_Determinations	READONLY,
	@TVP_DonerInfo	TVP_DonerInfo		READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileName NVARCHAR(100);
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @CropCode	NVARCHAR(10),@TestType1 INT,@StatusCode INT;
	DECLARE @FileID		INT;


	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle,
			@CropCode = CropCode,
			@TestType1 = T.TestTypeID,
			@StatusCode = T.StatusCode
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID --AND F.UserID = @UserID;

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END
		IF(ISNULL(@CropCode,'')='')
		BEGIN
			EXEC PR_ThrowError 'Specified crop not found';
			RETURN;
		END
		--Prevent changing testType when user choose different type of test after creating test.
		IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestType1,0)) BEGIN
			EXEC PR_ThrowError 'Cannot assign different test type for already created test.';
			RETURN;
		END
		--Prevent asigning determination when status is changed to point of no return
		IF(ISNULL(@StatusCode,0) >=400) BEGIN
			EXEC PR_ThrowError 'Cannot assign determination for confirmed test.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM @Determinations) BEGIN		
		--PRINT 1;	
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForS2S @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
		--PRINT 2;
		--select * from @TVP_DonerInfo;
			EXEC PR_SaveTestMaterialDeterminationWithTVP_ForS2S @CropCode, @TestID, @TVPM, @TVP_DonerInfo
		END

		IF EXISTS(SELECT TestID FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
			EXEC PR_Update_TestStatus @TestID, 350;
		END
		SELECT TestID, StatusCode 
		FROM Test WHERE TestID = @TestID;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END
GO

/*
    EXEC [PR_CNT_GetDataWithMarker] 4569, 1, 150, ''
*/
ALTER PROCEDURE [dbo].[PR_CNT_GetDataWithMarker]
(
    @TestID INT,
    @Page INT,
    @PageSize INT,
    @Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Columns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX), @ColumnIDs4 NVARCHAR(MAX);
    DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
    DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(MAX), ColumnLabel NVARCHAR(MAX), ColumnType INT, ColumnNr INT, ColumnHeader NVARCHAR(MAX));

    SELECT 
    @FileID = F.FileID,
    @ImportLevel = T.ImportLevel
    FROM [File] F
    JOIN Test T ON T.FileID = F.FileID 
    WHERE T.TestID = @TestID;

    --Determination columns
    INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
    SELECT DeterminationID, TraitID, ColumLabel, 1, ROW_NUMBER() OVER(ORDER BY DeterminationID)
    FROM
    (	
	   SELECT 
		  T1.DeterminationID,
		  CONCAT('D_', T1.DeterminationID) AS TraitID,
		  T4.ColumLabel AS ColumLabel
	   FROM TestMaterialDetermination T1
	   JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
	   JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
	   JOIN Trait T ON T.TraitID = CT.TraitID
	   JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
	   WHERE T1.TestID = @TestID
	   AND T4.FileID = @FileID			
	   GROUP BY T1.DeterminationID, T4.ColumLabel	
    ) V1;

    --Trait and Property columns
    INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
    SELECT ColumnID, TraitID, ColumLabel, 2, ROW_NUMBER() OVER(ORDER BY ColumnID)
    FROM
    (
	   SELECT 
		  ColumnID = MAX(ColumnID), 
		  TraitID, 
		  ColumLabel
	   FROM [Column]
	   WHERE FileID = @FileID
	   GROUP BY ColumLabel, TraitID
    ) V2;
	
    --get Get Determination Column
    SELECT 
	   @Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
	   @ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID)),
	   @ColumnIDs4  = COALESCE(@ColumnIDs4 + ',', '') + QUOTENAME(TraitID)
    FROM @TblColumns
    WHERE ColumnType = 1
    GROUP BY TraitID;

    SELECT 
	   @Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID, ColumnLabel))),
	   @ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
    FROM @TblColumns
    WHERE ColumnType = 2;

    SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
    FROM @TblColumns
    WHERE ColumnType <> 1
    ORDER BY [ColumnNr] ASC;

    IF(ISNULL(@ColumnIDs4, '') <> '') BEGIN
	   SET @Columns3 = @Columns3 + ', ' + @ColumnIDs4
    END

    --If there are no any determination assigned
    IF(ISNULL(@Columns, '') = '') BEGIN		
	   SET @Query = N';WITH CTE AS
	   (
		  SELECT 
			 M.MaterialID, 
			 T1.RowID, 
			 T1.RowNr, 
			 T1.Selected, 
			 M.MaterialKey,
			 D.DonorNumber,
			 D.ProcessID,
			 D.LabLocationID,
			 D.StartMaterialID,
			 D.TypeID,
			 D.Requested,
			 D.Transplant,
			 D.Net,
			 D.RequestedDate,
			 D.DH1ReturnDate,
			 D.Remarks,
			 ' + @Columns3 + N'
		  FROM 
		  (
			 SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
			 (
				    SELECT RowID, RowNr, MaterialKey, ColumnID, Selected, Value
				    FROM VW_IX_Cell_Material
				    WHERE FileID = @FileID
				    AND ISNULL([Value],'''') <> '''' 
			 ) SRC
			 PIVOT
			 (
				    Max([Value])
				    FOR [ColumnID] IN (' + @ColumnID2s + N')
			 ) PV
		  ) AS T1
		  JOIN Material M ON M.MaterialKey = T1.MaterialKey
		  LEFT JOIN CnTInfo D ON D.RowID = T1.RowID ';
    END
    ELSE BEGIN
	   SET @Query = N';WITH CTE AS
	   (
		  SELECT 
			 M.MaterialID, 
			 T1.RowID, 
			 T1.RowNr, 
			 T1.Selected, 
			 M.MaterialKey, 
			 D.DonorNumber,
			 D.ProcessID,
			 D.LabLocationID,
			 D.StartMaterialID,
			 D.TypeID,
			 D.Requested,
			 D.Transplant,
			 D.Net,
			 D.RequestedDate,
			 D.DH1ReturnDate,
			 D.Remarks, 
			 ' + @Columns3 + N'
		  FROM 
		  (
			 SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
			 (
					
				    SELECT RowID, MaterialKey,RowNr,ColumnID,Selected,Value
				    FROM VW_IX_Cell_Material
				    WHERE FileID = @FileID
				    AND ISNULL([Value],'''') <> '''' 

			 ) SRC
			 PIVOT
			 (
				    Max([Value])
				    FOR [ColumnID] IN (' + @ColumnID2s + N')
			 ) PV
		  ) AS T1
		  LEFT JOIN CnTInfo D ON D.RowID = T1.RowID
		  JOIN Material M ON M.MaterialKey = T1.MaterialKey
		  LEFT JOIN 
		  (
			 /*Marker info*/
			 SELECT MaterialID, ' + @Columns  + N'
			 FROM 
			 (
				    SELECT T1.MaterialID, T1.DeterminationID
				    FROM TestMaterialDetermination T1
				    WHERE T1.TestID = @TestID
			 ) SRC 
			 PIVOT
			 (
				    COUNT(DeterminationID)
				    FOR [DeterminationID] IN (' + @ColumnIDs + N')
			 ) PV
				
		  ) AS T2	
		  ON T2.MaterialID = M.MaterialID ';
    END

    IF(ISNULL(@Filter, '') <> '') BEGIN
	   SET @Query = @Query + ' WHERE ' + @Filter
    END

    SET @Query = @Query + N'
    ), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
    SELECT 
	   RowID,
	   MaterialID, 
	   MaterialKey, 
	   D_Selected = Selected, 
	   DonorNumber,
	   ProcessID,
	   LabLocationID,
	   StartMaterialID,
	   TypeID,
	   Requested,
	   Transplant,
	   Net,
	   RequestedDate = FORMAT(RequestedDate, ''dd/MM/yyyy''),
	   DH1ReturnDate = FORMAT(DH1ReturnDate, ''dd/MM/yyyy''),
	   Remarks, 
	   ' + @Columns3 + N', 
	   CTE_COUNT.TotalRows 
    FROM CTE, CTE_COUNT
    ORDER BY RowNr
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
    OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))';

    SET @Offset = @PageSize * (@Page -1);
    EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

    --insert other columns
    INSERT INTO @TblColumns(ColumnLabel, ColumnType, ColumnNr, ColumnHeader)
    VALUES   
    ('DonorNumber', 4, 3, 'Donor Number'),
    ('ProcessID', 4, 4, 'Process'),
    ('LabLocationID', 4, 5, 'LAB Location'),
    ('StartMaterialID', 4, 6, 'Start Material'),
    ('TypeID', 4, 7, 'Type'),
    ('Transplant', 4, 8, 'Transplant'),
    ('Requested', 4, 9, 'Requested'),
    ('Net', 4, 10, 'Net'),
    ('RequestedDate', 4, 11, 'Requested Date'),    
    ('DH1ReturnDate', 4, 12, 'DH1 Return Date'),
    ('Remarks', 4, 13, 'Remarks');

    INSERT INTO @TblColumns(TraitID, ColumnLabel, ColumnType, ColumnNr, ColumnHeader)
    VALUES('D_Selected', 'Selected', 5, 2, 'Selected');
    
    --Adjust column ordering in grid
    UPDATE @TblColumns SET ColumnNr = 0, ColumnType = 5 WHERE ColumnLabel = 'GID'
    UPDATE @TblColumns SET ColumnNr = 1, ColumnType = 5 WHERE ColumnLabel = 'Plant name';
    UPDATE @TblColumns SET ColumnType = 3 WHERE ColumnType = 1;
		
    SELECT 
	   TraitID, 
	   ColumnLabel, 
	   ColumnHeader = ISNULL(ColumnHeader, ColumnLabel),
	   ColumnType, 
	   ColumnNr = ROW_NUMBER() OVER(ORDER BY ColumnType DESC, ColumnNr),
	   Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
    FROM @TblColumns T1
    ORDER BY ColumnType DESC, ColumnNr;	
END
GO