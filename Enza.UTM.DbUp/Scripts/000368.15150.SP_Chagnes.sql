
DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_GetTestToSendScore]
GO
/*
=========Changes====================
Changed By			DATE				Description

Krishna Gautam		2020-08-10			#15150: Created Stored Procedure	

========Example=============
EXEC PR_RDT_GetTestToSendScore

*/


CREATE PROCEDURE [dbo].[PR_RDT_GetTestToSendScore]
AS
BEGIN

	SELECT TestID FROM Test WHERE StatusCode = 550 AND TestTypeID = 8;
END
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
	

	SELECT @CropCode = CropCode
	FROM [File] F 
	JOIN Test T ON T.FileID = F.FileID
	WHERE T.TestID = @TestID;


	SELECT T.TestID, M.MaterialKey, M.RefExternal, T1.ColumnLabel, TR.Score, TM.PhenomeObsID,T.ImportLevel, M.MaterialID,TR.TestID FROM Test T
	JOIN TestMaterial TM ON TM.TestID = T.TestID
	JOIN Material M ON M.MaterialID = TM.MaterialID
	JOIN RDTTestResult TR ON TR.TestID = T.TestID AND M.MaterialID = TR.MaterialID
	JOIN Determination D ON D.DeterminationID = TR.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
	JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = @CropCode
	JOIN Trait T1 ON T1.TraitID = CT.TraitID
	WHERE T.TestID = @TestID AND ISNULL(TR.IsResultSent,0) = 0
	order by MaterialID, D.DeterminationID


END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_UpdateObservationID]
GO

/*
=========Changes====================
Changed By			Date				Description

Krishna Gautam		2020-08-10			#15150: Created Stored Procedure	

========Example=============


*/

CREATE PROCEDURE [dbo].[PR_RDT_UpdateObservationID]
(
	@TestID INT,
	@TVP_PropertyValue TVP_PropertyValue READONLY
)
AS
BEGIN
	
	MERGE INTO TestMaterial T
	USING
	(
		SELECT MaterialID, MAX(CAST([Value] AS INT)) AS PhenomeObsID
		FROM @TVP_PropertyValue 
		WHERE [Key] = 'PhenomeObsID'
		GROUP BY MaterialID
	) S ON T.TestID = @TestID AND S.MaterialID = T.MaterialID 
	WHEN MATCHED THEN
	UPDATE SET T.PhenomeObsID = S.PhenomeObsID;


END
GO



DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_MarkSentResult]
GO


/*
=========Changes====================
Changed By			Date				Description

Krishna Gautam		2020-08-10			#15150: Created Stored Procedure	

========Example=============


*/


CREATE PROCEDURE [dbo].[PR_RDT_MarkSentResult]
(
	@TestID INT,
	@TestResultIDs NVARCHAR(MAX),
	@TestStatus INT OUTPUT
)
AS 
BEGIN
	DECLARE @AllSent BIT;

	UPDATE R SET R.IsResultSent = 1
	FROM RDTTestResult R
	JOIN string_split(@TestResultIDs,',') T1 ON ISNULL(CAST(T1.[value] AS INT),0) = R.RDTTestResultID

	IF EXISTS 
			(
				SELECT TOP 1 * FROM TestMaterialDetermination TMD
				LEFT JOIN RDTTestResult TR ON TMD.TestID = TR.TestID AND TMD.DeterminationID = TMD.DeterminationID AND TMD.MaterialID = TMD.MaterialID
				WHERE TR.TestID IS NULL AND TMD.TestID = @TestID
			)
	BEGIN
		SELECT @TestStatus = StatusCode FROM Test WHERE TestID = @TestID;
	END
	ELSE 
	BEGIN
		-- Check if all result is sent and update status if all sent
		IF EXISTS (SELECT TOP 1 * FROM RDTTestResult WHERE TestID = @TestID AND ISNULL(IsResultSent,0) = 0)
			SET @AllSent = 0;
		ELSE
			SET @AllSent = 1;

		IF(ISNULL(@AllSent,0) = 1)
			UPDATE Test SET StatusCode = 700 WHERE TestID = @TestID;


		SELECT @TestStatus = StatusCode FROM Test WHERE TestID = @TestID;
	END
	
END
GO


