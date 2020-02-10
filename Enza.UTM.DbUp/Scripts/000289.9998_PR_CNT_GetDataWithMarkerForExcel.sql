/*
Author					Date				Description
KRIAHNA GAUTAM			2020-JAN-02			Change in export to add unique rowID on excel export.
KRIAHNA GAUTAM			2020-JAN-29			Change header text of excel file.
KRIAHNA GAUTAM			2020-JAN-30			#9998 Change logic of showing marker result in different way
=================Example===============

EXEC [PR_CNT_GetDataWithMarkerForExcel] 4582
*/
ALTER PROCEDURE [dbo].[PR_CNT_GetDataWithMarkerForExcel]
(
    @TestID INT
) AS BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FileID INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Columns NVARCHAR(MAX), @ColumnIDs NVARCHAR(MAX);
    --DECLARE @TblColumns TABLE(DeterminationID INT, ColumnLabel NVARCHAR(MAX), ColumnNr INT IDENTITY(0, 1));

    SELECT 
	   @FileID = F.FileID
    FROM [File] F
    JOIN Test T ON T.FileID = F.FileID 
    WHERE T.TestID = @TestID;

	;WITH CTE AS
	(
		SELECT 
				UtmID = R.RowID,
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
				[Requested Date] = FORMAT(I.RequestedDate, 'dd/MM/yyyy'),				
				[Delivered] = FORMAT(I.DH1ReturnDate, 'dd/MM/yyyy'),
				[Notes/Remarks] = I.Remarks,
				D.Determinations,
				D.TotalDeterminations
			 FROM [Row] R 
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
					   AND ISNULL([Value], '') <> ''
				) SRC
				PIVOT
				(
					   Max([Value])
					   FOR ColumLabel IN ([GID], [Gen], [Plant name])
				) PV			 
			 ) P ON P.RowID = R.RowID
			 LEFT JOIN
			(
				SELECT MaterialID, Determinations, TotalDeterminations = ( SELECT COUNT(*) FROM string_split(Determinations,','))
				FROM
				(

					SELECT
						MaterialID, 
						Determinations = STUFF 
							((SELECT DISTINCT ',' + CAST(D.DeterminationName AS NVARCHAR(50))
										  FROM TestMaterialDetermination T
										  JOIN Determination D ON D.DeterminationID = T.DeterminationID
										  where T.MaterialID = TMD.MaterialID AND T.TestID = @TestID
										  FOR XML PATH ('')
								), 1, 1, '') 
					FROM TestMaterialDetermination TMD WHERE TestID = @TestID
				) D1
				GROUP BY MaterialID,Determinations
			) D ON D.MaterialID = M.MaterialID 
			LEFT JOIN CnTInfo I ON I.RowID = R.RowID
			 LEFT JOIN CnTProcess PR ON PR.ProcessID = I.ProcessID
			 LEFT JOIN CnTLABLocation LL ON LL.LabLocationID = I.LabLocationID
			 LEFT JOIN CnTStartMaterial SM ON SM.StartMaterialID = I.StartMaterialID
			 LEFT JOIN CnTType T ON T.TypeID = I.TypeID
			 WHERE R.Selected = 1
			 
			 ), Count_CTE AS (SELECT MAX(TotalDeterminations) AS MaxMarker FROM CTE) 
			 SELECT CTE.UtmID,CTE.[Crop Code],CTE.GID,CTE.Gen,CTE.[Plant name],CTE.PHID,CTE.Process,CTE.[LAB Location],CTE.[Start Material],CTE.[Type],CTE.Transplant,CTE.Requested,CTE.Net,CTE.[Requested Date],CTE.Delivered,CTE.[Notes/Remarks],CTE.Determinations, Count_CTE.MaxMarker FROM CTE, COUNT_CTE
	ORDER BY CTE.UtmID
END