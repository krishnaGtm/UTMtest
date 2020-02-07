
--EXEC PR_UpdateAndVerifyTraitDeterminationResult 'Phenome',0
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
		OriginRowID NVARCHAR(MAX),
		MaterialKey NVARCHAR(MAX),
		CropCode NVARCHAR(MAX),
		Cummulate BIT,
		InvalidPer DECIMAL(5,2),
		FieldID NVARCHAR(MAX),
		RequestingUser NVARCHAR(MAX),
		StatusCode INT,
		WellID INT,
		isvalid BIT
	)


	INSERT INTO @tbl2
	(
		TestID, TestName, Obsvaluechar,	croptraitid, traitname, TraitValue, determinationid, DeterminationName, OriginRowID, MaterialKey,	CropCode, Cummulate, InvalidPer, FieldID, RequestingUser, StatusCode,WellID, isvalid 
	)
	SELECT 
		T.TestID,
		T.TestName,
		TR.ObsValueChar,
		RTD.CropTraitID,
		T1.ColumnLabel,
		TDR.TraitResChar,
		RTD.DeterminationID,
		D.DeterminationName,
		M.Originrowid,
		M.MaterialKey,
		F.CropCode,
		T.Cumulate,
		CRD.InvalidPer,
		M.RefExternal,
		T.RequestingUser,
		T.StatusCode,
		W.WellID,
		CASE 
			WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
			WHEN ISNULL(TDR.RelationID,0) = 0 THEN 0 
			ELSE 1 END		
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
	LEFT JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	LEFT JOIN dbo.Trait T1 ON T1.TraitID = CT.TraitID
	LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650


	;
	WITH CTE AS
	(
	
		SELECT determinationid, MAX(ISNULL(TraitValue,'')) AS TraitValue,ISNULL(Obsvaluechar,'') AS determinationvalue 
		FROM @tbl2		
		GROUP BY determinationid,Obsvaluechar
	
	)
	UPDATE T1 SET T1.isvalid = 1
	FROM @tbl2 T1
	JOIN CTE T2 ON T1.determinationid = T2.determinationid AND T2.determinationvalue = T1.Obsvaluechar 
	WHERE T2.TraitValue <> '' AND T1.isvalid = 0;

	--this select statement is done earlier because we are sending email based on status of test. Email should to be sent only once.
	if(ISNULL(@SendResult,0)= 0) BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid, WellID FROM @tbl2 WHERE isvalid = 0
	END
	ELSE BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid, WellID FROM @tbl2;
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
END

