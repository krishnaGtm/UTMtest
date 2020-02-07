/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 5/4/2018 3:30:26 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Save_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 5/4/2018 3:30:26 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_RelationTraitDetermination]
GO
/****** Object:  StoredProcedure [dbo].[PR_Get_RelationTraitDetermination]    Script Date: 5/4/2018 3:30:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Get_RelationTraitDetermination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Get_RelationTraitDetermination] AS' 
END
GO
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
 
 SET @SQL = @SQL + ' ORDER BY CTE.ColumnLabel  
 OFFSET @Offset ROWS  
 FETCH NEXT @PageSize ROWS ONLY'
 PRINT @SQL

 EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;	

 

   
END
GO
/****** Object:  StoredProcedure [dbo].[PR_Save_RelationTraitDetermination]    Script Date: 5/4/2018 3:30:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_Save_RelationTraitDetermination]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PR_Save_RelationTraitDetermination] AS' 
END
GO
--DROP PROC PR_Save_RelationTraitDetermination
ALTER PROCEDURE [dbo].[PR_Save_RelationTraitDetermination]
(
	@TVP_RelationTraitDetermination TVP_RelationTraitDetermination READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	--INsert Statement

	--IF EXISTS (SELECT R.RelationID 
	--	FROM RelationTraitDetermination R 
	--	JOIN  @TVP_RelationTraitDetermination T1 
	--	--ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID
	--	ON R.TraitID = T1.TraitID
	--	WHERE T1.[Action] = 'I') BEGIN

	--	EXEC PR_ThrowError 'Insert Failed. Relation already exists.';
	--	RETURN;
	--END

	--IF EXISTS (SELECT R.RelationID 
	--	FROM RelationTraitDetermination R 
	--	JOIN  @TVP_RelationTraitDetermination T1 
	--	--ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID AND R.RelationID != T1.RelationID
	--	ON R.TraitID = T1.TraitID AND R.RelationID != T1.RelationID
	--	WHERE T1.[Action] = 'U') BEGIN

	--	EXEC PR_ThrowError 'Update Failed.Relation already exists.';
	--	RETURN;
	--END

	INSERT INTO RelationTraitDetermination(CropCode, TraitID, ColumnLabel, DeterminationID, [Source], [Status])
	SELECT D.CropCode, T1.TraitID, T1.TraitName, D.DeterminationID, T1.[Source], 'ACT'
	FROM @TVP_RelationTraitDetermination T1
	JOIN Determination D ON D.DeterminationID = T1.DeterminationID
	WHERE ISNULL(T1.RelationID, 0) = 0 AND T1.[Action] = 'I';

	--UPdate Statement 
	--We send Action = 'D' For Delete.
	UPDATE R SET 
		R.DeterminationID = T1.DeterminationID
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'U';


	--DELETE Statement 
	DELETE R
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'D';
	
END
GO
