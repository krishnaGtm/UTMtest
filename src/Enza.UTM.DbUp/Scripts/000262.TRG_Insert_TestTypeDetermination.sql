MERGE INTO TestTypeDetermination T
USING 
(
	SELECT D.DeterminationID,TT.TestTypeID FROM Determination D
	CROSS JOIN TestType TT WHERE TT.DeterminationRequired = 1
) S
ON S.DeterminationID = T.DeterminationID AND S.TestTypeID = T.TestTypeID
WHEN NOT MATCHED THEN 
INSERT (DeterminationID, TestTypeID)
VALUES(S.DeterminationID,S.TestTypeID);
GO



DROP TRIGGER IF EXISTS [dbo].[TRG_Insert_TestTypeDetermination]
GO

CREATE TRIGGER [dbo].[TRG_Insert_TestTypeDetermination]
ON [dbo].[Determination]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @TestType TABLE(TestTypeID INT);
	
	INSERT INTO @TestType(TestTypeID)
	SELECT TestTypeID FROM TestType WHERE DeterminationRequired = 1;

	INSERT INTO TestTypeDetermination	(DeterminationID,TestTypeID)
	SELECT I.DeterminationID,T.TestTypeID FROM inserted I
	CROSS JOIN @TestType T
END
GO

ALTER TABLE [dbo].[Determination] ENABLE TRIGGER [TRG_Insert_TestTypeDetermination]
GO


