/*
Authror					Date				Description
KRISHNA GAUTAM			2019-JAN-21			Get data of external test.
KRIAHNA GAUTAM			2019-MAR-27			Performance Optimization and code cleanup 
KRIAHNA GAUTAM			2019-DEC-12			Change in export logic to send Numerical ID and Sample name.
KRIAHNA GAUTAM			2020-JAN-02			Change in export to solve issue of result not imported returned correctly.
KRIAHNA GAUTAM			2020-JUNE-30		#14023: Change logic to implement change request			

=================Example===============
EXEC PR_GetExternalTestDataForExport 6577,0
*/

ALTER PROCEDURE [dbo].[PR_GetExternalTestDataForExport]
(
	@TestID INT,
	@MarkAsExported BIT = 0,
	@TraitScore BIT = 0
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @MarkerColumns NVARCHAR(MAX), @MarkerColumnIDs NVARCHAR(MAX), @Columns NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @Query NVARCHAR(MAX);
	DECLARE @TblMarkerColumns TABLE(ColumnID NVARCHAR(MAX), ColumnLabel NVARCHAR(100), ColumnOrder INT);
	DECLARE @TblColumns TABLE(ColumnID NVARCHAR(MAX), ColumnLabel NVARCHAR(100), ColumnOrder INT);
	DECLARE @FileID INT, @CountryCode NVARCHAR(100), @CropCode NVARCHAR(10);

	SELECT @FileID = FileID ,@CountryCode = CountryCode
	FROM Test WHERE TestID = @TestID;

	SELECT @CropCode = CropCode FROM [File] WHERE FileID = @FileID;
	--Get Markers columns only
	IF(ISNULL(@TraitScore,0) = 0) BEGIN
		INSERT INTO @TblMarkerColumns(ColumnID, ColumnLabel)
		SELECT DISTINCT
			D.DeterminationID,
			DeterminationName = MAX(D.DeterminationName)
		FROM TestMaterialDetermination TMD
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		WHERE TMD.TestID = @TestID
		GROUP BY D.DeterminationID;
	END
	ELSE BEGIN
		INSERT INTO @TblMarkerColumns(ColumnID, ColumnLabel)
		SELECT DISTINCT
			D.DeterminationID,
			TraitName = ISNULL( Max(T.ColumnLabel), MAX(D.DeterminationName))
		FROM TestMaterialDetermination TMD
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TMD.DeterminationID
		LEFT JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
		LEFT JOIN Trait T ON T.TraitID = CT.TraitID AND CT.CropCode = @CropCode
		WHERE TMD.TestID = @TestID 
		GROUP BY D.DeterminationID
	END

	--Get columns of imported file
	INSERT INTO @TblColumns(ColumnID, ColumnLabel,ColumnOrder)
	SELECT 
		C.ColumnID,
		ColumLabel = CASE WHEN C.ColumLabel = 'GID' THEN 'Numerical ID' 
							WHEN C.ColumLabel = 'Plant Name' THEN 'Sample Name'
							ELSE ColumLabel 
					END,
		ColumnNr = CASE WHEN C.ColumLabel = 'GID' THEN 1 
						WHEN C.ColumLabel = 'Plant Name' THEN 2
						ELSE C.COlumnNr + 4
					END
	FROM [Column] C
	JOIN Test T ON T.FileID = C.FileID
	WHERE T.TestID = @TestID
	order by c.ColumnID;

	--Get columns of markers
	SELECT 
		@MarkerColumnIDs  = COALESCE(@MarkerColumnIDs + ',', '') + QUOTENAME(ColumnID) + ' AS ' + QUOTENAME('D_' + CAST(ColumnID AS VARCHAR(10))),
		@MarkerColumns  = COALESCE(@MarkerColumns + ',', '') + QUOTENAME(ColumnID)
	FROM @TblMarkerColumns
	ORDER BY ColumnLabel;

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


	IF(@TraitScore = 0)	BEGIN

		SET @Query = N'SELECT
			V1.Country, '+@Columns+' , '  + @MarkerColumnIDs + '  FROM
		(
			SELECT RowID, Country =  '''+@CountryCode+''' , ' + @Columns + N' 
			FROM 
			(
				SELECT RowID, ColumnID,[Value] FROM dbo.VW_IX_Cell_Material
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
					R.RowID,
					TR.DeterminationID,
					Result = TR.ObsValueChar	
				FROM Test T
				JOIN [Row] R ON R.FileID = T.FileID
				JOIN Material M ON M.MaterialKey = R.MaterialKey
				JOIN Plate P ON P.TestID = T.TestID
				JOIN Well W ON W.PlateID = P.PlateID	
				JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
				JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
				JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
				WHERE T.TestID = @TestID		
			) SRC 
			PIVOT
			(
				MAX(Result)
				FOR [DeterminationID] IN (' + @MarkerColumns + N')
			) PV
		) 
		V2 ON V2.RowID = V1.RowID
		ORDER BY V1.RowID
		';
	END
	ELSE BEGIN
		SET @Query = N'SELECT
			V1.Country, '+@Columns+' , '  + @MarkerColumnIDs + '  FROM
		(
			SELECT RowID, Country =  '''+@CountryCode+''' , ' + @Columns + N' 
			FROM 
			(
				SELECT RowID, ColumnID,[Value] FROM dbo.VW_IX_Cell_Material
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
					R.RowID,
					TR.DeterminationID,
					Result = ISNULL(TDR.TraitResChar, TR.ObsValueChar)
				FROM Test T
				JOIN [Row] R ON R.FileID = T.FileID
				JOIN Material M ON M.MaterialKey = R.MaterialKey
				JOIN Plate P ON P.TestID = T.TestID
				JOIN Well W ON W.PlateID = P.PlateID	
				JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID AND TMDW.MaterialID = M.MaterialID
				JOIN TestMaterialDetermination TMD ON TMD.MaterialID = TMDW.MaterialID AND TMD.TestID = T.TestID
				JOIN TestResult TR ON TR.DeterminationID = TMD.DeterminationID AND TR.WellID = W.WellID
				LEFT JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
				LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
				WHERE T.TestID = @TestID		
			) SRC 
			PIVOT
			(
				MAX(Result)
				FOR [DeterminationID] IN (' + @MarkerColumns + N')
			) PV
		) 
		V2 ON V2.RowID = V1.RowID
		ORDER BY V1.RowID
		';
	END

	

	PRINT @Query;

	EXEC sp_executesql @Query, N'@TestID INT, @FileID INT', @TestID, @FileID;


	
	--Insert country record
	INSERT INTO @TblColumns(ColumnID, ColumnLabel,ColumnOrder)
	VALUES
	('Country','Country',3);

	
	SELECT ColumnID,ColumnLabel FROM 
	(
		SELECT 
			ColumnID = CAST(C1.ColumnID AS VARCHAR(10)),
			C1.ColumnLabel,
			C1.ColumnOrder,
			1 as [order]
		FROM @TblColumns C1
		UNION ALL
		SELECT 
			CONCAT('D_', CAST(C2.ColumnID AS VARCHAR(10))),
			C2.ColumnLabel,
			C2.ColumnOrder,
			2 as [order]
		FROM @TblMarkerColumns C2
	) T order by [order], ColumnOrder

	--update test with today's date if it was marked as exported
	IF(@MarkAsExported = 1) BEGIN
		UPDATE Test SET StatusCode = 700 WHERE TestID = @TestID;
	END
END

