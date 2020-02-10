DROP PROCEDURE IF EXISTS PR_S2S_GetMarkerTestData
GO

--EXEC PR_S2S_GetMarkerTestData 4378, 34277;
CREATE PROCEDURE PR_S2S_GetMarkerTestData
(
	@TestID				INT,
	@MaterialID			INT
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
	AND T.TestID = @TestID
	AND M.MaterialID = @MaterialID;
END
GO