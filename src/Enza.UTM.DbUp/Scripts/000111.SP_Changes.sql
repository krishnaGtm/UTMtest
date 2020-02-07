--EXEC PR_UpdateAndVerifyTraitDeterminationResult 'Phenome'
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL,
	@SendResult BIT =0
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @tbl1 AS TABLE 
	(
		DeterminationID INT
		
	);

	DECLARE @tbl2 AS TABLE
	(
		TestID INT,
		TestName NVARCHAR(MAX),
		Obsvaluechar NVARCHAR(MAX),
		croptraitid INT,
		traitname NVARCHAR(MAX),
		TraitValue NVARCHAR(MAX),
		determinationid INT,
		DeterminationName NVARCHAR(MAX),
		OriginRowID INT,
		MaterialKey NVARCHAR(MAX),
		CropCode NVARCHAR(MAX),
		Cummulate BIT,
		InvalidPer DECIMAL(5,2),
		FieldID NVARCHAR(MAX),
		RequestingUser NVARCHAR(MAX),
		StatusCode INT,
		isvalid BIT
	)

	INSERT INTO @tbl1
	(
		DeterminationID
	)
	SELECT TR.DeterminationID
	FROM dbo.TestResult TR 
	JOIN Well W ON W.WellID = TR.WellID
	
	JOIN Plate P ON P.PlateID = W.PlateID
	JOIN Test T ON T.TestID = P.TestID
	JOIN dbo.[File] F ON F.FileID = T.FileID
	
	JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode AND D.TestTypeID = T.TestTypeID
	JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
	JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = F.CropCode
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
	GROUP BY TR.DeterminationID
	HAVING COUNT(RTD.CropTraitID) > 1

	INSERT INTO @tbl2
	(
		TestID, TestName, Obsvaluechar,	croptraitid, traitname, TraitValue, determinationid, DeterminationName, OriginRowID, MaterialKey,	CropCode, Cummulate, InvalidPer, FieldID, RequestingUser, StatusCode, isvalid 
	)
	SELECT 
		T.TestID,
		T.TestName,
		TR.ObsValueChar,
		RTD.CropTraitID,
		T1.TraitName,
		TDR.TraitResChar,
		T2.DeterminationID,
		D.DeterminationName,
		Max(M.Originrowid),
		MAX(M.MaterialKey),
		Max(F.CropCode),
		T.Cumulate,
		MAX(CRD.InvalidPer),
		MAX(F.RefExternal),
		T.RequestingUser,
		T.StatusCode,
		CASE 
			WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
			WHEN ISNULL(T2.DeterminationID,0) = 0 THEN 1 
			ELSE 0 END
	FROM TestResult TR
	JOIN Well W ON W.WellID = TR.WellID
	JOIN TestMaterialDeterminationWell TMDW ON TMDW.WellID = W.WellID
	JOIN Plate P ON P.PlateID = W.PlateID
	JOIN Test T ON T.TestID = P.TestID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN CropRD CRD ON CRD.CropCode = F.CropCode
	JOIN dbo.Material M ON m.MaterialID = TMDW.MaterialID
	JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode AND D.TestTypeID = T.TestTypeID
	LEFT JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
	JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	JOIN dbo.Trait T1 ON T1.TraitID = CT.TraitID
	LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
	LEFT JOIN @tbl1 T2 ON T2.DeterminationID = TR.DeterminationID
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
	GROUP BY  T.TestID,TR.DeterminationID,TR.ObsValueChar,RTD.CropTraitID,T1.TraitName,TDR.DetResChar,T.TestName,t2.DeterminationID,D.DeterminationName,T.RequestingUser,T.StatusCode,T.Cumulate,TDR.TraitResChar

	;
	WITH CTE AS
	(
	SELECT T1.determinationid FROM 
	(
		SELECT determinationid,croptraitid, MIN(ISNULL(TraitValue,'')) AS Valid
		 FROM @tbl2
		WHERE isvalid = 0 
		GROUP BY determinationid,croptraitid
	) T1
	WHERE ISNULL(Valid,'') <> '' 
	GROUP BY determinationid 
	)
	UPDATE T1 SET T1.isvalid = 1
	FROM @tbl2 T1
	JOIN CTE T2 ON T1.determinationid = T2.determinationid

	--this select statement is done earlier because we are sending email based on status of test. Email should to be sent only once.
	if(ISNULL(@SendResult,0)= 0) BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID DeterminationName,RequestingUser,StatusCode, isvalid FROM @tbl2 WHERE isvalid = 0
	END
	ELSE BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID DeterminationName,RequestingUser,StatusCode, isvalid FROM @tbl2;
	END
	

	--update to status 625 if mapping of determinations and traits for test not present.
	UPDATE T1 SET T1.StatusCode = 625
	FROM Test T1
	WHERE EXISTS
	(
		SELECT TestID 
		FROM @tbl2 T2 
		WHERE T1.TestID = T2.TestID AND T2.isvalid = 0
		GROUP BY T2.TestID
	)

	--update to status 650 if all mapping of determinations and traits for test exists
	UPDATE T1 SET T1.StatusCode = 650
	FROM Test T1
	WHERE EXISTS
	(
		SELECT TestID 
		FROM @tbl2 T2 
		WHERE T1.TestID = T2.TestID AND T2.isvalid <> 0
		GROUP BY T2.TestID
	)


	/*This was previous method*/

	--DECLARE @tbl TABLE (TestID INT, DeterminationID INT, DeterminationValue NVARCHAR(255));
	--INSERT INTO @tbl(TestID, DeterminationID, DeterminationValue)
	--SELECT DISTINCT 
	--	T3.TestID, T1.DeterminationID, T1.ObsValueChar
	--FROM TestResult T1
	--JOIN Well T2 ON T2.WellID = T1.WellID
	--JOIN Plate T3 ON T3.PlateID = T2.PlateID
	--JOIN Test T ON T.TestID =T3.TestID
	--WHERE NOT EXISTS
	--(
	--	SELECT 
	--		TraitDeterminationResultID  
	--	FROM TraitDeterminationResult TDR
	--	JOIN RelationTraitDetermination RTD ON RTD.RelationID = TDR.RelationID
	--	WHERE DeterminationID = T1.DeterminationID
	--	AND DetResChar = T1.ObsValueChar --compare determination and its values in both table and if matches, send traitid and its values to Phenome
	--)
	--AND T.RequestingSystem  = @Source
	--AND T.StatusCode BETWEEN 600 AND 625;
	

	----UPDATE T1 SET 
	----	T1.StatusCode = 650
	----FROM Test T1
	----JOIN
	----(
	----	SELECT DISTINCT TestID FROM @tbl
	----) T2 ON T2.TestID = T1.TestID;

	--SELECT 
	--	T1.TestID, 
	--	T2.TestName,
	--	T1.DeterminationID,
	--	T3.DeterminationName,
	--	T1.DeterminationValue,
	--	T2.RequestingUser,
	--	T2.StatusCode
	--FROM @tbl T1
	--JOIN Test T2 ON T2.TestID = T1.TestID
	--JOIN Determination T3 ON T3.DeterminationID = T1.DeterminationID;

	----update to status 650 if all mapping of determinations and traits for test exists
	--UPDATE T1 SET 
	--	T1.StatusCode = 650
	--FROM Test T1
	--WHERE NOT EXISTS
	--(
	--	SELECT DISTINCT 
	--		T1.TestID 
	--	FROM @tbl TT1
	--	JOIN Test TT2 ON TT2.TestID = TT1.TestID
	--	JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
	--	WHERE TT1.TestID = T1.TestID
	--)
	--AND T1.RequestingSystem = @Source AND T1.StatusCode BETWEEN 600 AND 625

	----update to status 625 if mapping of determinations and traits for test not present.
	--UPDATE T1 SET 
	--	T1.StatusCode = 625
	--FROM Test T1
	--WHERE EXISTS
	--(
	--	SELECT DISTINCT 
	--		T1.TestID 
	--	FROM @tbl TT1
	--	JOIN Test TT2 ON TT2.TestID = TT1.TestID
	--	JOIN Determination TT3 ON TT3.DeterminationID = TT1.DeterminationID
	--	WHERE TT1.TestID = T1.TestID
	--)
	--AND T1.StatusCode != 625
END

