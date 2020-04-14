
DROP PROCEDURE IF EXISTS [dbo].[PR_Get_Total_Marker]
GO

/*
-- =============================================
Author:					Date				Remark
Krishna Gautam			2020/03/25			SP Created		

DECLARE @TotalMarker INT 
EXEC PR_Get_Total_Marker 4556, @TotalMarker OUT
PRINT @TotalMarker
*/
CREATE PROCEDURE [dbo].[PR_Get_Total_Marker]
(
	@TestID INT,
	@TotalMarker INT OUT
)
AS BEGIN
	
	DECLARE @DeadWellType INT;
	--this is needed to exclude marker used by dead material which resides in dead well
	SELECT @DeadWellType = WellTypeID 
	FROM WEllType WHERE WellTypeName = 'D'

	SELECT @TotalMarker = COUNT(V2.DeterminationID)
	FROM
	(
		SELECT V.DeterminationID, V.PlateID
		FROM
		(
			SELECT P.PlateID, TMDW.MaterialID, TMD.DeterminationID FROM TestMaterialDetermination TMD 
			JOIN TestMaterialDeterminationWell TMDW ON TMDW.MaterialID = TMD.MaterialID
			JOIN Well W ON W.WellID = TMDW.WellID
			JOIN Plate P ON P.PlateID = W.PlateID AND P.TestID = TMD.TestID
			WHERE TMD.TestID = @TestID AND W.WellTypeID <> @DeadWellType
		
		) V
		GROUP BY V.DeterminationID, V.PlateID
	) V2


END
GO


