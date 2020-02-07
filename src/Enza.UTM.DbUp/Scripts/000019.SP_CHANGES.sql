EXEC sp_RENAME 'TraitDeterminationResult.DeterminationValue' , 'DetResChar', 'COLUMN';

EXEC sp_RENAME 'TraitDeterminationResult.TraitValue' , 'TraitResChar', 'COLUMN';

DROP PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
GO

DROP PROCEDURE [dbo].[PR_SaveTraitDeterminationResult]
GO

DROP TYPE [dbo].[TVP_TraitDeterminationResult]
GO


CREATE TYPE [dbo].[TVP_TraitDeterminationResult] AS TABLE(
	[TraitDeterminationResultID] [int] NULL,
	[TraitID] [int] NULL,
	[DeterminationID] [int] NULL,
	[TraitResChar] [nvarchar](max) NULL,
	[DetResChar] [nvarchar](max) NULL,
	[Action] [char](1) NULL
)
GO

CREATE PROCEDURE [dbo].[PR_Get_TraitDeterminationResult]
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
			DTR.DetResChar,
			DTR.TraitResChar,
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




CREATE PROCEDURE [dbo].[PR_SaveTraitDeterminationResult]
(
	@CropCode	NCHAR(2),
	@TVP		TVP_TraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;
	--VALIDATION
	IF EXISTS
	(
		SELECT 
			T1.TraitDeterminationResultID
		FROM TraitDeterminationResult T1
		JOIN  @TVP T2 ON T2.TraitID = T1.TraitID AND T2.DeterminationID = T1.DeterminationID AND T2.TraitResChar = T1.TraitResChar
		WHERE T1.CropCode = @CropCode AND T2.[Action] = 'I'
	) BEGIN
		EXEC PR_ThrowError 'Insert failed. Relation already exists.';
		RETURN;
	END

	IF EXISTS
	(
		SELECT 
			T1.TraitDeterminationResultID
		FROM TraitDeterminationResult T1
		JOIN  @TVP T2 ON T2.TraitID = T1.TraitID AND T2.DeterminationID = T1.DeterminationID AND T2.TraitResChar = T1.TraitResChar AND T2.TraitDeterminationResultID <> T1.TraitDeterminationResultID
		WHERE T1.CropCode = @CropCode AND T2.[Action] = 'U'
	) BEGIN
		EXEC PR_ThrowError 'Update failed. Relation already exists.';
		RETURN;
	END


	--INSERT NEW 
	INSERT INTO TraitDeterminationResult([CropCode], [DeterminationID], [TraitID], [DetResChar], [TraitResChar])
	SELECT
		@CropCode,
		T1.DeterminationID,
		T1.TraitID,
		T1.DetResChar,
		T1.TraitResChar
	FROM @TVP T1
	WHERE T1.[Action] = 'I';

	--UPDATE IF AVAILABLE
	UPDATE T1 SET
		[CropCode]				= @CropCode, 
		[DeterminationID]		= T2.DeterminationID, 
		[TraitID]				= T2.TraitID, 
		[DetResChar]			= T2.DetResChar, 
		[TraitResChar]			= T2.TraitResChar
	FROM TraitDeterminationResult T1
	JOIN @TVP T2 ON T2.TraitDeterminationResultID = T1.TraitDeterminationResultID
	WHERE T2.[Action] = 'U';

	--DELETE 
	DELETE T1
	FROM TraitDeterminationResult T1
	JOIN @TVP T2 ON T2.TraitDeterminationResultID = T1.TraitDeterminationResultID
	WHERE T2.[Action] = 'D';
END
GO

