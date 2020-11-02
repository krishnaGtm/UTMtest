
/* 
Author					 Date			Description
Krishna Gautam			-				- Stored procedure created
Krishna Gautam			2020/10/14		#16301: Change status of DNA test type to 600.

Example
=============================================  

*/
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

	--TestTypeID for DNA isolation is 2
	--#16301: Change based on this BLI.
	UPDATE Test  SET StatusCode = 700 WHERE TestTypeID = 2 AND StatusCode > 400 AND GETDATE() > DATEADD(Week,2, ExpectedDate )


	SET NOCOUNT ON;
	DECLARE @TBL AS TABLE (TestID INT);
	DECLARE @Query NVARCHAR(MAX) ='';
	DECLARE @TraitIDS NVARCHAR(MAX);
	DECLARE @TraitQuery NVARCHAR(MAX) = '';

	IF(ISNULL(@TestID,0) <> 0)
	BEGIN
		SELECT  @TraitIDS = CASE 
							WHEN @TraitIDS = '' THEN ''
							ELSE COALESCE(@TraitIDS + ',', '') + CAST(C.TraitiD AS NVARCHAR(MAX))
							END
		FROM [Column] C
		JOIN [File] F ON F.FileID = C.FileId
		JOIN Test T ON T.FileID = F.FileID
		WHERE T.TestID = @TestID AND C.TraitID IS NOT NULL;

		SET @TraitQuery = 'AND T1.TraitID IN ('+@TraitIDs+')';
	END

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
						IsValid = CAST (CASE 
							WHEN ISNULL(TDR.RelationID,0) = 0 THEN 0 
							ELSE 1 END AS BIT),
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
						JOIN dbo.Determination D ON D.DeterminationID = TR.DeterminationID AND D.CropCode = F.CropCode
						JOIN dbo.RelationTraitDetermination RTD ON RTD.DeterminationID = TR.DeterminationID
						JOIN dbo.CropTrait CT ON CT.CropTraitID = RTD.CropTraitID						
						JOIN Trait T1 ON T1.TraitID = CT.TraitID
						LEFT JOIN dbo.TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResChar = TR.ObsValueChar 
						WHERE T.RequestingSystem = @Source 
						AND ((ISNULL(@TestID, 0) = 0 AND T.StatusCode BETWEEN 600 AND 650) OR T.TestID = @TestID)
						AND ISNULL(TR.IsResultSent,0) <> 1
						AND ISNULL(TR.ObsValueChar,'''') NOT IN ( ''-'','''')						
						'+ @TraitQuery +'
					)SELECT 
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
							T1.IsValid,
							T1.WellID,
							T1.Position,
							T1.PlateName
					FROM CTE1 T1';
	
	if(ISNULL(@SendResult,0)= 0) 
	BEGIN
		SET @Query = @Query + 'WHERE IsValid = 0' ;
	END
	
	--SELECT @Query;
	EXEC sp_ExecuteSQL @Query,N'@TestID INT,@Source NVARCHAR(MAX),@SendResult BIT',@TestID,@Source,@SendResult;

END
