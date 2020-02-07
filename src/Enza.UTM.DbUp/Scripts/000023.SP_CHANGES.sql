/*
EXEC PR_Get_TraitDeterminationResult 200, 1, 'CropCode like ''%TO%'''
*/
ALTER PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
(
	@PageSize	INT,
	@PageNumber INT,
	@Filter NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @Offset INT;
	SET @Offset = @PageSize * (@PageNumber -1);
	DECLARE @SQL NVARCHAR(MAX);

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
				DTR.TraitDeterminationResultID,
				DTR.CropCode, 
				DTR.TraitID,
				T.TraitName, 
				DTR.DeterminationID, 
				D.DeterminationName,
				D.DeterminationAlias,
				DTR.DetResChar AS DeterminationValue,
				DTR.TraitResChar AS TraitValue,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				T.[Source]
			FROM TraitDeterminationResult DTR 
			JOIN Determination D ON D.DeterminationID = DTR.DeterminationID AND D.CropCode = DTR.CropCode
			JOIN Trait T ON T.TraitID = DTR.TraitID AND T.CropCode = DTR.CropCode
			WHERE T.[Source] <> ''Breezys''
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(TraitDeterminationResultID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	--IF(ISNULL(@Filter,'')<> '') BEGIN
	--	SET @SQL = @SQL + ' WHERE '+@Filter;
	--END

	SET @SQL = @SQL + '	ORDER BY CTE.[Source], CTE.CropCode, CTE.TraitName,CTE.TraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	--PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
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
			TraitLabel = T1.TraitName,
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