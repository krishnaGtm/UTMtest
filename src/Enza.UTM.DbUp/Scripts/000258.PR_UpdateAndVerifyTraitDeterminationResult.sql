
--EXEC PR_UpdateAndVerifyTraitDeterminationResult NULL,'Phenome',1
ALTER PROCEDURE [dbo].[PR_UpdateAndVerifyTraitDeterminationResult]
(
	@TestID	INT = NULL,
	@Source NVARCHAR(100)= NULL,
	@SendResult BIT
)
AS BEGIN
	IF(ISNULL(@Source,'') = '') BEGIN
		SET @Source = 'Phenome'
	END

	SET NOCOUNT ON;
	DECLARE @TBL AS TABLE (TestID INT);
	DECLARE @Query NVARCHAR(MAX) ='';

	SET @Query = N';WITH CTE1 AS
					(
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
						IsValid = CASE 
							WHEN ISNULL(RTD.CropTraitID,0) = 0 THEN 0
							WHEN ISNULL(TDR.RelationID,0) = 0 THEN 0 
							ELSE 1 END,
					     W.Position,
						P.PlateName
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
						WHERE T.RequestingSystem = @Source 
						AND ((ISNULL(@TestID, 0) = 0 AND T.StatusCode BETWEEN 600 AND 650) OR T.TestID = @TestID)
						AND ISNULL(TR.IsResultSent,0) <> 1
						AND ISNULL(TR.ObsValueChar,'''') NOT IN ( ''-'','''')
					),
					CTE2 AS
					(
						SELECT determinationid, MAX(ISNULL(TraitResChar,'''')) AS TraitValue,ISNULL(Obsvaluechar,'''') AS determinationvalue 
						FROM CTE1
						GROUP BY DeterminationID,ObsValueChar

					)
					SELECT * FROM 
					(
						SELECT 
							T1.TestID, 
							T1.TestName,
							T1.Originrowid,
							T1.MaterialKey,
							T1.ColumnLabel,
							T1.TraitResChar,
							T1.ObsValueChar,
							T1.CropCode,
							T1.Cumulate,
							T1.InvalidPer,
							T1.RefExternal,
							T1.DeterminationName,
							T1.RequestingUser,
							T1.StatusCode,
							IsValid = CAST( CASE WHEN (T2.TraitValue <> '''' AND T1.IsValid = 0) THEN 1 ELSE T1.IsValid END AS BIT),
							T1.WellID,
							T1.Position,
							T1.PlateName
					FROM CTE1 T1
					JOIN CTE2 T2 ON ISNULL(T2.DeterminationID,0) = ISNULL(T1.DeterminationID,0) AND T2.determinationvalue = T1.Obsvaluechar
				) T ';
	
	if(ISNULL(@SendResult,0)= 0) 
	BEGIN
		SET @Query = @Query + 'WHERE IsValid = 0' ;
	END
	
	--SELECT @Query;
	EXEC sp_ExecuteSQL @Query,N'@TestID INT,@Source NVARCHAR(MAX),@SendResult BIT',@TestID,@Source,@SendResult;

END
