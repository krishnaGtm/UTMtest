IF NOT EXISTS (
  SELECT * 
  FROM EmailConfig 
  WHERE ConfigGroup = 'TEST_COMPLETE_NOTIFICATION'
) BEGIN
    INSERT EmailConfig(ConfigGroup, CropCode) 
    VALUES('TEST_COMPLETE_NOTIFICATION', '*')
END
GO
-- EXEC PR_GetTestsForTraitDeterminationResults 'Phenome'
ALTER PROCEDURE [dbo].[PR_GetTestsForTraitDeterminationResults]
(
	@Source NVARCHAR(100)
) AS BEGIN
	SET NOCOUNT ON;

	SELECT 
		T.TestID,
		T.TestName,
		T.StatusCode,
        T.LabPlatePlanName,
        T.BreedingStationCode	
	FROM Test T 
	WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650
END
GO

