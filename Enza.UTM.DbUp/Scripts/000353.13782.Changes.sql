ALTER TABLE Material 
DROP COLUMN MaterialState
GO

ALTER TABLE Material
ADD MaterialStatus NVARCHAR(100)
GO




ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForRDT]
(	
	@CropCode							NVARCHAR(15),
	@TestID								INT,	
	@TVP_TMD_WithDate TVP_TMD_WithDate	READONLY,
	@TVPProperty TVP_PropertyValue		READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	
	--insert or delete statement for merge
	MERGE INTO TestMaterialDetermination T 
	USING @TVP_TMD_WithDate S	
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.ExpectedDate,'') != ISNULL(S.ExpectedDate,'')
		THEN UPDATE SET T.ExpectedDate = S.ExpectedDate		
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,ExpectedDate) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.ExpectedDate);


	MERGE INTO Material T 
	USING @TVPProperty S ON T.MaterialID = S.MaterialID AND S.[Key] = 'MaterialStatus'
	WHEN MATCHED AND ISNULL(T.MaterialStatus,'') <> ISNULL(S.[Value],'') THEN UPDATE
	SET T.MaterialStatus = S.[Value];

END

