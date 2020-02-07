IF COL_LENGTH('S2SDonorInfo', 'ProjectCode') IS NULL
BEGIN
    ALTER TABLE S2SDonorInfo
	ADD ProjectCode NVARCHAR(20)
END

GO

DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_UpdateDonorNumber]
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
GO

DROP PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForS2S]
GO

DROP TYPE IF EXISTS [dbo].[TVP_DonerInfo]
GO

CREATE TYPE [dbo].[TVP_DonerInfo] AS TABLE(
	[MaterialID] [int] NULL,
	[DH0net] [int] NULL,
	[Requested] [int] NULL,
	[ToBeSown] [int] NULL,
	[Transplant] [int] NULL,
	[DonorNumber] [nvarchar](50) NULL,
	[ProjectCode] [nvarchar](50) NULL
)
GO

CREATE PROCEDURE [dbo].[PR_S2S_UpdateDonorNumber]
(
	@TVP_DonerInfo TVP_DonerInfo READONLY,
	@TestID INT
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileID INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT @FileID  = FileID FROM Test WHERE TestID = @TestID;

		--Update DonorNumber
		MERGE INTO S2SDonorInfo T
		USING
		(
			SELECT R.RowID, TVP1.DonorNumber FROM @TVP_DonerInfo TVP1
			JOIN Material M ON M.MaterialID = TVP1.MaterialID
			JOIN [Row] R ON R.MaterialKey = M.MaterialKey
			WHERE R.FileID = @FileID
		) S
		ON T.RowID = S.RowID
		WHEN MATCHED THEN
			UPDATE
			SET T.DonorNumber = S.DonorNumber;

		--Update Test status
		UPDATE Test
			SET StatusCode = 700
		WHERE TestID = @TestID

	COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
GO


CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForS2S]
(	
	@CropCode		NVARCHAR(15),
	@TestID			INT,	
	@TVPM TVP_TMD_WithScore	READONLY,
	@TVP_DonerInfo	TVP_DonerInfo	READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));

	INSERT INTO @Tbl (MaterialID, MaterialKey)
	SELECT M.MaterialID, M.MaterialKey
	FROM Material M
	JOIN
	(
		SELECT DISTINCT MaterialID 
		FROM @TVPM 
		--WHERE Selected = 1
	) M2 ON M2.MaterialID = M.MaterialID;

	--insert or delete statement for merge
	MERGE INTO S2SDonorMarkerScore T 
	USING 
	(
		SELECT T2.MaterialID,T1.DeterminationID,T1.Selected,T1.Score FROM @TVPM T1
		LEFT JOIN @Tbl T2 ON T1.MaterialID = T2.MaterialID			
	) S
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.Score,'') != ISNULL(S.Score,'')
		THEN UPDATE SET T.Score = S.Score
		--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,Score) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.Score);

	--merge donerinfo table
	MERGE INTO S2SDonorInfo T 
	USING 
	(
		SELECT R.RowID,D.DH0Net,D.Requested,D.Transplant,D.ToBeSown, D.ProjectCode FROM Test T
		JOIN [File] F ON F.FileID = T.FileID
		JOIN [Row] R ON R.FileID = F.FileID
		JOIN Material M ON M.MaterialKey = R.MaterialKey
		JOIN @TVP_DonerInfo D ON D.MaterialID = M.MaterialID
		WHERE T.TestID = @TestID
	) S
	ON T.RowID = S.RowID
	WHEN MATCHED
	THEN UPDATE SET T.DH0Net = ISNULL(S.DH0Net,T.DH0Net), T.Requested = ISNULL(S.Requested,T.Requested), T.Transplant = ISNULL(S.Transplant,T.Transplant), T.ToBeSown = ISNULL(S.ToBeSown,T.ToBeSown), T.ProjectCode = ISNULL(S.ProjectCode,T.ProjectCode); 
		
END

GO


CREATE PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForS2S]
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
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForS2S @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
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

DROP PROCEDURE IF EXISTS [dbo].[PR_GetMaterialWithMarker_ForS2s]
GO

/*

Author					Date				Description
KRISHNA GAUTAM			2019-MAY-03			Get Material and with assigned Marker data.
KRISHNA GAUTAM			2019-MAY-08			Marker and determinations is fetched from New table created for S2S which is S2SDonorMarkerScore

=================Example===============
EXEC PR_GetMaterialWithMarker_ForS2s 4336,1, 150, ''

*/
CREATE PROCEDURE [dbo].[PR_GetMaterialWithMarker_ForS2s]
(
	@TestID INT,
	@Page INT,
	@PageSize INT,
	@Filter NVARCHAR(MAX) = NULL
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Columns NVARCHAR(MAX),@ColumnIDs NVARCHAR(MAX), @Columns2 NVARCHAR(MAX), @ColumnID2s NVARCHAR(MAX), @Columns3 NVARCHAR(MAX),@Columns4 NVARCHAR(MAX), @ColumnIDS4 NVARCHAR(MAX);
	DECLARE @Offset INT, @Total INT, @FileID INT,@ReturnValue INT, @Query NVARCHAR(MAX),@ImportLevel NVARCHAR(MAX);	
	DECLARE @TblColumns TABLE(ColumnID INT, TraitID VARCHAR(MAX), ColumnLabel NVARCHAR(MAX), ColumnType INT, ColumnNr INT, DataType NVARCHAR(MAX));


	SELECT @FileID = F.FileID,@ImportLevel = T.ImportLevel
	FROM [File] F
	JOIN Test T ON T.FileID = F.FileID 
	WHERE T.TestID = @TestID;


	--Determination columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 1, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT) * 2) - 1
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('D_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
		FROM S2SDonorMarkerScore T1
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

	--Get Score Columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr)
	SELECT DeterminationID, TraitID, ColumLabel, 10, (CAST(ROW_NUMBER() OVER(ORDER BY ColumnNR) AS INT)) * 2
	FROM
	(	
		SELECT 
			T1.DeterminationID,
			CONCAT('score_', T1.DeterminationID) AS TraitID,
			T4.ColumLabel AS ColumLabel,
			MAX(T4.ColumnNR) AS ColumnNR
		FROM S2SDonorMarkerScore T1
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


	--get total rows inserted 
	--SELECT @Total = (@@ROWCOUNT + 1);
	SELECT @Total = 0;

	

	--Trait and Property columns
	INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
	SELECT MAX(ColumnID), TraitID, ColumLabel, 2, (MAX(ColumnNr) + @Total), MAX(DataType)
	FROM [Column]
	WHERE FileID = @FileID
	GROUP BY ColumLabel,TraitID
	
	--get Get Determination Column
	SELECT 
		@Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 1
	GROUP BY TraitID;

	--get score column
	SELECT 
		@Columns4  = COALESCE(@Columns4 + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
		@ColumnIDs4  = COALESCE(@ColumnIDs4 + ',', '') + QUOTENAME(MAX(ColumnID))
	FROM @TblColumns
	WHERE ColumnType = 10
	GROUP BY TraitID;

	SELECT 
		@Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID,ColumnLabel))),
		@ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
	FROM @TblColumns
	WHERE ColumnType = 2
	--ORDER BY [ColumnNr] ASC;

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(MAX(TraitID), MAX(ColumnLabel)))
	FROM @TblColumns
	WHERE ColumnType IN (1,10)
	GROUP BY TraitID

	SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
	FROM @TblColumns
	WHERE ColumnType NOT IN (1,10)
	ORDER BY [ColumnNr] ASC;


	IF(ISNULL(@Columns,'') = '') BEGIN
		
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowID, T1.RowNr, T1.Selected, M.MaterialKey,D.ProjectCode,D.DH0Net,D.Requested,D.Transplant,D.ToBeSown, ' + @Columns3 + N'
			FROM 
			(
				SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
				(
					SELECT RowID, MaterialKey,RowNr,ColumnID,Selected,Value
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
			LEFT JOIN S2SDonorInfo D ON D.RowID = T1.RowID
			'
	END
	ELSE BEGIN
		SET @Query = N';WITH CTE AS
		(
			SELECT M.MaterialID, T1.RowID, T1.RowNr, T1.Selected, M.MaterialKey, D.ProjectCode, D.DH0Net,D.Requested,D.Transplant,D.ToBeSown, ' + @Columns3 + N'
			FROM 
			(
				SELECT RowID, MaterialKey, RowNr, Selected, ' + @Columns2 + N'  FROM 
				(
					
					SELECT RowID, MaterialKey,RowNr,ColumnID,Selected,Value
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
			LEFT JOIN S2SDonorInfo D ON D.RowID = T1.RowID
			JOIN Material M ON M.MaterialKey = T1.MaterialKey
			LEFT JOIN 
			(
				--markers info
				SELECT MaterialID, ' + @Columns  + N'
				FROM 
				(
					SELECT T1.MaterialID, T1.DeterminationID
					FROM [S2SDonorMarkerScore] T1
					WHERE T1.TestID = @TestID
				) SRC 
				PIVOT
				(
					COUNT(DeterminationID)
					FOR [DeterminationID] IN (' + @ColumnIDs + N')
				) PV
				
			) AS T2	
			ON T2.MaterialID = M.MaterialID
			
			LEFT JOIN 
			(
				--Score Info
				SELECT MaterialID, ' + @Columns4  + N'
				FROM 
				(
					SELECT T1.MaterialID,T1.DeterminationID,Score
					FROM [S2SDonorMarkerScore] T1
					WHERE T1.TestID = @TestID AND ISNULL(T1.RelationDonorID,0) = 0
				) SRC 
				PIVOT
				(
					MAX(Score)
					FOR [DeterminationID] IN (' + @ColumnIDs4 + N')
				) PV
				
			) AS T3				
			ON T3.MaterialID = T2.MaterialID
			WHERE 1= 1';
		END

		IF(ISNULL(@Filter, '') <> '') BEGIN
			SET @Query = @Query + ' AND ' + @Filter
		END

		SET @Query = @Query + N'
		), CTE_COUNT AS (SELECT COUNT([MaterialID]) AS [TotalRows] FROM CTE)
	
		SELECT MaterialID, MaterialKey, D_Selected = Selected, ProjectCode, DH0Net, Requested, Transplant, ToBeSown, ' + @Columns3 + N', CTE_COUNT.TotalRows 
		FROM CTE, CTE_COUNT
		ORDER BY RowNr
		OFFSET @Offset ROWS
		FETCH NEXT @PageSize ROWS ONLY
		OPTION (USE HINT ( ''FORCE_LEGACY_CARDINALITY_ESTIMATION'' ))';

		SET @Offset = @PageSize * (@Page -1);

		PRINT @Query;
		
		EXEC sp_executesql @Query,N'@FileID INT, @Offset INT, @PageSize INT, @TestID INT', @FileID, @Offset, @PageSize, @TestID;


		update @TblColumns set ColumnType = 1 where ColumnType = 10;
		update @TblColumns SET ColumnNr = ColumnNr + 5 WHERE ColumnLabel NOT IN ('GID', 'Plant name')
		update @TblColumns SET ColumnNr = 0 WHERE ColumnLabel = 'GID'
		update @TblColumns SET ColumnNr = 1 WHERE ColumnLabel = 'Plant name';

		--insert other columns
		--DH0Net, Requested, Transplant, ToBeSown		
		INSERT INTO @TblColumns(ColumnLabel, ColumnType, DataType, ColumnNr)
		VALUES('DH0Net', 2, 'INT', 4),('Requested', 2, 'INT', 5),('Transplant', 2, 'INT', 6),('ToBeSown', 2, 'INT', 7);

		INSERT INTO @TblColumns(Traitid,ColumnLabel, ColumnType, DataType, ColumnNr)
		VALUES('D_Selected','Selected',2,'BIT',3);

		--ProjectCode
		INSERT INTO @TblColumns(Traitid,ColumnLabel, ColumnType, DataType, ColumnNr)
		VALUES('ProjectCode','ProjectCode',2,'NVARCHAR(20)',2);
		
		SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
		Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
		FROM @TblColumns T1
		ORDER BY Columntype,ColumnNr;

		
END
GO



