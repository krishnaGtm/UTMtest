
--EXEC PR_GetConvertedTraitDeterminationResult 'Phenome'
ALTER PROCEDURE [dbo].[PR_GetConvertedTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
			
		SELECT T.TestID, M.Originrowid, M.MaterialKey, T1.ColumnLabel,TDR.TraitResChar AS Traitvalue, TR.ObsValueChar AS DeterminationValue, F.CropCode,ISNULL(T.Cumulate,0) as Cumulate, ISNULL(CRD.InvalidPer,0) AS InvalidPer, F.RefExternal  --, CE.[Value] AS GID 
		FROM dbo.TestResult TR
		JOIN dbo.TestMaterialDeterminationWell TMDW ON TMDW.WellID = TR.WellID
		JOIN well W ON W.WellID = TMDW.WellID
		JOIN plate P ON P.PlateID = W.PlateID
		JOIN dbo.Test T ON T.TestID = P.TestID
		JOIN [file] F ON F.FileID = T.FileID
		--JOIN [dbo].[Column] C ON C.FileID = F.FileID AND C.ColumLabel = 'GID'
		--JOIN [dbo].[Row] R ON R.FileID = C.FileID 
		--JOIN [dbo].[Cell] CE ON CE.ColumnID = C.ColumnID AND CE.RowID = R.RowID
		JOIN dbo.Material M ON m.MaterialID = TMDW.MaterialID AND M.CropCode = F.CropCode --AND R.MaterialKey = m.MaterialKey
		JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID AND RTD.StatusCode = 100
		JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode AND D.CropCode = M.CropCode AND D.DeterminationID = RTD.DeterminationID AND D.TestTypeID = T.TestTypeID
		JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar
		JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = F.CropCode AND CT.CropCode = M.CropCode
		JOIN dbo.CropRD CRD ON CRD.CropCode = CT.CropCode AND CRD.CropCode = D.CropCode AND CRD.CropCode = F.CropCode
		JOIN dbo.Trait T1 ON T1.TraitID = CT.TraitID		
		WHERE T.RequestingSystem = @Source


END

