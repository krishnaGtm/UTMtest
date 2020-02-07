CREATE TABLE EmailConfig
(
	ConfigID		INT PRIMARY KEY IDENTITY(1, 1),
	ConfigGroup		NVARCHAR(100),
	CropCode		NVARCHAR(10),
	Recipients		NVARCHAR(MAX)
)
GO

--SEED DEFAULT GROUPS
INSERT [dbo].[EmailConfig] ([ConfigGroup], [CropCode], [Recipients]) VALUES (N'UTM_SEND_RESULT_EMAIL', N'TO', NULL)
GO
INSERT [dbo].[EmailConfig] ([ConfigGroup], [CropCode], [Recipients]) VALUES (N'SEND_RESULT_EXE_ERROR_EMAIL', N'*', NULL)
GO


DROP PROCEDURE IF EXISTS PR_SaveEmailConfig
GO
/*
	EXEC PR_SaveEmailConfig NULL, 'UTM_SEND_RESULT_EMAIL', 'AN', 'a@gmail.com'
*/
CREATE PROCEDURE PR_SaveEmailConfig
(
	@ConfigID		INT				= NULL,
	@ConfigGroup	NVARCHAR(100),
	@CropCode		NVARCHAR(10),
	@Recipients		NVARCHAR(MAX)
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
		) BEGIN
			EXEC PR_ThrowError N'Configuration already exists. Please edit configuration instead.';
			RETURN;
		END
		ELSE BEGIN
			INSERT INTO EmailConfig(ConfigGroup, CropCode, Recipients)
			VALUES(@ConfigGroup, @CropCode, @Recipients);
		END
	END
	ELSE BEGIN
		UPDATE EmailConfig SET
			CropCode = @CropCode,
			Recipients = @Recipients
		WHERE ConfigID = @ConfigID;
	END
END
GO

DROP PROCEDURE IF EXISTS PR_GetEmailConfigs
GO

--EXEC PR_GetEmailConfigs NULL, NULL, 1, 20

CREATE PROCEDURE PR_GetEmailConfigs
(
	@ConfigGroup	NVARCHAR(100)	= NULL,
	@CropCode		NVARCHAR(10)	= NULL,
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
			Recipients
		FROM EmailConfig
		WHERE (ISNULL(@ConfigGroup, '') = '' OR ConfigGroup = @ConfigGroup)
		AND (ISNULL(@CropCode, '') = '' OR CropCode = @CropCode)
		
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

DROP PROCEDURE IF EXISTS PR_DeleteEmailConfig
GO

--EXEC PR_DeleteEmailConfig 14
CREATE PROCEDURE PR_DeleteEmailConfig
(
	@ConfigID	INT
) AS BEGIN
	SET NOCOUNT ON;
	IF EXISTS
	(
		SELECT * FROM
		(
			SELECT 
				ConfigGroup,
				Total = COUNT(ConfigID)
			FROM EmailConfig
			GROUP BY ConfigGroup
		) T1
		JOIN EmailConfig T2 ON T2.ConfigGroup = T1.ConfigGroup
		WHERE T2.ConfigID = @ConfigID 
		AND T1.Total <= 1		
	) BEGIN
		EXEC PR_ThrowError N'You can not delete this config. At least one row should be availabe for a group.';
		RETURN;
	END

	DELETE FROM EmailConfig WHERE ConfigID = @ConfigID;
END
GO