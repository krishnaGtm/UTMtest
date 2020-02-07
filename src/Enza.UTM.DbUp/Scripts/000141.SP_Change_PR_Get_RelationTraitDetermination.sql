/*  
 DECLARE @Total INT;  
 EXEC PR_Get_RelationTraitDetermination 200, 1, 'ON',''
*/  
ALTER PROCEDURE [dbo].[PR_Get_RelationTraitDetermination]  
(  
 @PageSize INT,  
 @PageNumber INT,
 @Crops NVARCHAR(MAX),
 @Filter NVARCHAR(MAX)
)  
AS  
BEGIN  
 DECLARE @Offset INT, @SQL NVARCHAR(MAX);
 SET @Offset = @PageSize * (@PageNumber -1);  
 DECLARE @StatusTable TABLE(StatusCode INT, [Status] NVARCHAR(100));
 DECLARE @CropCodes NVARCHAR(MAX);



 SELECT @CropCodes = COALESCE(@CropCodes + ',', '') + ''''+ T.[value] +'''' FROM 
 string_split(@Crops,',') T
 

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
			CT.CropCode,
			CT.CropTraitID,
			TraitLabel = T.ColumnLabel,
			D.DeterminationID,
			D.DeterminationName,
			D.DeterminationAlias,
			RTD.RelationID,
			[Status] = ST.[StatusName]
		FROM CropTrait CT
		JOIN Trait T ON T.TraitID = CT.TraitID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.CropTraitID = CT.CropTraitID
		LEFT JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
		LEFT JOIN [Status] ST ON ST.StatusCode = RTD.StatusCode AND  ST.StatusTable =  ''RelationTraitDetermination''
		WHERE CT.CropCode in ('+@CropCodes+')
	
	) AS T '+ @Filter + '
		
), Count_CTE AS 
(	
	SELECT 
		COUNT(CropTraitID) AS [TotalRows] 
	FROM CTE
)  

SELECT 
	CropCode, 
	CropTraitID, 
	TraitLabel, 
	DeterminationID,	
	DeterminationName,
	DeterminationAlias, 
	RelationID,
	[Status],  
	Count_CTE.[TotalRows] 
FROM CTE, Count_CTE ' ;

--IF(ISNULL(@Filter,'') <> '') BEGIN
--	SET @SQL = @SQL + ' WHERE '+ @Filter;
--END
 


 SET @SQL = @SQL + ' ORDER BY CTE.CropCode, CTE.TraitLabel,CTE.CropTraitID 
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 --PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	

   
END
