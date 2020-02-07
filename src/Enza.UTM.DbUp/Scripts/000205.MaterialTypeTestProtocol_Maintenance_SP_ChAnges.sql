-- EXEC PR_GetMaterialTypeTestProtocols 1, 20, '[TestProtocolName] LIKE ''%CTAB%'''
ALTER PROCEDURE [dbo].[PR_GetMaterialTypeTestProtocols]
(
	@Page INT,
	@PageSize INT,
	@Filters NVARCHAR(MAX) = NULL
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Offset INT;

	IF(ISNULL(@Filters, '') = '') 
		SET @Filters = '1 = 1';

	DECLARE @SQL NVARCHAR(MAX) = 
	N'WITH CTE AS
	(
		SELECT * FROM
		(
			SELECT
				MTTP.CropCode,
				MTTP.MaterialTypeID,
				MTTP.TestProtocolID,
				MaterialTypeName =  MT.MaterialTypeCode + '' - '' + MT.MaterialTypeDescription,
				TP.TestProtocolName,
				TP.TestTypeID,
				TT.TestTypeName
			FROM MaterialTypeTestProtocol MTTP
			JOIN MaterialType MT ON MT.MaterialTypeID = MTTP.MaterialTypeID
			JOIN TestProtocol TP ON TP.TestProtocolID = MTTP.TestProtocolID
			JOIN TestType TT ON TT.TestTypeID = TP.TestTypeID 
		) V	WHERE ' + @Filters +
	N'), CTE_COUNT AS
	(
		SELECT TotalRows = COUNT(CTE.TestProtocolID)  FROM CTE
	)
	SELECT
		*
	FROM CTE, CTE_COUNT
	ORDER BY CTE.CropCode, CTE.MaterialTypeID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	SET @Offset = @PageSize * (@Page -1);

	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset, @PageSize;
END
GO
