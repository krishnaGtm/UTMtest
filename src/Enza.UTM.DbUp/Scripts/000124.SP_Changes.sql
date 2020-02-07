DROP PROCEDURE IF EXISTS  MarkSentResult
GO

CREATE PROCEDURE MarkSentResult
(
	@WellID NVARCHAR(MAX),
	@TestID INT
)
AS 
BEGIN
	UPDATE T  SET T. IsResultSent = 1
	FROM TestResult T
	JOIN String_Split(@WellID,',') T1 ON T.WellID =CAST(T1.[value] AS INT)

	IF NOT EXISTS(
		SELECT T.TestID FROM Test T 
		JOIN Plate P ON P.TestID = P.TestID
		JOIN Well W ON W.PlateID = P.PlateID
		JOIN TestResult TR ON TR.WellID = W.WellID
		WHERE T.TestID = @TestID AND ISNULL(TR.IsResultSent,0) = 0
	) BEGIN

		UPDATE Test SET StatusCode = 700
		WHERE TestID = @TestID
	END
END

GO

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
		TestID, TestName, Obsvaluechar,	croptraitid, traitname, TraitValue, determinationid, DeterminationName, OriginRowID, MaterialKey,	CropCode, Cummulate, InvalidPer, FieldID, RequestingUser, StatusCode,WellID, isvalid 
	)
	SELECT 
		T.TestID,
		T.TestName,
		TR.ObsValueChar,
		RTD.CropTraitID,
		T1.ColumnLabel,
		TDR.TraitResChar,
		T2.DeterminationID,
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
	LEFT JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
	LEFT JOIN dbo.Trait T1 ON T1.TraitID = CT.TraitID
	LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
	LEFT JOIN @tbl1 T2 ON T2.DeterminationID = TR.DeterminationID
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
	

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
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid, WellID FROM @tbl2 WHERE isvalid = 0
	END
	ELSE BEGIN
		SELECT TestID,TestName,OriginRowID,MaterialKey,traitname,TraitValue, Obsvaluechar, CropCode,Cummulate,InvalidPer,FieldID, DeterminationName,RequestingUser,StatusCode, isvalid,WellID FROM @tbl2;
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

