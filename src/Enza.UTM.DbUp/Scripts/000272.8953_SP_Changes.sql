
/*
Author					Date				Description
KRIAHNA GAUTAM			2019-Apr-25			Change of query after implementation of new table TestTypeDetermination for marker of testtype s2s.			 

=================Example===============
EXEC PR_GetDeterminationsForExternalTests 'LT', 1, 62

*/
ALTER PROCEDURE [dbo].[PR_GetDeterminationsForExternalTests]
(
	@CropCode NVARCHAR(10),
	@TestTypeID INT
) AS BEGIN
	SET NOCOUNT ON;
	SELECT 
		D.DeterminationID,
		D.DeterminationName,
		D.DeterminationAlias,
		ColumnLabel = D.DeterminationName
	FROM Determination D	
	JOIN TestTypeDetermination TTD ON TTD.DeterminationID = D.DeterminationID
	WHERE D.CropCode = @CropCode 
	AND TTD.TestTypeID = @TestTypeID;

END

GO


/*
Authror					Date				Description
KRISHNA GAUTAM			2019-JAN-21			Get data of external test.
KRIAHNA GAUTAM			2019-MAR-27			Performance Optimization and code cleanup 

=================Example===============
EXEC PR_GetExternalTestDataForExport 5587,0
*/

ALTER PROCEDURE [dbo].[PR_GetExternalTestDataForExport]
(
	@TestID INT,
	@MarkAsExported BIT = 0
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @MarkerColumns NVARCHAR(MAX), @MarkerColumnIDs NVARCHAR(MAX), @Columns NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @Query NVARCHAR(MAX);
	DECLARE @TblMarkerColumns TABLE(ColumnID INT, ColumnLabel NVARCHAR(100));
	DECLARE @TblColumns TABLE(ColumnID INT, ColumnLabel NVARCHAR(100));
	DECLARE @FileID INT;

	SELECT @FileID = FileID 
	FROM Test WHERE TestID = @TestID;

	--Get Markers columns only
	INSERT INTO @TblMarkerColumns(ColumnID, ColumnLabel)
	SELECT DISTINCT
		TMD.DeterminationID,
		D.DeterminationName
	FROM TestMaterialDetermination TMD
	JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TMD.DeterminationID
	JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	WHERE TMD.TestID = @TestID;

	--Get columns of imported file
	INSERT INTO @TblColumns(ColumnID, ColumnLabel)
	SELECT 
		C.ColumnID,
		C.ColumLabel
	FROM [Column] C
	JOIN Test T ON T.FileID = C.FileID
	WHERE T.TestID = @TestID;

	--Get columns of markers
	SELECT 
		@MarkerColumnIDs  = COALESCE(@MarkerColumnIDs + ',', '') + QUOTENAME(ColumnID) + ' AS ' + QUOTENAME('D_' + CAST(ColumnID AS VARCHAR(10))),
		@MarkerColumns  = COALESCE(@MarkerColumns + ',', '') + QUOTENAME(ColumnID)
	FROM @TblMarkerColumns;

	--Get columns of test
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns;

	IF(ISNULL(@Columns,'') = '') BEGIN
		EXEC PR_ThrowError 'Didn''t find any data to export';
		RETURN;
	END

	IF(ISNULL(@MarkerColumns,'') = '') BEGIN
		EXEC PR_ThrowError 'Didn''t find any determinations to export';
		RETURN;
	END

	SET @Query = N'SELECT V1.*, '  + @MarkerColumnIDs + '  FROM
	(
		SELECT MaterialKey, ' + @Columns + N' 
		FROM 
		(
			SELECT MaterialKey,ColumnID,[Value] FROM dbo.VW_IX_Cell_Material
			WHERE FileID = @FileID
			AND ISNULL([Value],'''')<>'''' 

		) SRC
		PIVOT
		(
			Max([Value])
			FOR [ColumnID] IN (' + @Columns + N')
		) PV
	) V1
	LEFT JOIN 
	(
		SELECT *
		FROM 
		(
			SELECT
				M.MaterialKey,
				TR.DeterminationID,
				Result = TR.ObsValueChar	
			FROM Test T
			JOIN [Row] R ON R.FileID = T.FileID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN Plate P ON P.TestID = T.TestID
			JOIN Well W ON W.PlateID = P.PlateID
			--JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
			--JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
			--JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
			--JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
			JOIN TestResult TR ON TR.WellID = W.WellID
			WHERE T.TestID = @TestID		
		) SRC 
		PIVOT
		(
			MAX(Result)
			FOR [DeterminationID] IN (' + @MarkerColumns + N')
		) PV
	) V2 ON V2.MaterialKey = V1.MaterialKey
	--OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))
	';

	PRINT @Query;

	EXEC sp_executesql @Query, N'@TestID INT, @FileID INT', @TestID, @FileID;

	--get colums informations
	SELECT 
		ColumnID = CAST(C1.ColumnID AS VARCHAR(10)),
		C1.ColumnLabel
	FROM @TblColumns C1
	UNION ALL
	SELECT 
		CONCAT('D_', CAST(C2.ColumnID AS VARCHAR(10))),
		C2.ColumnLabel 
	FROM @TblMarkerColumns C2;

	--update test with today's date if it was marked as exported
	IF(@MarkAsExported = 1) BEGIN
		UPDATE Test SET StatusCode = 700 WHERE TestID = @TestID;
	END
END

GO