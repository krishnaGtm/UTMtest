ALTER TABLE RDTTestResult
DROP COLUMN IsResultSent

GO

ALTER TABLE RDTTestResult
ADD ResultStatus INT

GO


INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (37, N'Test', 550, N'Partially Received', N'Partially Received')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (38, N'RDTTestResult', 100, N'Received', N'Result Received')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (39, N'RDTTestResult', 200, N'Error', N'Error sending result')
GO
INSERT [dbo].[Status] ([StatusID], [StatusTable], [StatusCode], [StatusName], [StatusDescription]) VALUES (40, N'RDTTestResult', 300, N'Sent', N'Result sent')
GO

DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_ReceiveResults]
GO


CREATE PROCEDURE [dbo].[PR_RDT_ReceiveResults]
(
	@TestID INT,
	@TVP_RDTScore TVP_RDTScore READONLY
) AS

BEGIN
SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
					
			--INSERT INTO RDTTestResult(TestID, DeterminationID, MaterialID, Score, ResultStatus)
			--SELECT @TestID, T1.DeterminationID, T1.MaterialID, T1.Score, 100		
			--FROM @TVP_RDTScore T1
			--JOIN TestMaterialDetermination TMD ON TMD.DeterminationID = T1.DeterminationID AND TMD.MaterialID = T1.MaterialID
			--WHERE TMD.TestID = @TestID
			--GROUP BY T1.DeterminationID, T1.MaterialID, T1.Score;

			--UPDATE Test 
			--	SET StatusCode = 550 --Partially Received
			--WHERE TestID = @TestID;
			
		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK;
		THROW;
	END CATCH
END

GO


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_MarkSentResult]
GO


CREATE PROCEDURE [dbo].[PR_RDT_MarkSentResult]
(
	@TestID INT,
	@TestResultIDs NVARCHAR(MAX),
	@TestStatus INT OUTPUT
)
AS 
BEGIN
	DECLARE @AllSent BIT;

	UPDATE R SET R.ResultStatus = 300 --R.IsResultSent = 1
	FROM RDTTestResult R
	JOIN string_split(@TestResultIDs,',') T1 ON ISNULL(CAST(T1.[value] AS INT),0) = R.RDTTestResultID

	IF EXISTS 
			(
				SELECT TOP 1 * FROM TestMaterialDetermination TMD
				LEFT JOIN RDTTestResult TR ON TMD.TestID = TR.TestID AND TMD.DeterminationID = TR.DeterminationID AND TMD.MaterialID = TR.MaterialID
				WHERE TR.TestID IS NULL AND TMD.TestID = @TestID
			)
	BEGIN
		SELECT @TestStatus = StatusCode FROM Test WHERE TestID = @TestID;
	END
	ELSE 
	BEGIN
		-- Check if all result is sent and update status if all sent
		IF EXISTS (SELECT TOP 1 * FROM RDTTestResult WHERE TestID = @TestID AND ResultStatus <> 300 ) --ISNULL(IsResultSent,0) = 0
			SET @AllSent = 0;
		ELSE
			SET @AllSent = 1;

		IF(ISNULL(@AllSent,0) = 1)
			UPDATE Test SET StatusCode = 700 WHERE TestID = @TestID;


		SELECT @TestStatus = StatusCode FROM Test WHERE TestID = @TestID;
	END
	
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
		TR.ResultStatus 
	FROM Test T
	JOIN TestMaterial TM ON TM.TestID = T.TestID
	JOIN Material M ON M.MaterialID = TM.MaterialID
	JOIN RDTTestResult TR ON TR.TestID = T.TestID AND M.MaterialID = TR.MaterialID
	JOIN Determination D ON D.DeterminationID = TR.DeterminationID
	JOIN RelationTraitDetermination RTD ON RTD.DeterminationID = D.DeterminationID
	JOIN CropTrait CT ON CT.CropTraitID = RTD.CropTraitID AND CT.CropCode = @CropCode
	JOIN Trait T1 ON T1.TraitID = CT.TraitID
	WHERE T.TestID = @TestID AND TR.ResultStatus IN (100,200) --ISNULL(TR.IsResultSent,0) = 0
	order by MaterialID, D.DeterminationID


END
GO


DROP PROCEDURE IF EXISTS [dbo].[PR_RDT_MarkResultError]
GO

CREATE PROCEDURE [dbo].[PR_RDT_MarkResultError]
(
	@TestID INT,
	@TestResultIDs NVARCHAR(MAX)
)
AS 
BEGIN

	SET NOCOUNT ON;
	
	UPDATE R SET R.ResultStatus = 200
	FROM RDTTestResult R
	JOIN string_split(@TestResultIDs,',') T1 ON ISNULL(CAST(T1.[value] AS INT),0) = R.RDTTestResultID

END

GO
