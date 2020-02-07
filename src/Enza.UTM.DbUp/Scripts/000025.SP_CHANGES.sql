--EXEC PR_UpdateAndVerifyTraitDeterminationResult
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @tbl TABLE (TestID INT, DeterminationID INT, DeterminationValue NVARCHAR(255));
	INSERT INTO @tbl(TestID, DeterminationID, DeterminationValue)
	SELECT DISTINCT 
		T3.TestID, T1.DeterminationID, T1.ObsValueChar
	FROM TestResult T1
	JOIN Well T2 ON T2.WellID = T1.WellID
	JOIN Plate T3 ON T3.PlateID = T2.PlateID
	JOIN Test T ON T.TestID =T3.TestID
	WHERE NOT EXISTS
	(
		SELECT 
			TraitDeterminationResultID 
		FROM TraitDeterminationResult
		WHERE DeterminationID = T1.DeterminationID
		AND DetResChar = T1.ObsValueChar --compare determination and its values in both table and if matches, send traitid and its values to Phenome
	)
	AND T.RequestingSystem  = @Source
	AND T.StatusCode BETWEEN 600 AND 625;
	

	--UPDATE T1 SET 
	--	T1.StatusCode = 650
	--FROM Test T1
	--JOIN
	--(
	--	SELECT DISTINCT TestID FROM @tbl
	--) T2 ON T2.TestID = T1.TestID;

	SELECT 
		T1.TestID, 
		T2.TestName,
		T1.DeterminationID,
		T3.DeterminationName,
		T1.DeterminationValue,
		T2.RequestingUser,
		T2.StatusCode
	FROM @tbl T1
	JOIN Test T2 ON T2.TestID = T1.TestID
	JOIN Determination T3 ON T3.DeterminationID = T1.DeterminationID;

	--update to status 650 if all mapping of determinations and traits for test exists
	UPDATE T1 SET 
		T1.StatusCode = 650
	FROM Test T1
	WHERE NOT EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.RequestingSystem = @Source AND T1.StatusCode BETWEEN 600 AND 625

	--update to status 625 if mapping of determinations and traits for test not present.
	UPDATE T1 SET 
		T1.StatusCode = 625
	FROM Test T1
	WHERE EXISTS
	(
		SELECT DISTINCT 
			T1.TestID 
		FROM @tbl TT1
		JOIN Test TT2 ON TT2.TestID = TT1.TestID
		JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
		WHERE TT1.TestID = T1.TestID
	)
	AND T1.StatusCode != 625
END

