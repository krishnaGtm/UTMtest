
ALTER PROCEDURE [dbo].[PR_SaveTraitDeterminationResult]
(
	@CropCode	NCHAR(2),
	@TVP		TVP_TraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;

	--insert or delete operation
	MERGE INTO TraitDeterminationResult T
				USING
				(
					SELECT T1.TraitDeterminationResultID, T1.RelationID,TraitResChar,DetResChar
					FROM @TVP T1	--get only data to insert otherwise it will not match for update and delete also.
					WHERE T1.Action in ('I','U')						
				) S	ON S.TraitDeterminationResultID = T.TraitDeterminationResultID
				WHEN NOT MATCHED THEN
					INSERT(RelationID, DetResChar,TraitResChar)
					VALUES(S.RelationID, S.DetResChar,S.TraitResChar)
				WHEN MATCHED THEN
					UPDATE SET T.RelationID		= S.RelationID,
							   T.TraitResChar	= S.TraitResChar, 
							   T.DetResChar		= S.DetResChar;

			--DELETE Statement 
			DELETE R
			FROM @TVP T1 
			JOIN TraitDeterminationResult R ON R.TraitDeterminationResultID = T1.TraitDeterminationResultID
			WHERE T1.[Action] = 'D';

END
