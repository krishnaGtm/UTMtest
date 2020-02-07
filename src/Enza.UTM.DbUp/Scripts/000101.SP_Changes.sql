
/****** Object:  StoredProcedure [dbo].[PR_GetConvertedTraitDeterminationResult]    Script Date: 11/20/2018 4:02:53 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[PR_GetConvertedTraitDeterminationResult]
GO

--EXEC PR_GetConvertedTraitDeterminationResult 'Phenome'
CREATE PROCEDURE [dbo].[PR_GetConvertedTraitDeterminationResult]
(
	@Source NVARCHAR(100)= NULL
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
			
		SELECT T.TestID,T.TestName, Mat.GID, M.MaterialKey,mat.[plant name], mat.[Entry code], T1.TraitID, T1.TraitName, T1.ColumnLabel,D.DeterminationID,TDR.TraitResChar AS Traitvalue, TR.ObsValueChar AS DeterminationValue, F.CropCode,ISNULL(T.Cumulate,0) as Cumulate, ISNULL(CRD.InvalidPer,50) AS InvalidPer, F.RefExternal  --, CE.[Value] AS GID 
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
		JOIN 
		(
			SELECT PIV.MaterialKey, GID, PIV.[plant name],PIV.[Entry code] FROM 
			(
				SELECT C1.[Value],R.MaterialKey, C.ColumLabel FROM [dbo].[File] F
				JOIN dbo.Test T ON T.FileID = F.FileID
				JOIN dbo.[Column] C ON C.FileID = F.FileID
				JOIN dbo.[Row] R ON R.FileID = F.FileID
				JOIN dbo.Cell C1 ON C1.ColumnID = C.ColumnID AND C1.RowID = R.RowID
				--WHERE C.ColumLabel = 'GID' --AND T.StatusCode = 650
				WHERE C.ColumLabel IN ('GID','Plant name','Entry code') AND T.StatusCode = 650
			)
			SRC 
			PIVOT
			(
				MAX([Value])
				FOR ColumLabel IN ([GID],[plant name],[Entry code])
			) PIV
		) Mat ON Mat.MaterialKey = M.MaterialKey
		WHERE T.RequestingSystem = @Source


END

GO


