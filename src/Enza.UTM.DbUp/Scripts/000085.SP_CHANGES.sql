--EXEC PR_GetDeterminationsForExternalTests 'LT', 1
CREATE PROCEDURE PR_GetDeterminationsForExternalTests
(
	@CropCode NVARCHAR(10),
	@TestTypeID INT
) AS BEGIN
	SET NOCOUNT ON;

	SELECT 
		T1.DeterminationID,
		T1.DeterminationName,
		T1.DeterminationAlias,
		T2.ColumnLabel
	FROM Determination T1
	JOIN
	(
		SELECT DISTINCT
			T1.DeterminationID,
			T.ColumnLabel
		FROM RelationTraitDetermination T1
		JOIN CropTrait CT ON CT.CropTraitID =T1.CropTraitID
		JOIN Trait T ON T.TraitID = CT.TraitID
		WHERE T1.[StatusCode] = 100
	) T2 ON T2.DeterminationID = T1.DeterminationID
	WHERE T1.CropCode = @CropCode 
	AND T1.TestTypeID = @TestTypeID;
END
GO