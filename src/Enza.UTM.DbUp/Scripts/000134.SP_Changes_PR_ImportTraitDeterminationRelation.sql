/*
declare @p1 dbo.TVP_Trait_Determination_Relation
insert into @p1 values(N'CB LoV Int',N'CC',N'SLM0000001',N'R',N'0001')
insert into @p1 values(N'CLoVT 5',N'CC',N'SLM0000001',N'RS',N'0010')
insert into @p1 values(N'CLoVT 5',N'CC',N'SLM0000002',N'RR',N'0101')
insert into @p1 values(N'CB LoV Int',N'CC',N'SLM0000002',N'SR',N'1010')

exec PR_ImportTraitDeterminationRelation @TVP_Trait_Determination_Relation=@p1
*/
ALTER PROCEDURE [dbo].[PR_ImportTraitDeterminationRelation]
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
			SELECT CT.CropTraitID, CT.CropCode, CT.TraitID, T.ColumnLabel FROM Trait T
			JOIN CropTrait CT ON CT.TraitID = T.TraitID
		) T ON T.ColumnLabel = R.TraitName AND T.CropCode = R.CropCode
		JOIN Determination D ON D.DeterminationName = R.DeterminationName 
		


		MERGE INTO RelationTraitDetermination T
		USING 
		(
			SELECT CropTraitID,DeterminationID FROM @RelationTraitDetermination
			GROUP BY CropTraitID, DeterminationID
		) S ON S.CropTraitID = T.CropTraitID AND S.DeterminationID = T.DeterminationID
		WHEN NOT MATCHED THEN
		INSERT(CropTraitID,DeterminationID,StatusCode)
		VALUES (S.CropTraitID, S.DeterminationID,100);
		


		MERGE INTO TraitDeterminationResult T
		USING 
		(
			SELECT R.RelationID,T1.TraitValue, T1.DeterminationValue FROM @RelationTraitDetermination T1
			JOIN RelationTraitDetermination R ON R.CropTraitID = T1.CropTraitID AND R.DeterminationID = T1.DeterminationID
		) S ON S.RelationID = T.RelationID AND T.TraitResChar = S.TraitValue AND T.DetResChar = S.DeterminationValue
		WHEN NOT MATCHED THEN
		INSERT(RelationID, DetResChar, TraitResChar)
		VALUES (S.RelationID, S.DeterminationValue, S.TraitValue);
		
		--Find unimported relation
		SELECT	T3.CropCode AS 'Crop', 
				T3.TraitName AS 'TraitLabel', 
				T3.DeterminationName AS 'DeterminationLabel', 
				T3.TraitValue AS 'TraitValue', 
				T3.DeterminationValue AS 'DeterminationValue' 
			FROM @TVP_Trait_Determination_Relation T3
		LEFT JOIN
		(
			SELECT CT.CropCode, T.ColumnLabel, D.DeterminationName FROM RelationTraitDetermination T1
			JOIN CropTrait CT ON CT.CropTraitID = T1.CropTraitID
			JOIN Trait T ON T.TraitID = CT.TraitID
			JOIN Determination D ON D.DeterminationID = T1.DeterminationID
		) T2 ON T3.CropCode = T2.CropCode AND T3.TraitName = T2.ColumnLabel AND T3.DeterminationName = T2.DeterminationName
		WHERE T2.CropCode IS NULL AND T2.ColumnLabel IS NULL AND T2.DeterminationName IS NULL

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END


