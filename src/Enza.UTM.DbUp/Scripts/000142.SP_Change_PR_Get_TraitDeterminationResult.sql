/*
EXEC PR_Get_TraitDeterminationResult 200, 1, ''
*/
ALTER PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
(
	@PageSize	INT,
	@PageNumber INT,
	@Crops NVARCHAR(MAX),
	@Filter NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @Offset INT;
	SET @Offset = @PageSize * (@PageNumber -1);
	DECLARE @SQL NVARCHAR(MAX);
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
				TDR.TraitDeterminationResultID AS ID,
				CT.CropCode,
				CT.CropTraitID,
				TraitName = T.ColumnLabel,
				D.DeterminationID,
				D.DeterminationName,
				D.DeterminationAlias,
				TDR.DetResChar AS DeterminationValue,
				TDR.TraitResChar AS TraitValue,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				RTD.RelationID
			FROM TraitDeterminationResult TDR
			JOIN RelationTraitDetermination RTD ON TDR.RelationID = RTD.RelationID
			JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
			JOIN Trait T ON T.TraitID = CT.TraitID
			WHERE CT.CropCode in ('+@CropCodes+')
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(ID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	--IF(ISNULL(@Filter,'')<> '') BEGIN
	--	SET @SQL = @SQL + ' WHERE '+@Filter;
	--END

	SET @SQL = @SQL + '	ORDER BY CTE.CropCode, CTE.TraitName,CTE.CropTraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
END
