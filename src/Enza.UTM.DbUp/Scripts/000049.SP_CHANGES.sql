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
				--DTR.CropCode,
				T.CropCode, 
				DTR.TraitID,
				TraitName = T.ColumnLabel, 
				DTR.DeterminationID, 
				D.DeterminationName,
				D.DeterminationAlias,
				DTR.DetResChar AS DeterminationValue,
				DTR.TraitResChar AS TraitValue,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				T.[Source]
			FROM TraitDeterminationResult DTR 
			JOIN Determination D ON D.DeterminationID = DTR.DeterminationID --AND D.CropCode = DTR.CropCode
			JOIN Trait T ON T.TraitID = DTR.TraitID --AND T.CropCode = DTR.CropCode
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
