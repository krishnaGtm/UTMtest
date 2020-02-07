DROP PROCEDURE IF EXISTS PR_S2S_GetMarkerTestData
GO

CREATE PROCEDURE PR_S2S_GetMarkerTestData
(
	@ReplicationCode	NVARCHAR(20) = 'PH',
	@CapacitySlotID		INT = NULL,
	@MaterialID			INT = NULL --TestID in service input parameter
) AS BEGIN
	SET NOCOUNT ON;

	SELECT
		DI.DonorNumber,
		MarkerNumber = DMS.DeterminationID,
		MarkerName = D.DeterminationName,
		DonorMarkerUse = 'Sel',
		HaploidMarkerUse = 'Sel',
		AutoSelectScore = DMS.Score
	FROM S2SCapacitySlot CS
	JOIN Test T ON T.CapacitySlotID = CS.CapacitySlotID
	JOIN [File] F ON F.FileID = T.FileID
	JOIN [Row] R ON R.FileID = F.FileID
	JOIN Material M ON M.MaterialKey = R.MaterialKey
	JOIN S2SDonorInfo DI ON DI.RowID = R.RowID
	JOIN S2SDonorMarkerScore DMS ON DMS.TestID = T.TestID AND DMS.MaterialID = M.MaterialID
	JOIN Determination D ON D.DeterminationID = DMS.DeterminationID
	WHERE T.StatusCode >= 700
	AND (ISNULL(@CapacitySlotID, 0) = 0 OR CS.CapacitySlotID = @CapacitySlotID)
	AND (ISNULL(@MaterialID, 0) = 0 OR M.MaterialID = @MaterialID);
END