DROP TYPE IF EXISTS [dbo].[TVP_RDTTraitDeterminationResult]
GO


CREATE TYPE [dbo].[TVP_RDTTraitDeterminationResult] AS TABLE(
	[RDTTraitDetResultID] [int] NULL,
	[RelationID] [int] NULL,
	[TraitResult] [nvarchar](1000) NULL,
	[DetResult] [nvarchar](1000) NULL,
	[MaterialStatus] [nvarchar](1000) NULL,
	[MinPercent] [decimal](18, 3) NULL,
	[MaxPercent] [decimal](18, 3) NULL,
	[MappingCol] [nvarchar](1000) NULL,
	[Action] [nvarchar](10) NULL
)
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_GetScore]
GO


/*
=========Changes====================
Changed By			Date				Description

Krishna Gautam		2020-08-10			#15150: Created Stored Procedure	

========Example=============
EXEC PR_RDT_GetScore 10628

*/


CREATE PROCEDURE [dbo].[PR_RDT_GetScore]
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
		LEFT JOIN RDTTraitDetResult TDR ON TDR.RelationID = RTD.RelationID AND TDR.DetResult = TR.Score
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
					AND ISNULL(TM.MaterialStatus,'') = ISNULL(TDR.MaterialStatus,'')				
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
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_Get_TraitDeterminationResult]
GO


/*
EXEC PR_RDT_Get_TraitDeterminationResult 200, 1, NULL, ''
EXEC PR_RDT_Get_TraitDeterminationResult 200, 1, 'CF', ''
*/
CREATE PROCEDURE [dbo].[PR_RDT_Get_TraitDeterminationResult]
(
	@PageSize	INT,
	@PageNumber INT,
	@Crops NVARCHAR(MAX),
	@Filter NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @Offset INT;
	SET @Offset = @PageSize * (@PageNumber -1);
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @CropCodes NVARCHAR(MAX);


	SELECT @CropCodes = COALESCE(@CropCodes + ',', '') + ''''+ T.[value] +'''' FROM 
	string_split(@Crops,',') T

	--PRINT @CropCodes

	IF(ISNULL(@Filter,'') <> '') BEGIN
	SET @Filter =' WHERE '+ @Filter;
	END

	ELSE BEGIN
		SET @Filter = '';
	END

	SET @SQL = N'
	;WITH CTE AS
	(
		SELECT * FROM 
		(
			SELECT 
				TDR.RDTTraitDetResultID AS ID,
				Crop = CT.CropCode,
				CT.CropTraitID,
				Trait = T.ColumnLabel,
				D.DeterminationID,
				Determination = D.DeterminationName,
				D.DeterminationAlias,
				TDR.MaterialStatus,
				PercentFrom = MinPercent,
				PercentTo = MaxPercent,
				MappingCol,
				TraitValue = TDR.TraitResult,
				[Value] = TDR.DetResult,
				RTD.RelationID
			FROM RDTTraitDetResult TDR
			JOIN RelationTraitDetermination RTD ON TDR.RelationID = RTD.RelationID
			JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID
			JOIN Determination D ON D.DeterminationID = RTD.DeterminationID
			JOIN Trait T ON T.TraitID = CT.TraitID
			WHERE T.Property = 0 AND CT.CropCode in ('+@CropCodes+')
		) AS T ' +@Filter +' 
	), CTE_COUNT AS
	(
		SELECT COUNT(ID) AS TotalRows FROM CTE
	)

	SELECT * FROM CTE, CTE_COUNT'

	SET @SQL = @SQL + '	ORDER BY CTE.Crop, CTE.Trait, CTE.CropTraitID
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY';

	--PRINT @SQL;
	EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset,@PageSize;
END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_SaveTraitDeterminationResult]
GO



CREATE PROCEDURE [dbo].[PR_RDT_SaveTraitDeterminationResult]
(
	@TVP		TVP_RDTTraitDeterminationResult READONLY
) AS BEGIN
	SET NOCOUNT ON;

	--merge statement
	MERGE INTO RDTTraitDetResult T
	USING @TVP S ON S.RDTTraitDetResultID = T.RDTTraitDetResultID
	WHEN MATCHED AND S.[Action] = 'U' THEN
	UPDATE SET 
			T.TraitResult = S.TraitResult,
			T.MappingCol = (CASE WHEN ISNULL(S.MappingCol,'') <> '' THEN S.MappingCol ELSE NULL END),
			T.MinPercent = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MinPercent ELSE NULL END),
			T.MaxPercent = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaxPercent ELSE NULL END),
			T.MaterialStatus = (CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaterialStatus ELSE NULL END)
	WHEN MATCHED AND S.[Action] = 'D' THEN
	DELETE
	WHEN NOT MATCHED AND S.[Action] = 'I'
	THEN INSERT (RelationID, TraitResult, DetResult, MappingCol, MinPercent, MaxPercent, MaterialStatus)
	VALUES 
	(RelationID, 
	TraitResult, 
	DetResult, 
	(CASE WHEN ISNULL(S.MappingCol,'') <> '' THEN S.MappingCol ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MinPercent ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaxPercent ELSE NULL END),
	(CASE WHEN ISNULL(S.MappingCol,'') = '' THEN S.MaterialStatus ELSE NULL END)
	);

END
GO


