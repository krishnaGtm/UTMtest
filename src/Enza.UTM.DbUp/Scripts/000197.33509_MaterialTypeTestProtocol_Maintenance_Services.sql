DROP PROCEDURE IF EXISTS PR_GetMaterialTypeTestProtocols
GO
-- EXEC PR_GetMaterialTypeTestProtocols 1, 20, '[TestProtocolName] LIKE ''%CTAB%'''
CREATE PROCEDURE PR_GetMaterialTypeTestProtocols
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
		WHERE ' + @Filters +
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

DROP PROCEDURE IF EXISTS PR_SaveMaterialTypeTestProtocols
GO

CREATE PROCEDURE PR_SaveMaterialTypeTestProtocols
(
	@OldMaterialTypeID	INT = NULL,
	@OldTestProtocolID	INT = NULL,
	@OldCropCode		NVARCHAR(4) = NULL,
	@MaterialTypeID		INT,
	@TestProtocolID		INT,
	@CropCode			NVARCHAR(4)
) AS BEGIN
	SET NOCOUNT ON;

	IF EXISTS
	(
		SELECT 
			MaterialtypeID 
		FROM MaterialTypeTestProtocol
		WHERE MaterialTypeID = @MaterialTypeID
		AND TestProtocolID = @TestProtocolID
		AND CropCode = @CropCode
	) BEGIN
		EXEC PR_ThrowError N'Data with same combination already exists.';
		RETURN;
	END	
	IF(ISNULL(@OldMaterialTypeID, 0) <> 0 AND ISNULL(@OldTestProtocolID, 0) <> 0 AND ISNULL(@OldCropCode, '') <> '') BEGIN
		UPDATE MaterialTypeTestProtocol SET 
			MaterialTypeID = @MaterialTypeID, 
			TestProtocolID = @TestProtocolID, 
			CropCode = @CropCode
		WHERE MaterialTypeID = @OldMaterialTypeID
		AND TestProtocolID = @OldTestProtocolID
		AND CropCode = @OldCropCode;
	END
	ELSE BEGIN
		INSERT MaterialTypeTestProtocol(MaterialTypeID, TestProtocolID, CropCode)
		VALUES(@MaterialTypeID, @TestProtocolID, @CropCode);
	END	
END
GO