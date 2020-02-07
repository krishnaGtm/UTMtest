CREATE TYPE TVP_Trait_Determination_Relation AS TABLE
(
	TraitName NVARCHAR(MAX),
	CropCode NVARCHAR(MAX),
	DeterminationName NVARCHAR(MAX),
	TraitValue NVARCHAR(MAX),
	DeterminationValue NVARCHAR(MAX)
	
)
GO

CREATE PROCEDURE PR_ImportTraitDeterminationRelation
(
	@TVP_Trait_Determination_Relation TVP_Trait_Determination_Relation READONLY
) AS BEGIN
BEGIN TRY
		BEGIN TRAN
		DECLARE @RelationTraitDetermination AS TABLE
		(
			CropTraitID INT,
			DeterminationID INT,
			TraitValue NVARCHAR(MAX),
			DeterminationValue NVARCHAR(MAX)
		);

		INSERT INTO @RelationTraitDetermination(CropTraitID,DeterminationID,TraitValue, DeterminationValue)
		SELECT T.CropTraitID,D.DeterminationID,R.TraitValue,R.DeterminationValue FROM @TVP_Trait_Determination_Relation R
		JOIN 
		(
			SELECT CT.CropTraitID, CT.CropCode, CT.TraitID, T.TraitName FROM Trait T
			JOIN CropTrait CT ON CT.TraitID = T.TraitID
		) T ON T.TraitName = R.TraitName AND T.CropCode = R.CropCode
		JOIN Determination D ON D.DeterminationName = R.DeterminationName 
		

		MERGE INTO RelationTraitDetermination T
		USING 
		(
			SELECT CropTraitID,DeterminationID FROM @RelationTraitDetermination
			GROUP BY CropTraitID, DeterminationID
		) S ON S.CropTraitID = T.CropTraitID
		WHEN NOT MATCHED THEN
		INSERT(CropTraitID,DeterminationID,StatusCode)
		VALUES (S.CropTraitID, S.DeterminationID,100);
		--OUTPUT INSERTED.RelationID, INSERTED.CropTraitID,Inserted.DeterminationID INTO @Inserteddata(RelationID,CropTraitID, DeterminationID);


		MERGE INTO TraitDeterminationResult T
		USING 
		(
			SELECT R.RelationID,T1.TraitValue, T1.DeterminationValue FROM @RelationTraitDetermination T1
			JOIN RelationTraitDetermination R ON R.CropTraitID = T1.CropTraitID AND R.DeterminationID = T1.DeterminationID
		) S ON S.RelationID = T.RelationID
		WHEN NOT MATCHED THEN
		INSERT(RelationID, DetResChar, TraitResChar)
		VALUES (S.RelationID, S.DeterminationValue, S.TraitValue)
		WHEN MATCHED AND T.DetResChar <> S.DeterminationValue THEN
		UPDATE SET T.DetResChar = S.DeterminationValue;


		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END


GO