DROP PROCEDURE IF EXISTS [dbo].[PR_S2S_GetFillRateDetails]
GO

--EXEC PR_S2S_GetFillRateDetails 4369
CREATE PROCEDURE [dbo].[PR_S2S_GetFillRateDetails]
(
	@TestID	INT
) 
AS 
BEGIN
	SET NOCOUNT ON;

	;WITH CTE
	AS
	(
		SELECT T.CapacitySlotID FROM Test T
		WHERE T.TestID = @TestID
	)

	SELECT 
		CS.DH0Location,
		CS.MaxPlants,
		CS.AvailPlants,
		CS.CordysStatus,
		CS.CapacitySlotName, 
		(ISNULL(CS.MaxPlants,0) - ISNULL(CS.AvailPlants,0) + ISNULL(SUM(D.transplant),0)) AS FilledPlants 
	FROM CTE
	JOIN S2SCapacitySlot CS ON CS.CapacitySlotID = CTE.CapacitySlotID
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [Row] R ON R.FileID = T.FileID
	JOIN S2SDonorInfo D ON D.RowID = R.RowID 
	WHERE ISNULL(D.DonorNumber, '') = ''
	GROUP BY CS.CapacitySlotID,CS.DH0Location,
		CS.MaxPlants,
		CS.AvailPlants,
		CS.CordysStatus,	
		CS.CapacitySlotName

END
GO


