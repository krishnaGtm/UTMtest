DROP PROCEDURE IF EXISTS [PR_SaveTraitDeterminationResult]
GO

CREATE PROCEDURE [dbo].[PR_SaveTraitDeterminationResult]
(
	@CropCode	NCHAR(2),
	@TVP		TVP_TraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;

	--validation check if value already exists
	IF EXISTS
	(
		SELECT 
			T1.TraitDeterminationResultID 
		FROM TraitDeterminationResult T1
		JOIN @TVP T2 ON T2.RelationID = T1.RelationID AND T2.TraitResChar = T1.TraitResChar AND T2.DetResChar = T1.DetResChar
	) BEGIN
		EXEC PR_ThrowError N'Mapping already exists.';
		RETURN;
	END

	--New Insert
	INSERT INTO TraitDeterminationResult(RelationID, TraitResChar, DetResChar)
	SELECT T1.RelationID, T1.TraitResChar, T1.DetResChar
	FROM @TVP T1
	LEFT JOIN TraitDeterminationResult T2 ON T2.RelationID = T1.RelationID AND T2.TraitResChar = T1.TraitResChar AND T2.DetResChar = T1.DetResChar
	WHERE T2.TraitDeterminationResultID IS NULL
	AND T1.[Action] = 'I'

	--Update existing
	UPDATE T2 SET
		T2.TraitResChar = T1.TraitResChar,
		T2.DetResChar = T1.DetResChar
	FROM @TVP T1
	JOIN TraitDeterminationResult T2 ON T2.TraitDeterminationResultID = T1.TraitDeterminationResultID
	WHERE T1.[Action] = 'U'
	AND NOT EXISTS
	(
		SELECT TraitDeterminationResultID FROM TraitDeterminationResult
		WHERE RelationID = T1.RelationID
		AND TraitResChar = T1.TraitResChar
		AND DetResChar = T1.DetResChar
	)

	--Delete existing
	DELETE R
	FROM TraitDeterminationResult R 
	JOIN @TVP T1 ON T1.TraitDeterminationResultID = R.TraitDeterminationResultID
	WHERE T1.[Action] = 'D';
END
GO
