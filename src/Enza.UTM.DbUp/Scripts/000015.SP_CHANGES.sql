--DROP PROC PR_Save_RelationTraitDetermination
ALTER PROCEDURE [dbo].[PR_Save_RelationTraitDetermination]
(
	@TVP_RelationTraitDetermination TVP_RelationTraitDetermination READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	--INsert Statement

	IF EXISTS (SELECT R.RelationID 
		FROM RelationTraitDetermination R 
		JOIN  @TVP_RelationTraitDetermination T1 
		ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID
		WHERE T1.Action = 'I' AND R.Status = 'ACT') BEGIN

		EXEC PR_ThrowError 'Insert Failed. Relation already exists.';
		RETURN;
	END

	IF EXISTS (SELECT R.RelationID 
		FROM RelationTraitDetermination R 
		JOIN  @TVP_RelationTraitDetermination T1 
		ON T1.DeterminationID = R.DeterminationID AND R.Source=T1.Source AND R.TraitID = T1.TraitID AND R.RelationID != T1.RelationID
		WHERE T1.Action = 'U' AND R.Status = 'ACT') BEGIN

		EXEC PR_ThrowError 'Update Failed.Relation already exists.';
		RETURN;
	END

	INSERT INTO RelationTraitDetermination(CropCode,TraitID,ColumnLabel,DeterminationID,Source,Status)
	SELECT D.CropCode, T1.TraitID,T1.TraitName,D.DeterminationID,T1.[Source],'ACT'
	FROM @TVP_RelationTraitDetermination T1
	JOIN Determination D ON D.DeterminationID = T1.DeterminationID
	WHERE ISNULL(T1.RelationID,0) = 0 AND T1.[Action] = 'I';

	--DELETE/UPdate Statement 
	--We send Action = 'D' For Delete 'U' For UPdate.
	--UPDATE R
	--SET R.TraitID = T1.TraitID,
	--R.DeterminationID = T1.DeterminationID,
	--R.Source = T1.Source,
	--R.Status = CASE WHEN T1.Action = 'D' THEN 'BLOC' ELSE R.Status END
	--FROM @TVP_RelationTraitDetermination T1 
	--JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID


	--DELETE/UPdate Statement 
	--We send Action = 'D' For Delete.
	UPDATE R
	SET R.TraitID = T1.TraitID,
	R.DeterminationID = T1.DeterminationID,
	R.Source = T1.Source,
	R.ColumnLabel = T1.TraitName	
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.Action = 'U';


	--UPdate Statement 
	--We send Action = 'U' For UPdate.
	UPDATE R
	SET R.Status = 'BLOC'
	FROM @TVP_RelationTraitDetermination T1 
	JOIN RelationTraitDetermination R ON R.RelationID = T1.RelationID
	WHERE T1.Action = 'D';
	
END