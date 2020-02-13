/*
Author					Date				Description
KRISHNA GAUTAM			   2018-NOv-24			Performance Optimization
KRIAHNA GAUTAM			   2019-Mar-27			Performance Optimization and code cleanup 
DIBYA				   2020-Feb-07			Adjusted column names for external tests. 
										GID and Plant name is changed to Numerical ID and Sample name respectively.

=================Example===============
EXEC PR_GET_Data 56,'KATHMANDU\dsuvedi', 1, 3, '[Lotnr]   LIKE  ''%9%''   and [Crop]   LIKE  ''%LT%'''
EXEC PR_GET_Data 6586, 1, 100, ''
*/
ALTER PROCEDURE [dbo].[PR_GET_Data]
(
	@TestID INT,
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
	DECLARE @Source VARCHAR(20);
	DECLARE @tblColumns TABLE(ColumnID INT, TraitID INT, Datatype VARCHAR(15), ColumnNr INT, ColumLabel NVARCHAR(200));	

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
	SELECT 
	   @FileID = FileID,
	   @Source = RequestingSystem
	FROM Test 
	WHERE TestID = @TestID;
	IF(ISNULL(@FileID, 0) = 0) BEGIN
		EXEC PR_ThrowError 'Invalid file or test.';
		RETURN;
	END
	
	INSERT @tblColumns(ColumnID, TraitID, DataType, ColumnNr, ColumLabel)
	SELECT 
	   ColumnID, 
	   TraitID, 
	   DataType, 
	   ColumnNr,
	   ColumLabel = CASE 
				    WHEN @Source = 'External' THEN
					   CASE ColumLabel
						  WHEN 'GID' THEN 'Numerical ID'
						  WHEN 'Plant name' THEN 'Sample Name'
						  ELSE ColumLabel
					   END
				    ELSE
					   ColumLabel
				END
	FROM [Column] 
	WHERE FileID = @FileID;
	
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') +'CAST('+ QUOTENAME(MAX(ColumnID)) +' AS '+ MAX(Datatype) +')' + ' AS ' + ISNULL(QUOTENAME(TraitID), QUOTENAME(ColumLabel)),
		@Columns2  = COALESCE(@Columns2 + ',', '') + ISNULL(QUOTENAME(TraitID), QUOTENAME(ColumLabel)),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @tblColumns
	GROUP BY ColumLabel,TraitID

	IF(ISNULL(@Columns, '') = '') BEGIN
		EXEC PR_ThrowError 'At lease 1 columns should be specified';
		RETURN;
	END

	SET @Query = N' ;WITH CTE AS 
	(
		SELECT R.RowID, R.MaterialKey, M.MaterialID, R.[RowNr], ' + @Columns2 + ' 
		FROM [ROW] R 
		JOIN Material M ON M.MaterialKey = R.MaterialKey
		LEFT JOIN 
		(
			SELECT PT.[RowID], ' + @Columns + ' 
			FROM
			(
				SELECT *
				FROM 
				(
					SELECT * FROM dbo.VW_IX_Cell
					WHERE FileID = @FileID
					AND ISNULL([Value],'''')<>'''' 
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnIDs + ')
				) PIV
			) AS PT 					
		) AS T1	ON R.[RowID] = T1.RowID  				
			WHERE R.FileID = @FileID ' + @FilterClause + '
	), Count_CTE AS (SELECT COUNT([RowID]) AS [TotalRows] FROM CTE) 					
	SELECT CTE.RowID, CTE.MaterialID, CTE.MaterialKey, '+ @Columns2 + ', Count_CTE.[TotalRows] FROM CTE, COUNT_CTE
	ORDER BY CTE.[RowNr]
	OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS
	FETCH NEXT ' + CAST (@PageSize AS NVARCHAR) + ' ROWS ONLY';
					
	
	EXEC sp_executesql @Query, N'@FileID INT', @FileID;	
	
	SELECT 
	   [TraitID], 
	   [ColumLabel] as ColumnLabel, 
	   DataType = MAX([DataType]),
	   ColumnNr = MAX([ColumnNr]),
	   CASE WHEN [TraitID] IS NULL THEN 0 ELSE 1 END AS IsTraitColumn,
	   Fixed = CASE WHEN [ColumLabel] = 'Crop' 
	   OR [ColumLabel] IN('GID', 'Numerical ID') OR [ColumLabel] = 'Plantnr' 
	   OR [ColumLabel] IN('Plant name', 'Sample Name') THEN 1 ELSE 0 END
	FROM @tblColumns 
	GROUP BY ColumLabel,TraitID
	ORDER BY ColumnNr;
END
GO

/*
Authror					Date				Description
KRISHNA GAUTAM			2018-OCT-01			Get Material and with assigned Marker data for external test.
KRIAHNA GAUTAM			2018-DEC-22			Performance Optimization
KRIAHNA GAUTAM			2019-Mar-27			Performance Optimization and code cleanup 
DIBYA				   2020-Feb-07			Adjusted column names for external tests. 
										GID and Plant name is changed to Numerical ID and Sample name respectively.
=================Example===============
	
*/
ALTER PROCEDURE [dbo].[PR_GetMaterialWithMarkerForExternalTest]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@Columns NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(20), ColumnLabel NVARCHAR(50), ColumnType INT, ColumnNr INT, DataType NVARCHAR(15));
	DECLARE @Source VARCHAR(20);

	SELECT 
	   @FileID = F.FileID,
	    @Source = RequestingSystem
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID 

	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumnLabel, 1, ROW_NUMBER() OVER(ORDER BY ColumnLabel)
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			MAX(T2.DeterminationName) AS ColumnLabel			
		FROM TestMaterialDetermination T1
		JOIN Determination T2 ON T2.DeterminationID = T1.DeterminationID		
		WHERE T1.TestID = @TestID		
		GROUP BY T1.DeterminationID
	) V1
	ORDER BY V1.ColumnLabel;

	--get total rows inserted 
	SELECT @Total = (@@ROWCOUNT + 1);	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 2, (MAX(ColumnNr) + @Total), MAX(DataType)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID;

	--update column label for external tests

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

	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(

					SELECT MaterialKey,RowNr,ColumnID,Value
					FROM VW_IX_Cell_Material
					WHERE FileID = @FileID
					AND ISNULL([Value],'''')<>'''' 

				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowNr, T1.MaterialKey, ' + @Columns3 + N'
			FROM 
			(
				SELECT MaterialKey, RowNr, ' + @Columns2 + N'  FROM 
				(
					SELECT MaterialKey,RowNr,ColumnID,Value
					FROM VW_IX_Cell_Material
					WHERE FileID = @FileID
					AND ISNULL([Value],'''')<>'''' 
				) SRC
				PIVOT
				(
					Max([Value])
					FOR [ColumnID] IN (' + @ColumnID2s + N')
				) PV
			) AS T1
			
			JOIN Material M ON M.MaterialKey = T1.MaterialKey

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
				) PV
				
			) AS T2			
			ON T2.MaterialID = M.MaterialID
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY
		OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ));';

		SET @Offset = @PageSize * (@Page -1);

		PRINT @QUERY;

		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;

		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel IN('GID', 'Numerical ID') 
		OR ColumnLabel = 'Plantnr' OR ColumnLabel IN ('Plant name', 'Sample Name') THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY ColumnNr;
END
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
EXEC [PR_GetDataWithMarkers1] 4260, 1, 1000, ''
*/
ALTER PROCEDURE [dbo].[PR_GetDataWithMarkers]
(
	@TestID			INT,
	@Page			INT,
	@PageSize		INT,
	@Filter			NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT, @FileID INT, @Total INT,@Rearrange BIT=1;
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

	SELECT @DeterminationRequired = DeterminationRequired, @PlateTypeID = TT.PlateTypeID FROM TestType TT
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

							DELETE TT 
							FROM @TempWellTable TT
							JOIN WellTYpePosition WTP ON WTP.PositionOnPlate = TT.WellID
							JOIN WellType WT ON WT.WellTypeID = WTP.WellTypeID
							JOIN Test T ON T.TestTypeID = WTP.TestTypeID
							WHERE T.TestID = @TestID AND WT.WellTypeName = 'B'

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