/*  
 DECLARE @Total INT;  
 EXEC PR_Get_RelationTraitDetermination 200, 1, 'CropCode like ''%LT%'''
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

  
  SET @SQL = N'
;WITH CTE AS  
(  
	SELECT 
		T1.[Source],
		T1.CropCode,
		T1.TraitID,
		T2.RelationID,
		ColumnLabel = T1.TraitName,
		T2.DeterminationID,
		T2.DeterminationName,
		T2.DeterminationAlias,
		T2.[Status]
	FROM Trait T1
	LEFT JOIN
	(
		SELECT 
			RTD.[Source],
			RTD.CropCode,    
			RTD.RelationID, 	    
			RTD.TraitID,  
			RTD.ColumnLabel,   
			RTD.DeterminationID,	  
			RTD.[Status],
			D.DeterminationName,  
			D.DeterminationAlias 
		FROM RelationTraitDetermination RTD 
		JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
	) T2 ON T2.TraitID = T1.TraitID AND T2.[Source] = T1.[Source] AND T2.CropCode = T1.CropCode
	WHERE T1.[Source] <> ''Breezys''
), Count_CTE AS 
(	
	SELECT 
		COUNT(TraitID) AS [TotalRows] 
	FROM CTE
)  

SELECT 
	CropCode, 
	TraitID, 
	ColumnLabel, 
	DeterminationID,
	[Source],
	DeterminationName,
	DeterminationAlias, 
	RelationID,
	[Status],  
Count_CTE.[TotalRows] 
FROM CTE, Count_CTE' ;

IF(ISNULL(@Filter,'') <> '') BEGIN
	SET @SQL = @SQL + ' WHERE '+ @Filter;
END
 
 SET @SQL = @SQL + ' ORDER BY CTE.[Source], CTE.CropCode, CTE.ColumnLabel  
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	
    
END

GO


--EXEC [PR_Get_TraitDeterminationResult] 100, 1
ALTER PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
(
	@PageSize	INT,
	@PageNumber INT
)
AS
BEGIN
	DECLARE @Offset INT;
	SET @Offset = @PageSize * (@PageNumber -1);

	WITH CTE AS
	(
		SELECT 
			DTR.TraitDeterminationResultID,
			DTR.CropCode, 
			DTR.TraitID,
			T.TraitName, 
			DTR.DeterminationID, 
			D.DeterminationName,
			D.DeterminationAlias,
			DTR.DeterminationValue,
			DTR.TraitValue,
			ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
			T.[Source]
		FROM TraitDeterminationResult DTR 
		JOIN Determination D ON D.DeterminationID = DTR.DeterminationID AND D.CropCode = DTR.CropCode
		JOIN Trait T ON T.TraitID = DTR.TraitID AND T.CropCode = DTR.CropCode
	), CTE_COUNT AS
	(
		SELECT COUNT(TraitDeterminationResultID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT
	ORDER BY CTE.[Source], CTE.CropCode, CTE.TraitName
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO
