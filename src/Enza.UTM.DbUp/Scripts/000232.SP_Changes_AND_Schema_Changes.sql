DROP TABLE IF EXISTS [RelationDonorDH0]
GO

CREATE TABLE [dbo].[RelationDonorDH0](
	[RelationDonorID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[MaterialID] [int] NULL,
	[CropCode] [nvarchar](10) NULL,
	[ProposedName] [nvarchar](100) NULL,
	[GID] [int] NULL,
	[DH1ProposedName] [nvarchar](100) NULL,
	[DH1GID] [int],
	[StatusCode] [int] NULL,
	[TestID] [int] NULL
)

GO

DROP INDEX IF EXISTS IX_DH1ProposedName ON RelationDonorDH0
GO

CREATE INDEX IX_DH1ProposedName 
ON RelationDonorDH0(DH1ProposedName)
GO

DROP INDEX IF EXISTS IX_ProposedName ON RelationDonorDH0
GO

CREATE INDEX IX_ProposedName
ON RelationDonorDH0(ProposedName)
GO


IF COL_LENGTH('S2SDonorInfo', 'DonorName') IS NULL
BEGIN
    ALTER TABLE S2SDonorInfo
	ADD DonorName NVARCHAR(100)
END

GO

UPDATE DI SET DI.[DonorName] =T.[Value] FROM S2SDonorInfo DI
JOIN 
(
	SELECT C.rowID,C.[Value] from S2SDonorInfo DI
	JOIN Cell C ON C.RowID = DI.RowID
	JOIN [Column] C1 ON C1.ColumnID = C.ColumnID
	WHERE C1.ColumLabel = 'Name'
	GROUP BY C.RowID,C.[Value]
) T ON T.RowID = Di.RowID

GO

DROP TABLE IF EXISTs [dbo].[DHSyncConfig]
GO


CREATE TABLE [dbo].[DHSyncConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DH0GermplasmSetID] [int] NULL,
	[ResearchGroupID] [int] NULL,
	[CropCode] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'
    [
	    {
		    "TestID": 4463,
		    "MaterialID": 10295,
		    "DH0List": [
			    {
				    "ProposedName": "P1",
				    "Markers": [
					    {
						    "MarkerNumber": 695,
						    "Score": "0101"
					    },
					    {
						    "MarkerNumber": 740,
						    "Score": "0201"
					    }
				    ]
			    },
			    {
				    "ProposedName": "P2",
				    "Markers": [
					    {
						    "MarkerNumber": 88221,
						    "Score": "0102"
					    },
					    {
						    "MarkerNumber": 88222,
						    "Score": "0202"
					    }
				    ]
			    }
		    ]
	    }
    ]';
    EXEC PR_S2S_StoreDH0Details @DataAsJson;
*/
ALTER PROCEDURE [dbo].[PR_S2S_StoreDH0Details]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @IDs NVARCHAR(MAX);
    DECLARE @Tbl TABLE(TestID INT, MaterialID INT, ProposedName NVARCHAR(100), DeterminationID INT, Score NVARCHAR(20));
    
    INSERT INTO @Tbl(TestID, MaterialID, ProposedName, DeterminationID, Score)
    SELECT T1.TestID, T1.MaterialID, T2.ProposedName, T3.DeterminationID, T3.Score
    FROM OPENJSON(@DataAsJson) WITH
    (
	   TestID		INT,
	   MaterialID	INT,
	   DH0List	NVARCHAR(MAX) AS JSON	  
    ) T1
    CROSS APPLY OPENJSON(T1.DH0List) WITH
    (
	   ProposedName    NVARCHAR(100),
	   Markers	    NVARCHAR(MAX) AS JSON
    ) T2
    CROSS APPLY OPENJSON(T2.Markers) WITH
    (
	   DeterminationID	   INT '$.MarkerNumber',
	   Score			   NVARCHAR(100)
    ) T3;

    --TestID validation
    SELECT DISTINCT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(T.TestID AS NVARCHAR(20))
    FROM @Tbl T
    LEFT JOIN Test T2 ON T2.TestID = T.TestID
    WHERE T2.TestID IS NULL;

    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Test ID(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END

    --MaterialID validation
    SET @IDs = NULL;
    SELECT DISTINCT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(M.MaterialID AS NVARCHAR(20))
    FROM @Tbl M
    LEFT JOIN Material T ON T.MaterialID = M.MaterialID
    WHERE T.MaterialID IS NULL;;
    
    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Material ID(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END

    --MarkerNumber validation
    SET @IDs = NULL;
    SELECT
	   @IDs = COALESCE(@IDs + ',', '') + CAST(M.DeterminationID AS NVARCHAR(20))
    FROM @Tbl M
    LEFT JOIN Determination D ON D.DeterminationID = M.DeterminationID
    WHERE D.DeterminationID IS NULL;  
    
    IF(ISNULL(@IDs, '') <> '') BEGIN
	   SET @IDs = N'Invalid Marker Number(s): ' + @IDs;
	   EXEC PR_ThrowError @IDs;
	   RETURN;
    END
    
    --Update RelationDonorDH0 table first
    MERGE RelationDonorDH0 T
    USING
    (
	   SELECT
		  TestID = MAX(T1.TestID), 
		  MaterialID = MAX(T1.MaterialID),
		  T1.ProposedName,
		  CropCode = MAX(F.CropCode)
	   FROM @Tbl T1
	   JOIN Test T ON T.TestID = T1.TestID
	   JOIN [File] F ON F.FileID = T.FileID
	   GROUP BY T1.ProposedName
    ) S ON S.ProposedName = T.ProposedName
    WHEN NOT MATCHED THEN
	   INSERT(MaterialID, CropCode, ProposedName,DH1ProposedName, StatusCode, TestID)
	   VALUES(S.MaterialID, S.CropCode, S.ProposedName,S.ProposedName +'DH1', 100, S.TestID);

    --Update S2SDonorMarkerScore table
    MERGE S2SDonorMarkerScore T
    USING 
    (
	   SELECT DISTINCT
		  M.DeterminationID, 
		  M.Score,
		  M.TestID,
		  M.MaterialID,
		  R.RelationDonorID
	   FROM @Tbl M 
	   JOIN RelationDonorDH0 R ON R.ProposedName = M.ProposedName
    ) S ON S.TestID = T.TestID 
    AND S.MaterialID = T.MaterialID 
    AND S.DeterminationID = T.DeterminationID 
    AND S.Score = T.Score
    AND S.RelationDonorID = T.RelationDonorID
    WHEN NOT MATCHED THEN
	   INSERT(TestID, MaterialID, DeterminationID, Score, RelationDonorID)
	   VALUES(S.TestID, S.MaterialID, S.DeterminationID, S.Score, S.RelationDonorID);
END

GO


DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_GetMarkerTestData]

GO

--EXEC PR_S2S_GetMarkerTestData 4378, 34277;
CREATE PROCEDURE [dbo].[PR_S2S_GetMarkerTestData]
(
	@TestID				INT,
	@MaterialID			INT
) AS BEGIN
	SET NOCOUNT ON;

	SELECT
		DI.DonorNumber,
		MarkerNumber = DMS.DeterminationID,
		MarkerName = D.DeterminationName,
		DonorMarkerUse = 'Sel',
		HaploidMarkerUse = 'Sel',
		AutoSelectScore = DMS.Score
	FROM S2SCapacitySlot CS
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	JOIN S2SDonorMarkerScore DMS ON DMS.TestID = T.TestID AND DMS.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = DMS.DeterminationID
	WHERE T.StatusCode >= 700
	AND T.TestID = @TestID
	AND M.MaterialID = @MaterialID
	AND ISNULL(DMS.Score,'') <> ''
	AND DMS.RelationDonorID IS NULL
END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_Get_DH0_To_Sync_GID]

GO

CREATE PROCEDURE [dbo].[PR_S2S_Get_DH0_To_Sync_GID]
(
	@CropCode NVARCHAR(MAX)
)
AS
BEGIN
	SELECT DH1ProposedName FROM RelationDonorDH0 WHERE CropCode = @CropCode AND StatusCode = 100;
END

GO


DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_Save_GID_To_ProposedName]
GO
 
CREATE PROCEDURE [dbo].[PR_S2S_Save_GID_To_ProposedName]
(
	@Json  NVARCHAR(MAX)
)
AS 
BEGIN
	
	MERGE INTO RelationDonorDH0 T
	USING
	(
		SELECT GID,ProposedName
		FROM OPENJSON(@Json)
		WITH
		(
			GID			INT '$.GID',
			ProposedName NVARCHAR(MAX) '$.Name'
		) AS JsonValues
	) S
	ON T.DH1ProposedName = S.ProposedName
	WHEN MATCHED THEN
	UPDATE SET T.DH1GID = S.GID, T.StatusCode = 200;


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



DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_GETDH0ToCreate]
GO


CREATE PROCEDURE [dbo].[PR_S2S_GETDH0ToCreate]
(
	@CropCode NVARCHAR(MAX),
	@TestID INT
)

AS 
BEGIN
	
	DECLARE @Columns NVARCHAR(MAX),@ColumnIDS NVARCHAR(MAX), @Query NVARCHAR(MAX)='',@PivotQuery NVARCHAR(MAX), @markerColumns NVARCHAR(MAX);


	SELECT 
		@ColumnIDS = COALESCE(@ColumnIDS + ',', '') + QUOTENAME(T.TraitID),
		@Columns = COALESCE(@Columns + ',', '') + QUOTENAME(T.TraitID) +' AS '+QUOTENAME(T.ColumnLabel),
		@markerColumns = COALESCE(@markerColumns + ',', '') + QUOTENAME(T.ColumnLabel)
	FROM S2SDonorMarkerScore MS
	JOIN RelationDonorDH0 R ON R.MaterialID = MS.MaterialID
	JOIN Determination D ON D.DeterminationID = MS.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
	JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = R.CropCode
	JOIN Trait T ON T.TraitID = CT.TraitID
	WHERE R.StatusCode = 100 AND MS.RelationDonorID IS NOT NULL AND R.TestID = @TestID
	GROUP BY T.TraitID,T.ColumnLabel


	IF(ISNULL(@Columns,'')<>'')
	BEGIN
		
		SET @PivotQuery = 'SELECT ProposedName, '+@Columns+' FROM 
							(
								SELECT ProposedName,TraitID,TraitVal FROM 
								(

									SELECT	
										R.ProposedName,
										T.TraitID,
										TraitVal = ISNULL(TDR.TraitResChar,''''),
										IsValid = CASE
													WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
													WHEN ISNULL(TDR.RelationID,0) = 0 THEN 0
													ELSE 1 END										
									FROM  RelationDonorDH0 R 
									JOIN Material M ON M.MaterialID = R.MaterialID
									JOIN [Row] Rw ON Rw.MaterialKey = M.MaterialKey
									JOIN S2SDonorMarkerScore MS ON MS.MaterialID = M.MaterialID
									JOIN Determination D ON D.DeterminationID = MS.DeterminationID
									JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
									JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = R.CropCode
									JOIN Trait T ON T.TraitID = CT.TraitID
									JOIN TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = MS.Score
									WHERE R.StatusCode = 100 AND MS.RelationDonorID IS NOT NULL AND ISNULL(MS.Score,'''') <> '''' AND R.TestID = @TestID
								
								)
								T WHERE T.IsValid = 1
							)
							Source
							PIVOT
							(
								MAX(TraitVal)
								FOR TraitID in ('+@ColumnIDS+')
							) PT';
		
		SET @Query =
			N'
				SELECT RD.ProposedName, DI.DonorName, ''DH0'' AS Gen, '+@markerColumns+' FROM Test T 
				JOIN [File]  F ON F.FileID = T.FileID
				JOIN [Row] R ON R.FileID = F.FileID
				JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
				JOIN Material M ON M.MaterialKey = R.MaterialKey
				JOIN RelationDonorDH0 RD ON RD.MaterialID = M.MaterialID AND RD.TestID = T.TestID AND RD.TestID = @TestID
				LEFT JOIN 
				(

					'+@PivotQuery+'
					
				)
				MT ON MT.ProposedName = RD.ProposedName
				WHERE RD.StatusCode = 100';
		PRINT @Query;
	END

	ELSE 
	BEGIN
		SET @Query = 
			N'	SELECT RD.ProposedName,DI.DonorName, ''DH0'' AS Gen  FROM Test T 
			JOIN [File]  F ON F.FileID = T.FileID
			JOIN [Row] R ON R.FileID = F.FileID
			JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
			JOIN Material M ON M.MaterialKey = R.MaterialKey
			JOIN RelationDonorDH0 RD ON RD.MaterialID = M.MaterialID AND RD.TestID = T.TestID
			WHERE RD.StatusCode = 100 AND RD.TestID = @TestID';
	END
	
	EXEC SP_ExecuteSQl @query, N'@TestID INT',@TestID;
	
END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_GetMissingConversion]
GO

CREATE PROCEDURE [dbo].[PR_S2S_GetMissingConversion]
(
	@TestID INT
)
AS
BEGIN

	SELECT 
		DeterminationName,
		Score
	FROM 
	(
		SELECT									
			IsValid = CASE
						WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
						WHEN ISNULL(TDR.RelationID,0) = 0 THEN 0
						ELSE 1 END,
			D.DeterminationName,
			D.DeterminationID,
			MS.Score
		FROM  RelationDonorDH0 R 
		JOIN Material M ON M.MaterialID = R.MaterialID
		JOIN [Row] Rw ON Rw.MaterialKey = M.MaterialKey
		JOIN S2SDonorMarkerScore MS ON MS.MaterialID = M.MaterialID
		JOIN Determination D ON D.DeterminationID = MS.DeterminationID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
		LEFT JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = R.CropCode
		LEFT JOIN Trait T ON T.TraitID = CT.TraitID
		LEFT JOIN TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND ISNULL(TDR.DetResChar,'') = ISNULL(MS.Score,'')
		WHERE 
			R.StatusCode = 100 
			AND MS.RelationDonorID IS NOT NULL 
			AND ISNULL(MS.Score,'') <> '' 
			AND R.TestID = @TestID
	) T WHERE IsValid = 0 
	GROUP BY DeterminationID, DeterminationName, Score
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

