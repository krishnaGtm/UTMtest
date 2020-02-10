DROP PROCEDURE IF EXISTS [PR_CNT_GetDataWithMarker]
GO

/*
    EXEC [PR_CNT_GetDataWithMarker] 4569, 1, 150, ''
*/
CREATE PROCEDURE [dbo].[PR_CNT_GetDataWithMarker]
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

    SELECT 
    @FileID = F.FileID,
    @ImportLevel = T.ImportLevel
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
	   FROM TestMaterialDetermination T1
	   JOIN RelationTraitDetermination T3 ON T3.DeterminationID = T1.DeterminationID
	   JOIN CropTrait CT ON CT.CropTraitID = T3.CropTraitID
	   JOIN Trait T ON T.TraitID = CT.TraitID
	   JOIN [Column] T4 ON T4.TraitID = T.TraitID AND ISNULL(T4.TraitID, 0) <> 0		
	   WHERE T1.TestID = @TestID
	   AND T4.FileID = @FileID			
	   GROUP BY T1.DeterminationID,T4.ColumLabel	
    ) V1
    ORDER BY V1.ColumnNr;

    --Trait and Property columns
    INSERT INTO @TblColumns(ColumnID, TraitID, ColumnLabel, ColumnType, ColumnNr, DataType)
    SELECT MAX(ColumnID), TraitID, ColumLabel, 2, MAX(ColumnNr), MAX(DataType)
    FROM [Column]
    WHERE FileID = @FileID
    GROUP BY ColumLabel, TraitID;
	
    --get Get Determination Column
    SELECT 
	   @Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(ColumnID)), ' AS ', QUOTENAME(MAX(TraitID))),
	   @ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(ColumnID))
    FROM @TblColumns
    WHERE ColumnType = 1
    GROUP BY TraitID;

    SELECT 
	   @Columns2  = COALESCE(@Columns2 + ',', '') + CONCAT(QUOTENAME(ColumnID), ' AS ', QUOTENAME(ISNULL(TraitID,ColumnLabel))),
	   @ColumnID2s  = COALESCE(@ColumnID2s + ',', '') + QUOTENAME(ColumnID)
    FROM @TblColumns
    WHERE ColumnType = 2;

    SELECT 
		@Columns3  = COALESCE(@Columns3 + ',', '') +  QUOTENAME(ISNULL(TraitID, ColumnLabel))
    FROM @TblColumns
    WHERE ColumnType <> 1
    ORDER BY [ColumnNr] ASC;

    --If there are no any determination assigned
    IF(ISNULL(@Columns,'') = '') BEGIN		
	   SET @Query = N';WITH CTE AS
	   (
		  SELECT 
			 M.MaterialID, 
			 T1.RowID, 
			 T1.RowNr, 
			 T1.Selected, 
			 M.MaterialKey,				
			 D.ProcessID,
			 D.LabLocationID,
			 D.StartMaterialID,
			 D.TypeID,
			 D.Requested,
			 D.Transplant,
			 D.Net,
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
			 D.ProcessID,
			 D.LabLocationID,
			 D.StartMaterialID,
			 D.TypeID,
			 D.Requested,
			 D.Transplant,
			 D.Net,
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
	   ProcessID,
	   LabLocationID,
	   StartMaterialID,
	   TypeID,
	   Requested,
	   Transplant,
	   Net,
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

    update @TblColumns SET ColumnNr = ColumnNr + 5 WHERE ColumnLabel NOT IN ('GID', 'Plant name')
    update @TblColumns SET ColumnNr = 0 WHERE ColumnLabel = 'GID'
    update @TblColumns SET ColumnNr = 1 WHERE ColumnLabel = 'Plant name';

    --insert other columns
    INSERT INTO @TblColumns(ColumnLabel, ColumnType, DataType, ColumnNr)
    VALUES('ProcessID', 2, 'INT', 4),
    ('LabLocationID', 2, 'INT', 5),
    ('StartMaterialID', 2, 'INT', 6),
    ('TypeID', 2, 'INT', 7),
    ('Requested', 2, 'INT', 8),
    ('Transplant', 2, 'INT', 9),
    ('Net', 2, 'INT', 10),
    ('DH1ReturnDate', 2, 'INT', 11),
    ('Remarks', 2, 'INT', 12);

    INSERT INTO @TblColumns(Traitid, ColumnLabel, ColumnType, DataType, ColumnNr)
    VALUES('D_Selected','Selected',2,'BIT',3);
		
    SELECT TraitID, ColumnLabel, ColumnType, ColumnNr, DataType,
    Fixed = CASE WHEN ColumnLabel = 'Crop' OR ColumnLabel = 'GID' OR ColumnLabel = 'Plantnr' OR ColumnLabel = 'Plant name' THEN 1 ELSE 0 END
    FROM @TblColumns T1
    ORDER BY Columntype,ColumnNr;		
END
GO

DROP PROCEDURE IF EXISTS [PR_CNT_GetDataWithMarkerForExcel]
GO

/*
    EXEC [PR_CNT_GetDataWithMarkerForExcel] 4569
*/
CREATE PROCEDURE [dbo].[PR_CNT_GetDataWithMarkerForExcel]
(
    @TestID INT
) AS BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FileID INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX);
    DECLARE @TblColumns TABLE(DeterminationID INT, ColumnLabel NVARCHAR(MAX), ColumnNr INT IDENTITY(0, 1));

    SELECT 
	   @FileID = F.FileID
    FROM [File] F
    JOIN Test T ON T.FileID = F.FileID 
    WHERE T.TestID = @TestID;

    --Determination columns
    INSERT INTO @TblColumns(DeterminationID, ColumnLabel)
    SELECT 
	   T1.DeterminationID,
	   D.DeterminationName
    FROM TestMaterialDetermination T1
    JOIN Test TST ON TST.TestID = T1.TestID
    JOIN [File] F ON F.FileID = TST.FileID
    JOIN [Column] C ON C.FileID = F.FileID
    JOIN Trait T ON T.TraitID = C.TraitID
    JOIN CropTrait CT ON CT.CropCode = F.CropCode AND CT.TraitID = T.TraitID
    JOIN RelationTraitDetermination T3 ON T3.CropTraitID = CT.CropTraitID AND T3.DeterminationID = T1.DeterminationID
    JOIN Determination D ON D.DeterminationID = T1.DeterminationID
    WHERE T1.TestID = @TestID AND ISNULL(C.TraitID, 0) <> 0			
    GROUP BY T1.DeterminationID, D.DeterminationName
    ORDER BY MAX(C.ColumnNr); 

    SELECT 
	   @Columns  = COALESCE(@Columns + ',', '') + CONCAT(QUOTENAME(MAX(DeterminationID)), ' AS ', QUOTENAME(MAX(ColumnLabel))),
	   @ColumnIDs  = COALESCE(@ColumnIDs + ',', '') + QUOTENAME(MAX(DeterminationID))
    FROM @TblColumns
    GROUP BY DeterminationID;

    SET @SQL = N'SELECT 
				[Crop Code] = F.CropCode,
				P.[GID],
				P.[Gen],
				P.[Plant name],
				[Process] = PR.ProcessName,
				[Requested Date] = FORMAT(I.Requested, ''dd/MM/yyyy''),
				[LAB Location] = LL.LabLocationName,
				[Start Material] = SM.StartMaterialName,
				[Type] = T.TypeName,
				I.[Transplant],
				I.[Net],
				[DH1 Return Date] = FORMAT(I.DH1ReturnDate, ''dd/MM/yyyy''),
				[Notes/Remarks] = I.Remarks ' + 
				CASE WHEN ISNULL(@ColumnIDs, '') <> '' THEN 
				    ', ' + @ColumnIDs 
				    ELSE '' 
				END +
			 N'FROM [Row] R 
			 JOIN [File] F ON F.FileID = R.FileID
			 JOIN Material M ON M.MaterialKey = R.MaterialKey
			 JOIN
			 (
				SELECT *  FROM 
				(
					
					   SELECT M.RowID, C.ColumLabel, M.[Value]
					   FROM VW_IX_Cell_Material M
					   JOIN [Column] C ON C.ColumnID = M.ColumnID
					   WHERE M.FileID = @FileID
					   AND ISNULL([Value], '''') <> ''''
				) SRC
				PIVOT
				(
					   Max([Value])
					   FOR ColumLabel IN ([GID], [Gen], [Plant name])
				) PV			 
			 ) P ON P.RowID = R.RowID ' + 
			 CASE WHEN ISNULL(@ColumnIDs, '') <> '' THEN 
				N'LEFT JOIN
				(
				    SELECT *
				    FROM 
				    (
					   SELECT 
						  T1.MaterialID, 
						  T1.DeterminationID
					   FROM TestMaterialDetermination T1
					   WHERE T1.TestID = @TestID
				    ) SRC 
				    PIVOT
				    (
					   COUNT(DeterminationID)
					   FOR [DeterminationID] IN (' + @ColumnIDs + N')
				    ) PV 
				) D ON D.MaterialID = M.MaterialID '
				ELSE '' 
			 END + 
			 N'LEFT JOIN CnTInfo I ON I.RowID = R.RowID
			 LEFT JOIN CnTProcess PR ON PR.ProcessID = I.ProcessID
			 LEFT JOIN CnTLABLocation LL ON LL.LabLocationID = I.LabLocationID
			 LEFT JOIN CnTStartMaterial SM ON SM.StartMaterialID = I.StartMaterialID
			 LEFT JOIN CnTType T ON T.TypeID = I.TypeID
			 WHERE R.Selected = 1';

    EXEC sp_executesql @SQL, N'@TestID INT, @FileID INT', @TestID, @FileID;

    SELECT 
	   DeterminationID, 
	   ColumnLabel 
    FROM @TblColumns;
END
GO

DROP PROCEDURE IF EXISTS [PR_CNT_ManageInfo]
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'{
	 "Materials": [
	   {
		"MaterialID": 0,
		"Selected": true
	   }
	 ],
	 "Details": [
	   {
		"MaterialID": 10,
		"ProcessID": 0,
		"LabLocationID": 0,
		"StartMaterialID": 0,
		"TypeID": 0,
		"Requested": 0,
		"Transplant": 0,
		"Net": 0,
		"DH1ReturnDate": "2019-09-18T12:09:03.577Z",
		"Remarks": "string"
	   }
	 ]
    }';
    EXEC PR_CNT_ManageInfo @DataAsJson;
*/
CREATE PROCEDURE [dbo].[PR_CNT_ManageInfo]
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    MERGE INTO CnTInfo T
    USING 
    ( 
	   SELECT 
		  V.MaterialID,
		  V.ProcessID,
		  V.LabLocationID,
		  V.StartMaterialID,
		  V.TypeID,
		  V.Requested,
		  V.Transplant,
		  V.Net,
		  V.DH1ReturnDate,
		  V.Remarks,
		  R.RowID
	   FROM OPENJSON(@DataAsJson) WITH
	   (
		  Details	 NVARCHAR(MAX) AS JSON
	   )
	   CROSS APPLY OPENJSON(Details) WITH
	   (
		  MaterialID		  INT,
		  ProcessID		  INT,
		  LabLocationID	  INT,
		  StartMaterialID	  INT,
		  TypeID			  INT,
		  Requested		  INT,
		  Transplant		  INT,
		  Net			  INT,
		  DH1ReturnDate	  DATETIME,
		  Remarks			  NVARCHAR(MAX)
	   ) V
	   JOIN Material M ON M.MaterialID = V.MaterialID
	   JOIN [Row] R ON R.MaterialKey = M.MaterialKey
    ) S
    ON T.RowID = S.RowID
    WHEN NOT MATCHED THEN 
	   INSERT(RowID, ProcessID, LabLocationID, StartMaterialID, TypeID, Requested, Transplant, Net, DH1ReturnDate, Remarks) 
	   VALUES(S.RowID, S.ProcessID, S.LabLocationID, S.StartMaterialID, S.TypeID, S.Requested, S.Transplant, S.Net, S.DH1ReturnDate, S.Remarks)
    WHEN MATCHED THEN
	   UPDATE SET 
		  ProcessID	   = S.ProcessID, 
		  LabLocationID   = S.LabLocationID, 
		  StartMaterialID = S.StartMaterialID, 
		  TypeID		   = S.TypeID, 
		  Requested	   = S.Requested, 
		  Transplant	   = S.Transplant, 
		  Net		   = S.Net, 
		  DH1ReturnDate   = S.DH1ReturnDate, 
		  Remarks		   = S.Remarks;

    --Now update state of selected rows
    UPDATE R SET 
	   R.Selected = S.Selected
    FROM [Row] R
    JOIN
    (
	   SELECT 
		  R.RowID,
		  V.Selected
	   FROM OPENJSON(@DataAsJson) WITH
	   (
		  Materials NVARCHAR(MAX) AS JSON
	   )
	   CROSS APPLY OPENJSON(Materials) WITH
	   (
		  MaterialID	INT,
		  Selected	BIT
	   ) V
	   JOIN Material M ON M.MaterialID = V.MaterialID
	   JOIN [Row] R ON R.MaterialKey = M.MaterialKey
    ) S ON S.RowID = R.RowID;
END
GO