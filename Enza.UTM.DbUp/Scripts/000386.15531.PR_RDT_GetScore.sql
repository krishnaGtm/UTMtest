
/*
=========Changes====================
Changed By			Date				Description

Krishna Gautam		2020-08-10			#15150: Created Stored Procedure	

========Example=============
EXEC PR_RDT_GetScore 10628

*/


ALTER PROCEDURE [dbo].[PR_RDT_GetScore]
(
	@TestID INT
)
AS 
BEGIN
	DECLARE @CropCode NVARCHAR(MAX);
	DECLARE @FlowType INT;
	

	SELECT @CropCode = CropCode, @FlowType = TestFlowType
	FROM [File] F 
	JOIN Test T ON T.FileID = F.FileID
	WHERE T.TestID = @TestID;

	SET @FlowType = 1;

	IF(@FlowType = 1)
	BEGIN
		SELECT 
			T.TestID, 
			M.MaterialKey, 
			M.RefExternal, 
			T1.ColumnLabel, 
			Score = CASE WHEN ISNULL(TDR.TraitResult,'') <> '' THEN TDR.TraitResult ELSE TR.Score END, 
			TM.PhenomeObsID,
			T.ImportLevel, 
			M.MaterialID,
			TR.RDTTestResultID,
			TR.ResultStatus,
			TDR.RDTTraitDetResultID,
			TDR.TraitResult,
			FlowType = @FlowType
		FROM Test T
		JOIN TestMaterial TM ON TM.TestID = T.TestID
		JOIN Material M ON M.MaterialID = TM.MaterialID
		JOIN RDTTestResult TR ON TR.TestID = T.TestID AND M.MaterialID = TR.MaterialID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
		LEFT JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = @CropCode
		LEFT JOIN Trait T1 ON T1.TraitID = CT.TraitID
		LEFT JOIN RDTTraitDetResult TDR ON TDR.RelationID = RTD.RelationID AND ISNULL(TDR.DetResult,'') = ISNULL(TR.Score,'')
		WHERE T.TestID = @TestID AND TR.ResultStatus IN (100,200)
		order by MaterialID
	END
	ELSE IF (@FlowType = 2)
	BEGIN
		SELECT 
			T.TestID, 
			M.MaterialKey, 
			M.RefExternal, 
			T1.ColumnLabel, 
			Score = CASE WHEN ISNULL(TDR.TraitResult,'') <> '' THEN TDR.TraitResult ELSE TR.Score END, 
			TM.PhenomeObsID,
			T.ImportLevel, 
			M.MaterialID,
			TR.RDTTestResultID,
			TR.ResultStatus,
			TDR.RDTTraitDetResultID,
			TDR.TraitResult,
			FlowType = @FlowType
		FROM Test T
		JOIN TestMaterial TM ON TM.TestID = T.TestID
		JOIN Material M ON M.MaterialID = TM.MaterialID
		JOIN RDTTestResult TR ON TR.TestID = T.TestID AND M.MaterialID = TR.MaterialID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
		LEFT JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = @CropCode
		LEFT JOIN Trait T1 ON T1.TraitID = CT.TraitID
		LEFT JOIN RDTTraitDetResult TDR ON 
					TDR.RelationID = RTD.RelationID
					AND (TM.MaterialStatus = TDR.MaterialStatus	OR ISNULL(TDR.MaterialStatus,'') = '')			
					AND (
							ISNULL(TDR.DetResult,'') = ISNULL(TR.Score,'') 
							OR (TR.SusceptibilityPercent BETWEEN TDR.MinPercent AND TDR.MaxPercent)
						)
		WHERE T.TestID = @TestID AND TR.ResultStatus IN (100,200)
		order by MaterialID
	END
	ELSE IF (@FlowType = 3)
	BEGIN
		SELECT 
			T.TestID, 
			M.MaterialKey, 
			M.RefExternal, 
			T1.ColumnLabel, 
			TR.Score, 
			TM.PhenomeObsID,
			T.ImportLevel, 
			M.MaterialID,
			TR.RDTTestResultID,
			TR.ResultStatus,
			TDR.RDTTraitDetResultID,
			TDR.TraitResult,
			FlowType = @FlowType
		FROM Test T
		JOIN TestMaterial TM ON TM.TestID = T.TestID
		JOIN Material M ON M.MaterialID = TM.MaterialID
		JOIN RDTTestResult TR ON TR.TestID = T.TestID AND M.MaterialID = TR.MaterialID
		LEFT JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
		LEFT JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = @CropCode
		LEFT JOIN Trait T1 ON T1.TraitID = CT.TraitID		
		LEFT JOIN RDTTraitDetResult TDR ON 
					TDR.RelationID = RTD.RelationID
					AND ISNULL(TDR.MappingCol,'') = ISNULL(TR.MappingColumn,'') 
		WHERE T.TestID = @TestID AND TR.ResultStatus IN (100,200)
		order by MaterialID
	END

END
