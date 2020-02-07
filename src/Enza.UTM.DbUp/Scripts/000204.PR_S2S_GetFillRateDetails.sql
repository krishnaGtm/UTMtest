/****** Object:  StoredProcedure [dbo].[PR_S2S_GetFillRateDetails]    Script Date: 5/17/2019 1:06:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_S2S_GetFillRateDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PR_S2S_GetFillRateDetails]
GO
/****** Object:  StoredProcedure [dbo].[PR_S2S_GetFillRateDetails]    Script Date: 5/17/2019 1:06:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC PR_S2S_GetFillRateDetails 4369
CREATE PROCEDURE [dbo].[PR_S2S_GetFillRateDetails]
(
	@TestID	INT
) AS BEGIN
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
		SUM(D.transplant) AS FilledPlants 
	FROM CTE
	JOIN S2SCapacitySlot CS ON CS.CapacitySlotID = CTE.CapacitySlotID
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [Row] R ON R.FileID = T.FileID
	JOIN S2SDonorInfo D ON D.RowID = R.RowID
	GROUP BY CS.CapacitySlotID,CS.DH0Location,
		CS.MaxPlants,
		CS.AvailPlants,
		CS.CordysStatus,	
		CS.CapacitySlotName

END
GO
