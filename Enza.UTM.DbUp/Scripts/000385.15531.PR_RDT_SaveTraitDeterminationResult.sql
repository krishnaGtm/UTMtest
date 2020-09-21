

ALTER PROCEDURE [dbo].[PR_RDT_SaveTraitDeterminationResult]
(
	@TVP		TVP_RDTTraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT R.RDTTraitDetResultID FROM @TVP T
	JOIN RDTTraitDetResult R ON ISNULL(R.DetResult,'') = ISNULL(T.DetResult,'') AND ISNULL(T.MappingCol,'') = ISNULL(R.MappingCol,'') AND ISNULL(T.MinPercent,0) = ISNULL(R.MinPercent,0) AND ISNULL(T.MaxPercent,0) = ISNULL(R.MaxPercent,0) AND ISNULL(T.MaterialStatus,'') = ISNULL(R.MaterialStatus,'') AND ISNULL(T.DetResult,'') = ISNULL(R.DetResult,'')
	WHERE T.Action = 'I')
	BEGIN		
		EXEC PR_ThrowError 'Cannot insert duplicate value.';
		RETURN;

	END

	--merge statement
	MERGE INTO RDTTraitDetResult T
	USING @TVP S ON S.RDTTraitDetResultID = T.RDTTraitDetResultID
	WHEN MATCHED AND S.[Action] = 'U' THEN
	UPDATE SET 
			T.TraitResult = S.TraitResult,
			T.MappingCol = (CASE WHEN ISNULL(S.MappingCol,'') <> '' THEN S.MappingCol ELSE NULL END),
			T.MinPercent = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MinPercent ELSE NULL END),
			T.MaxPercent = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaxPercent ELSE NULL END),
			T.MaterialStatus = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaterialStatus ELSE NULL END),
			T.DetResult = S.DetResult
	WHEN MATCHED AND S.[Action] = 'D' THEN
	DELETE
	WHEN NOT MATCHED AND S.[Action] = 'I'
	THEN INSERT (RelationID, TraitResult, DetResult, MappingCol, MinPercent, MaxPercent, MaterialStatus)
	VALUES 
	(RelationID, 
	TraitResult, 
	DetResult, 
	(CASE WHEN ISNULL(S.MappingCol,'') <> '' THEN S.MappingCol ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MinPercent ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaxPercent ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaterialStatus ELSE NULL END)
	);

END
