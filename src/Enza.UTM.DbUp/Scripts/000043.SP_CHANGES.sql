/*
	EXEC PR_GET_Determination_All 'r 0010'
*/
ALTER PROCEDURE [dbo].[PR_GET_Traits_All]
(
	@TraitName NVARCHAR(100),
	@CropCode NVARCHAR(10),
	@Source	  NVARCHAR(50)
)
AS
BEGIN
	SELECT TOP 200 TraitID, ColumnLabel AS TraitName,TraitDescription, CropCode, ListOfValues = CAST ( ISNULL(ListOfValues, 0) AS BIT )
	FROM Trait
	WHERE TraitName like '%'+ @TraitName+'%'
	AND CropCode = @CropCode
	AND [Source] = @Source;
END

GO



/*  
 DECLARE @Total INT;  
 EXEC PR_Get_RelationTraitDetermination 200, 1, 'traitlabel like ''%s%'''
*/  
ALTER PROCEDURE [dbo].[PR_Get_RelationTraitDetermination]  
(  
 @PageSize INT,  
 @PageNumber INT,
 @Filter NVARCHAR(MAX)
)  
AS  
BEGIN  
 DECLARE @Offset INT, @SQL NVARCHAR(MAX);
 SET @Offset = @PageSize * (@PageNumber -1);  


IF(ISNULL(@Filter,'') <> '') BEGIN
	SET @Filter =' WHERE '+ @Filter;
END

ELSE BEGIN
	SET @Filter = '';
END
  
 SET @SQL = N'
;WITH CTE AS  
(  
	SELECT * FROM 
	(
		SELECT 
			T1.[Source],
			T1.CropCode,
			T1.TraitID,
			T2.RelationID,
			--TraitLabel = T1.TraitName,
			TraitLabel = T1.ColumnLabel,
			T2.DeterminationID,
			T2.DeterminationName,
			T2.DeterminationAlias,
			T2.[Status]
		FROM Trait T1
		LEFT JOIN
		(
			SELECT 
				--RTD.[Source],
				--RTD.CropCode,    
				RTD.RelationID, 	    
				RTD.TraitID,  
				RTD.ColumnLabel,   
				RTD.DeterminationID,	  
				RTD.[Status],
				D.DeterminationName,  
				D.DeterminationAlias 
			FROM RelationTraitDetermination RTD 
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
		) T2 ON T2.TraitID = T1.TraitID --AND T2.[Source] = T1.[Source] AND T2.CropCode = T1.CropCode
		WHERE T1.[Source] <> ''Breezys''
	) AS T '+@Filter +' 
), Count_CTE AS 
(	
	SELECT 
		COUNT(TraitID) AS [TotalRows] 
	FROM CTE
)  

SELECT 
	CropCode, 
	TraitID, 
	TraitLabel, 
	DeterminationID,
	[Source],
	DeterminationName,
	DeterminationAlias, 
	RelationID,
	[Status],  
Count_CTE.[TotalRows] 
FROM CTE, Count_CTE' ;

--IF(ISNULL(@Filter,'') <> '') BEGIN
--	SET @SQL = @SQL + ' WHERE '+ @Filter;
--END
 

 SET @SQL = @SQL + ' ORDER BY CTE.[Source], CTE.CropCode, CTE.TraitLabel,CTE.TraitID 
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 --PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	

 

   
END
Go