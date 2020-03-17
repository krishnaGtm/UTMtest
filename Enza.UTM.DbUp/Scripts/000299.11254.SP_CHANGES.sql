ALTER TABLE EmailConfig
ADD BrStationCode   NVARCHAR(20);
GO

--EXEC PR_GetEmailConfigs 'CREATE_DH0_DH1_DATA_ERROR', '*', null, 1, 20

ALTER PROCEDURE [dbo].[PR_GetEmailConfigs]
(
	@ConfigGroup	NVARCHAR(100)	= NULL,
	@CropCode		NVARCHAR(10)	= NULL,
    @BrStationCode	NVARCHAR(20)    = NULL,
	@Page			INT,
	@PageSize		INT
) AS BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT = @PageSize * (@Page -1);
	
	WITH CTE AS
	(
		SELECT
			ConfigID,
			ConfigGroup,
			CropCode,
			Recipients,
            BrStationCode
		FROM EmailConfig
		WHERE (ISNULL(@ConfigGroup, '') = '' OR ConfigGroup = @ConfigGroup)
		AND (ISNULL(@CropCode, '') = '' OR CropCode = @CropCode)
        AND (ISNULL(@BrStationCode, '') = '' OR BrStationCode = @BrStationCode)		
	), CTE_COUNT AS 
	(
		SELECT COUNT(ConfigID) AS TotalRows FROM CTE
	)

	SELECT 
		CTE.*,
		CTE_COUNT.TotalRows
	FROM CTE, CTE_COUNT
	ORDER BY ConfigID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;
END
GO

/*
	EXEC PR_SaveEmailConfig NULL, 'UTM_SEND_RESULT_EMAIL', 'AN', 'a@gmail.com'
*/
ALTER PROCEDURE [dbo].[PR_SaveEmailConfig]
(
	@ConfigID		INT				= NULL,
	@ConfigGroup	NVARCHAR(100),
	@CropCode		NVARCHAR(10),  
	@Recipients		NVARCHAR(MAX),
    @BrStationCode	NVARCHAR(20)
) AS BEGIN
	SET NOCOUNT ON;
	
	IF(ISNULL(@ConfigID, 0) = 0 ) BEGIN
		IF EXISTS
		(
			SELECT 
				ConfigID 
			FROM EmailConfig 
			WHERE ConfigGroup = @ConfigGroup 
			AND CropCode = @CropCode
            AND BrStationCode = @BrStationCode
		) BEGIN
			EXEC PR_ThrowError N'Configuration already exists. Please edit configuration instead.';
			RETURN;
		END
		ELSE BEGIN
			INSERT INTO EmailConfig(ConfigGroup, CropCode, Recipients, BrStationCode)
			VALUES(@ConfigGroup, @CropCode, @Recipients, @BrStationCode);
		END
	END
	ELSE BEGIN
		UPDATE EmailConfig SET
			CropCode = @CropCode,
            BrStationCode = @BrStationCode,
			Recipients = @Recipients
		WHERE ConfigID = @ConfigID;
	END
END
GO