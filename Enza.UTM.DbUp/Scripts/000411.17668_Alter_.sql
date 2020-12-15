DROP PROCEDURE [dbo].[PR_RDT_Get_TraitDeterminationResult]
GO

/*
EXEC PR_RDT_Get_TraitDeterminationResult 200, 1, NULL, ''
EXEC PR_RDT_Get_TraitDeterminationResult 200, 1, 'CF', ''
*/
CREATE PROCEDURE [dbo].[PR_RDT_Get_TraitDeterminationResult]
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

	--PRINT @CropCodes

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
				TDR.RDTTraitDetResultID AS ID,
				Crop = CT.CropCode,
				CT.CropTraitID,
				Trait = T.ColumnLabel,
				D.DeterminationID,
				Determination = D.DeterminationName,
				D.DeterminationAlias,
				TDR.MaterialStatus,
				PercentFrom = MinPercent,
				PercentTo = MaxPercent,
				MappingCol,
				TraitValue = TDR.TraitResult,
				[Value] = TDR.DetResult,
				ListOfValues = CAST(ISNULL(T.ListOfValues, 0) AS BIT),
				RTD.RelationID
			FROM RDTTraitDetResult TDR
			JOIN RelationTraitDetermination RTD ON TDR.RelationID = RTD.RelationID
			JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
			JOIN Trait T ON T.TraitID = CT.TraitID
			WHERE T.Property = 0 AND CT.CropCode in ('+@CropCodes+')
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(ID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	SET @SQL = @SQL + '	ORDER BY CTE.Crop, CTE.Trait, CTE.CropTraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	--PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
END
GO


