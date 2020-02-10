/*
Author					Date				Description
KRIAHNA GAUTAM			2020-JAN-02			Change in export to add unique rowID on excel export.

=================Example===============

EXEC [PR_CNT_GetDataWithMarkerForExcel] 4569
*/
ALTER PROCEDURE [dbo].[PR_CNT_GetDataWithMarkerForExcel]
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
				R.RowID,
				[Crop Code] = F.CropCode,
				P.[GID],
				P.[Gen],
				P.[Plant name],
				[PHID] = R.MaterialKey,
				[Donor Number] = I.DonorNumber,
				[Process] = PR.ProcessName,
				[LAB Location] = LL.LabLocationName,
				[Start Material] = SM.StartMaterialName,
				[Type] = T.TypeName,
				I.[Transplant],
				I.[Requested],
				I.[Net],	
				[Requested Date] = FORMAT(I.RequestedDate, ''dd/MM/yyyy''),				
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
			 WHERE R.Selected = 1
			 ORDER BY R.RowID';

    EXEC sp_executesql @SQL, N'@TestID INT, @FileID INT', @TestID, @FileID;

    SELECT 
	   DeterminationID, 
	   ColumnLabel 
    FROM @TblColumns;
END