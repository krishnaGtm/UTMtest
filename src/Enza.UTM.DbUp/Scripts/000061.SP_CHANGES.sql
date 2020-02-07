--DROP PROC PR_Save_RelationTraitDetermination
ALTER PROCEDURE [dbo].[PR_Save_RelationTraitDetermination]
(
	@TVP_RelationTraitDetermination TVP_RelationTraitDetermination READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	
	--validation on insert
	--EXEC PR_ThrowError 'test'
	--RETURN;

	

	IF EXISTS (SELECT R.RelationID 
		FROM RelationTraitDetermination R 
		JOIN  @TVP_RelationTraitDetermination T1
		ON R.CropTraitID = T1.TraitID AND R.DeterminationID = T1.DeterminationID
		WHERE  T1.[Action] = 'I') BEGIN
			EXEC PR_ThrowError 'Insert Failed. Relation already exists.';
			RETURN;
		RETURN;
	END

	--validation for update and delete.
	IF EXISTS(
		SELECT TSR.TraitDeterminationResultID FROM TraitDeterminationResult TSR
		JOIN @TVP_RelationTraitDetermination T1 ON T1.RelationID = TSR.RelationID
		JOIN RelationTraitDetermination RTS ON RTS.RelationID = TSR.RelationID
		WHERE T1.DeterminationID != RTS.DeterminationID AND T1.Action IN ('U','D')) BEGIN
		EXEC PR_ThrowError 'Trait result mapping(s) already present for this Trait - Determination. Please delete Trait Result first.';
		RETURN;
	END



	INSERT INTO RelationTraitDetermination(CropTraitID, DeterminationID, [StatusCode])
	SELECT T1.TraitID, D.DeterminationID, '100'
	FROM @TVP_RelationTraitDetermination T1
	JOIN Determination D ON D.DeterminationID = T1.DeterminationID
	WHERE ISNULL(T1.RelationID, 0) = 0 AND T1.[Action] = 'I';

	--UPdate Statement 
	UPDATE R SET 
		R.DeterminationID = T1.DeterminationID
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'U';


	--DELETE Statement 
	DELETE R
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.[Action] = 'D';
	
END
